function EROSHIELD15_literature_screening_v2()
% EROSHIELD-15 - literature-calibrated aerodynamic screening V2
% Preliminary portfolio/research model. Not product validation.
% Recovery is calculated as an output, not prescribed.

clc; close all;

script_dir = fileparts(mfilename('fullpath'));
if isempty(script_dir), script_dir = pwd; end

%% Configuration
rho = 1.225;
V0 = 10.59;
omega = 0.7916813478;
B = 3;
pitch = 0.0;
nu_air = 1.4607e-5;
P_clean_reference_W = 16.204e6;

max_iter = 200;
tol = 1e-6;
relax = 0.25;
a_min = 0.00; a_max = 0.50;
ap_min = -0.10; ap_max = 0.20;
F_min = 0.01;

%% IEA 15-MW outer-blade stations
blspn = [90.73464077239812;93.12239447693490;95.51014818147171; ...
97.89790188600848;100.28565559054530;102.67340929508210; ...
105.06116299961890;107.44891670415570;109.83667040869240; ...
112.22442411322920;114.61217781776610;116.99993152230280];

chord = [2.880705106690617;2.786969376686517;2.691030938627057; ...
2.591965555977676;2.489323647505217;2.383917231097341; ...
2.275923816206998;2.165466732053696;2.052625082558482; ...
1.937753326819164;1.819662967336163;0.500000000000000];

twist = [-1.623298762065715;-1.884368146311783;-2.086230093232373; ...
-2.163998201705838;-2.175841166085000;-2.155303774975188; ...
-2.102909521958467;-2.018403421317624;-1.896743213972770; ...
-1.724325762660474;-1.508125114401624;-1.242387706272970];

afid = (39:50)';
polar_suffix = afid - 1;
nsta = numel(blspn);

shield_start = 100.28565559054530;
shield_end   = 109.83667040869240;

% Current public geometry convention used in the final screening.
HubRad_axis = 3.97;
TipRad_axis = 120.97;
precone_deg = 4.0;

r = (HubRad_axis + blspn).*cosd(precone_deg);
R = TipRad_axis*cosd(precone_deg);
Rhub = HubRad_axis*cosd(precone_deg);

fprintf('\n============================================================\n');
fprintf(' EROSHIELD-15 - LITERATURE-CALIBRATED SCREENING V2\n');
fprintf('============================================================\n');
fprintf('Physical shield BlSpn       : %.6f to %.6f m\n',shield_start,shield_end);
fprintf('Physical protected length   : %.6f m\n',shield_end-shield_start);
fprintf('Projected BEM tip radius    : %.6f m\n\n',R);

%% Cases
names = {'Clean';'Erosion_A1';'Erosion_A2';'Erosion_B3'; ...
         'LEP_Tape_Analogue';'LEP_Chamfer_Analogue';'LEP_Step_Analogue'};
ncase = numel(names);

dCl_abs = [0;-0.07;-0.12;-0.14;0;0;0];
Cd_mult = [1;1.06;1.80;3.00;1.10;1.177;1.376];
Cl_mult = [1;1;1;1;1.000;0.979;0.957];

window_names = {'Nominal';'Wide';'Narrow'};
window_def = [0 4 9 13; 0 3 10 14; 3 6 7 10];
nwindow = rows(window_def);

%% Load station-specific public IEA polars
alpha_station = cell(nsta,1);
Cl_station = cell(nsta,1);
Cd_station = cell(nsta,1);

cache_dir = fullfile(script_dir,'IEA15_polars_cache');
if exist(cache_dir,'dir') ~= 7, mkdir(cache_dir); end

base_url = ['https://raw.githubusercontent.com/IEAWindSystems/' ...
            'IEA-15-240-RWT/v1.1.17/OpenFAST/IEA-15-240-RWT/Airfoils/'];

fprintf('Station-specific polar import\n');
fprintf('------------------------------------------------------------\n');

for j = 1:nsta
    name = sprintf('IEA-15-240-RWT_AeroDyn15_Polar_%02d.dat',polar_suffix(j));
    path = fullfile(cache_dir,name);

    if exist(path,'file') ~= 2
        url = [base_url name];
        [~,ok,msg] = urlwrite(url,path);
        if ~ok, error('Could not download %s: %s',name,msg); end
    end

    [alpha_station{j},Cl_station{j},Cd_station{j}] = read_polar(path);
    fprintf('BlAFID %2d -> Polar_%02d : %d points\n',afid(j),polar_suffix(j),numel(alpha_station{j}));
end

%% Storage
Pseg = zeros(nwindow,ncase);
Ptotal = zeros(nwindow,ncase);

AoA = NaN(nwindow,ncase,nsta);
Aind = NaN(nwindow,ncase,nsta);
APind = NaN(nwindow,ncase,nsta);
Iter = zeros(nwindow,ncase,nsta);
Conv = false(nwindow,ncase,nsta);
ClipA = false(nwindow,ncase,nsta);
ClipAP = false(nwindow,ncase,nsta);
Re = NaN(nwindow,ncase,nsta);

%% Solve
for iw = 1:nwindow
    fprintf('\nSolving AoA window: %-8s [%g %g %g %g] deg\n', ...
        window_names{iw},window_def(iw,:));

    for k = 1:ncase
        Ft = zeros(nsta,1);

        for j = 1:nsta
            a = 0.30; ap = 0.01;
            sigma = B*chord(j)/(2*pi*r(j));
            converged = false;
            clip_a = false; clip_ap = false;

            for it = 1:max_iter
                Vax = V0*(1-a);
                Vtan = omega*r(j)*(1+ap);
                phi = atan2(Vax,Vtan);
                aoa = phi*180/pi - (twist(j)+pitch);

                cl0 = interp1(alpha_station{j},Cl_station{j},aoa,'linear');
                cd0 = interp1(alpha_station{j},Cd_station{j},aoa,'linear');
                if ~isfinite(cl0) || ~isfinite(cd0), error('Polar interpolation failed.'); end

                w = aoa_weight(aoa,window_def(iw,:));
                [cl,cd] = apply_case(cl0,cd0,w,k,dCl_abs,Cl_mult,Cd_mult);

                Cn = cl*cos(phi) + cd*sin(phi);
                Ct = cl*sin(phi) - cd*cos(phi);

                sinphi = max(abs(sin(phi)),1e-6);
                ftip = (B/2)*(R-r(j))/(r(j)*sinphi);
                fhub = (B/2)*(r(j)-Rhub)/(Rhub*sinphi);
                Ftip = (2/pi)*acos(exp(-max(ftip,0)));
                Fhub = (2/pi)*acos(exp(-max(fhub,0)));
                F = max(Ftip*Fhub,F_min);

                a_raw = 1/(1 + (4*F*sin(phi)^2)/max(sigma*Cn,1e-8));
                denom_ap = (4*F*sin(phi)*cos(phi))/max(sigma*Ct,1e-8) - 1;
                if abs(denom_ap) > 1e-8, ap_raw = 1/denom_ap; else, ap_raw = ap; end

                clip_a = clip_a || a_raw<a_min || a_raw>a_max;
                clip_ap = clip_ap || ap_raw<ap_min || ap_raw>ap_max;

                a_new = min(max(a_raw,a_min),a_max);
                ap_new = min(max(ap_raw,ap_min),ap_max);

                an = (1-relax)*a + relax*a_new;
                apn = (1-relax)*ap + relax*ap_new;

                if abs(an-a)<tol && abs(apn-ap)<tol
                    a=an; ap=apn; converged=true; break;
                end
                a=an; ap=apn;
            end

            Vax = V0*(1-a);
            Vtan = omega*r(j)*(1+ap);
            W = hypot(Vax,Vtan);
            phi = atan2(Vax,Vtan);
            aoa = phi*180/pi - (twist(j)+pitch);

            cl0 = interp1(alpha_station{j},Cl_station{j},aoa,'linear');
            cd0 = interp1(alpha_station{j},Cd_station{j},aoa,'linear');
            w = aoa_weight(aoa,window_def(iw,:));
            [cl,cd] = apply_case(cl0,cd0,w,k,dCl_abs,Cl_mult,Cd_mult);

            Ct = cl*sin(phi)-cd*cos(phi);
            Ft(j) = 0.5*rho*W^2*chord(j)*Ct;

            AoA(iw,k,j)=aoa; Aind(iw,k,j)=a; APind(iw,k,j)=ap;
            Iter(iw,k,j)=it; Conv(iw,k,j)=converged;
            ClipA(iw,k,j)=clip_a; ClipAP(iw,k,j)=clip_ap;
            Re(iw,k,j)=W*chord(j)/nu_air;
        end

        pdens = B*omega.*r.*Ft; % W per physical-span metre
        sw = linspace(shield_start,shield_end,300)';
        pdens_i = interp1(blspn,pdens,sw,'linear');
        Pseg(iw,k) = trapz(sw,pdens_i);
    end

    Ptotal(iw,:) = P_clean_reference_W + (Pseg(iw,:) - Pseg(iw,1));
end

%% Audit
fprintf('\n============================================================\n');
fprintf(' NUMERICAL AUDIT SUMMARY\n');
fprintf('============================================================\n');
fprintf('Converged solutions          : %d / %d\n',nnz(Conv),numel(Conv));
fprintf('Axial-induction clip flags   : %d\n',nnz(ClipA));
fprintf('Tangential clip flags        : %d\n',nnz(ClipAP));
fprintf('Maximum iterations used      : %d / %d\n',max(Iter(:)),max_iter);

%% Nominal results
inom = 1;
fprintf('\n============================================================\n');
fprintf(' NOMINAL AoA-WINDOW RATED-POINT RESULTS\n');
fprintf('============================================================\n');
fprintf('%-24s %12s %14s\n','Case','Power [MW]','Delta clean [kW]');
for k=1:ncase
    fprintf('%-24s %12.6f %14.3f\n',names{k},Ptotal(inom,k)/1e6, ...
        (Ptotal(inom,k)-Ptotal(inom,1))/1000);
end

fprintf('\nNominal clean-case station AoA [deg]\n');
disp(squeeze(AoA(inom,1,:))');
fprintf('Nominal clean-case station Reynolds numbers\n');
disp(squeeze(Re(inom,1,:))');

fprintf('\nNet rated-point benefit: protected vs eroded\n');
fprintf('%-12s %-22s %12s %12s\n','Erosion','LEP analogue','Benefit kW','Recovery %');
for e=2:4
    for p=5:7
        loss=Ptotal(inom,1)-Ptotal(inom,e);
        benefit=Ptotal(inom,p)-Ptotal(inom,e);
        rec=100*benefit/loss;
        fprintf('%-12s %-22s %12.2f %12.2f\n',names{e},names{p},benefit/1000,rec);
    end
end

%% Export compact reproducibility results
summary_file=fullfile(script_dir,'EROSHIELD15_literature_v2_summary.csv');
fid=fopen(summary_file,'w');
fprintf(fid,'AoA_window,Case,Power_MW,Delta_from_clean_kW\n');
for iw=1:nwindow
    for k=1:ncase
        fprintf(fid,'%s,%s,%.9f,%.6f\n',window_names{iw},names{k}, ...
            Ptotal(iw,k)/1e6,(Ptotal(iw,k)-Ptotal(iw,1))/1000);
    end
end
fclose(fid);

diag_file=fullfile(script_dir,'EROSHIELD15_literature_v2_diagnostics.csv');
fid=fopen(diag_file,'w');
fprintf(fid,'AoA_window,Case,BlAFID,BlSpn_m,Radius_m,AoA_deg,a,ap,Iterations,Converged,AxialClipped,TangentialClipped,Re\n');
for iw=1:nwindow
 for k=1:ncase
  for j=1:nsta
   fprintf(fid,'%s,%s,%d,%.9f,%.9f,%.9f,%.9f,%.9f,%d,%d,%d,%d,%.6f\n', ...
    window_names{iw},names{k},afid(j),blspn(j),r(j),AoA(iw,k,j), ...
    Aind(iw,k,j),APind(iw,k,j),Iter(iw,k,j),Conv(iw,k,j), ...
    ClipA(iw,k,j),ClipAP(iw,k,j),Re(iw,k,j));
  end
 end
end
fclose(fid);

fprintf('\nIMPORTANT LIMITATIONS\n');
fprintf('1. Erosion anchors are transferred from a different airfoil/Re.\n');
fprintf('2. LEP branches are analogue geometries, not 2 mm EROSHIELD data.\n');
fprintf('3. AoA weighting windows are engineering model-form assumptions.\n');
fprintf('4. Healthy LEP states represent prevention / clean+LEP, not repair.\n');
fprintf('5. Results are rated-point differential screening, not AEP.\n');
fprintf('6. BEM uses bounded induction without a high-induction correction.\n');

end

function [alpha,Cl,Cd] = read_polar(path)
fid=fopen(path,'r');
if fid<0, error('Cannot open %s',path); end
n=0;
while ~feof(fid)
    line=fgetl(fid);
    if ischar(line) && ~isempty(strfind(line,'NumAlf'))
        parts=strsplit(strtrim(line)); n=str2double(parts{1});
        fgetl(fid); fgetl(fid); break;
    end
end
if n<=0, fclose(fid); error('NumAlf not found in %s',path); end
d=fscanf(fid,'%f %f %f %f',[4 n])'; fclose(fid);
alpha=d(:,1); Cl=d(:,2); Cd=d(:,3);
end

function w=aoa_weight(a,v)
a0=v(1); a1=v(2); a2=v(3); a3=v(4);
if a<=a0 || a>=a3
    w=0;
elseif a<a1
    t=(a-a0)/(a1-a0); w=t^2*(3-2*t);
elseif a<=a2
    w=1;
else
    t=(a3-a)/(a3-a2); w=t^2*(3-2*t);
end
w=min(max(w,0),1);
end

function [cl,cd]=apply_case(cl0,cd0,w,k,dCl_abs,Cl_mult,Cd_mult)
if k==1
    cl=cl0; cd=cd0;
elseif k<=4
    cl=cl0+dCl_abs(k)*w;
    cd=cd0*(1+(Cd_mult(k)-1)*w);
else
    cl=cl0*(1+(Cl_mult(k)-1)*w);
    cd=cd0*(1+(Cd_mult(k)-1)*w);
end
end

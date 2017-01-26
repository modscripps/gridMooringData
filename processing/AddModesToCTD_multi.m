function CTD = AddModesToCTD_multi(CTD, FP)
%function CTD = AddModesToCTD_multi(CTD, FP)
%   computates modal structures from CTD.z and CTD.n2
%
%   Its difference from AddModesToCTD.m is that:
%       it calculate modes using variable n2, so that 
%       a series of modal structures are calculated, 
%       depending on the number of columns of n2.
%       
%   INPUT:
%      CTD structure
%        CTD.n2         (m, n) VB frequency
%        CTD.lat        (n)/(1)latitude
%        CTD.z          (m) meter (dbar)
% 
%      FP parameters
%        FP.Nmode       number of modes calculated (default: 10)
%        FP.Ngrid       number of grids during modal decomposition
%                       (default, 200)
%        FP.z_full:     z grid (may be different from CTD.z) saved in the
%                       resultant modal structures (default: CTD.z)
%
%        FP.good_percent:    in each column, if n2 has too much nan,
%                            then, no modal decomposition will be done.
%                            good data > good_percent (default: 80%)
%
%   OUTPUT:
%       CTD.para_mode     para parameters
%       CTD.z_full        z for modes
%       CTD.vert_full     vertical structures
%       CTD.hori_full     horizontal structures
%                         where '_full' may be different from CTD.z
% 
% See also AddModesToCTD, AddModeToMMP
%
% ZZ @ APL-UW, April 28th, 2011


%% (0) display function name
disp( ['Calling function ' mfilename])


%% (1) check FP and its parameters
% FP
if ~exist('FP', 'var' )
    FP = struct;
end
% FP.Nmode
if ~isfield( FP, 'Nmode')
    FP.Nmode = 10; %number of modes
end
% FP.Ngrid
if ~isfield( FP, 'Ngrid')
    FP.Ngrid = 200; %number of modes
end
% FP.z_full
if ~isfield( FP, 'z_full' )
    FP.z_full = CTD.z;
end
% FP.percent_good
if ~isfield( FP, 'good_percent' )
    FP.good_percent = 0.8;
end
% save FP
CTD.para_vmode = FP;


%% check dimensions
m = length(FP.z_full);  %saved z_full length
n = FP.Nmode;
k = size(CTD.n2, 2);

%% initialize data
CTD.z_full    = FP.z_full(:);
CTD.n2_full   = nan(m, k);
CTD.vert_full = nan(m, n, k);
CTD.hori_full = nan(m, n, k);
CTD.ce    = nan(n, k);
CTD.ce_bt = nan(1, k);

warning off
%% (2) for each column of n2(:,idx), calling AddModesToCTD
for id = 1 : size(CTD.n2, 2)
    id;
    
    %% DATA from CTD
    z    = CTD.z;
    n2   = CTD.n2(:,id);
    if length(CTD.lat) == size(CTD.n2,2)
        lat  = CTD.lat(id);
    else
        lat  = CTD.lat;
    end    
    
    idx_gd = find( ~isnan(n2) );
    if length(idx_gd) >= length(n2) * FP.good_percent
        %% fill upper/lower nan data with good data
        %% upper layer, linear to zeros
        igda = idx_gd(1);
        if igda > 1
            n2(1:igda) = interp1([1 igda], [0 n2(igda)], 1:igda);
        end
        %% lower layer
        igdb = idx_gd(end);
        n2(igdb:end) = n2(igdb);
        %% nan in the middle, linear interpolate
        igd = find( ~isnan(n2) );
        n2 = interp1( z(igd), n2(igd), z);

        %% square root
        n = sqrt( n2 );

        %% save n2
        CTD.n2_full(:, id)  = interp1(z, n2, CTD.z_full);

        %% re-sample on new FP.Ngrid (200-point vertical) grid (to reduce calculation time)
        z_grid = linspace( z(1), z(end), FP.Ngrid); z_grid = z_grid(:);
        n_grid = interp1( z, n, z_grid);

        %% check n_grid for 0
        idx_zero = 1;
        while idx_zero<length(n_grid) & n_grid(idx_zero) == 0
            idx_zero = idx_zero+1; 
        end
        if idx_zero<length(n_grid)
            n_grid( 1:idx_zero-1) = n_grid(idx_zero)/5;
        end
        
        %% calling sw_vmodes
        [Vert, Hori, Edep, PVel] = sw_vmodes(z_grid, n_grid, lat, FP.Nmode+1);

        %% re-sample back to z_full grid
        CTD.vert_full(:,:,id) = interp1( z_grid, Vert(:, 2:end), CTD.z_full );
        CTD.hori_full(:,:,id) = interp1( z_grid, Hori(:, 2:end), CTD.z_full );

        %MHA change 10/1/2010: add mode speeds to calculation
        CTD.ce(:,id) = PVel(2:end);
        CTD.ce_bt(id)= PVel(1);
    end
end


%% calculate group/phase speed
% local near-inertial frequency f
f = 2*sin(CTD.lat*pi/180) / (24*3600); %1/second
% tidal frequency omega
if strcmp( upper(CTD.FreqBand), 'SEMI' ) | ...
       strcmp( upper(CTD.FreqBand), 'SEMIDIURNSL' )
   omega = 1/12.42/3600; %(M2+S2)/2
elseif strcmp( upper(CTD.FreqBand), 'M2')
   omega = 1/12.42/3600;
elseif strcmp( upper(CTD.FreqBand), 'S2')
   omega = 1/12/3600;
elseif strcmp( upper(CTD.FreqBand), 'DIURNAL')
   omega = 1/24/3600;
elseif strcmp( upper(CTD.FreqBand), 'O1')
   omega = 1/25.82/3600;   
elseif strcmp( upper(CTD.FreqBand), 'K1')
   omega = 1/23.93/3600;      
elseif strcmp( upper(CTD.FreqBand), 'NI') | ...
   strcmp( upper(CTD.FreqBand), 'NEAR INERTIAL')
   omega = 1.05*f;
end

%%
CTD.cp = omega / sqrt(omega^2-f^2) * CTD.ce;
CTD.cg = sqrt(omega^2-f^2) / omega * CTD.ce;
CTD.WLen = CTD.cp/ omega;


%% squeeze them 
CTD.vert_full = squeeze(CTD.vert_full);
CTD.hori_full = squeeze(CTD.hori_full);

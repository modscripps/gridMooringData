function MMP = AddModeToMMP( MMP, FP)
%function MMP = AddModeToMMP( MMP, FP)
%   computates modal structures from MMP.z and MMP.n2
%   
%   Input:
%     MMP structure
%       MMP.n2         VB frequency
%       MMP.z          m (dbar)
% 
%     FP parameters
%       FP.Nmode       how many modes are calculated
%       FP.z_full:     z grid (can be different from MMP.z)
%
%   Output:
%       MMP.para_mode     para parameters
%       MMP.z_full           z for modes
%       MMP.vert_full        vertical structures
%       MMP.hori_full        horizontal structures
%           where '_full' may be different from MMP.z
% 
% See also PlotModeFit 
%
% ZZ @ APL-UW, March 23rd, 2010
% ZZ @ APL-UW, April 30st, 2010


%% display
disp( ['Calling function ' mfilename])


%% check FP and its parameters
%% FP
if ~exist('FP', 'var' )
    FP = struct;
end

%% FP.window
if ~isfield( FP, 'Nmode')
    FP.Nmode = 20; %number of modes
end

%% FP.z_full
if ~isfield( FP, 'z_full' )
    FP.z_full = MMP.z;
end


%% save FP
MMP.para_vmode = FP;


%% DATA
z    = MMP.z;
lat  = nanmean( MMP.lat );
n2   = nanmean(MMP.n2, 2);


%% fill upper/lower nan data with good data
idx_gd = find( ~isnan(n2) );
if length( idx_gd ) > 5
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
    n2 = interp1( MMP.z(igd), n2(igd), MMP.z);
end
%% square root
n = sqrt( n2 );


%% save some results
MMP.z_full    = FP.z_full(:);
MMP.n2_full   = interp1( z, n2, MMP.z_full );


%% re-sample on new 500-point vertical grid (to reduce calculation time)
z_grid = linspace( z(1), z(end), 500); z_grid = z_grid(:);
n_grid = interp1( z, n, z_grid);


%% calling sw_vmodes
[Vert, Hori, Edep, PVel] = sw_vmodes(z_grid, n_grid, lat, FP.Nmode+1);


%% re-sample back to z_full grid
MMP.vert_full = interp1( z_grid, Vert(:, 2:end), MMP.z_full );
MMP.hori_full = interp1( z_grid, Hori(:, 2:end), MMP.z_full );

%MHA change 10/1/2010: add mode speeds to calculation
MMP.ce = PVel(2:end);
MMP.ce_bt = PVel(1);

return
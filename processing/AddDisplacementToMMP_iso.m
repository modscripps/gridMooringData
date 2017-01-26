function MMP = AddDisplacementToMMP_iso( MMP, FP )
%function MMP = AddDisplacementToMMP_iso( MMP, FP )
%   calculates the vertical displacement from MMP.(FP.varname)
%
%   Input:
%       MMP: standard MMP structure, gridded yday/z- data
%       FP: parametes
%          FP.time:     yday (default)
%          FP.varname:  t or sgth (sgth default)
%          FP.window:   nan days (no window defaut)
%
%   Output:
%       MMP.eta:                 vertical displacement
%       MMP.para_eta:            parameter       
%       MMP.iso_varname:         iso-FP.varname locations
%       MMP.iso_varname_smooth:  window-smoothed iso
%       MMP.iso_varname_vals:    values of iso

% see also AddDisplacementToMMP_grad
%
% ZZ @ APL-UW, March 8th, 2010
% ZZ @ APL-UW, March 16th, 2010
% ZZ @ APL-UW, April 29th, 2010
% ZZ @ APL-UW, May 17th, 2011
% ZZ @ APL-UW, June 30th, 2011

%%
disp(['Calling function ' mfilename ])

%% check FP and its parameters
% FP
if ~exist( 'FP', 'var') 
    FP = struct; 
end
% FP.varname
if ~isfield( FP, 'varname' )
    FP.varname = 'sgth'; % density 
end
% FP.time
if ~isfield( FP, 'time' )
    FP.time = 'yday';    % 'yday' 
end
% FP.window
if ~isfield( FP, 'window' )
    FP.window = nan;     % days
end

%% method used by this program
FP.method = 'iso-contour';

%% start to work
warning off

%% load data from MMP
DATA  = MMP.(FP.varname);
yday  = MMP.(FP.time);
z     = MMP.z;

%% check the range of data, and create a linear series
DATAmin  = nanmin( nanmin(DATA) );
DATAmax  = nanmax( nanmax(DATA) );
vals     = linspace(DATAmin, DATAmax, length(z));
% using vals input from FP
if isfield(FP, 'vals')
   vals = FP.vals; 
end


%% calculate iso-data contours
iso = nan(length(vals), length(yday) );
for idx = 1 : length(yday)
    data = DATA(:, idx);
    igd  = find( ~isnan(data) );
    if length(igd) > 3
        iso(:, idx) = interp1( data(igd), z(igd), vals);
    end
end

%% smoothing Iso using FP.window
if ~isnan(FP.window)
    % case 1: using window
    smooth = nan( size(iso) );
    for idx = 1 : length(yday)
        yday0 = yday(idx);
        igd = find( abs(yday-yday0)<=FP.window/2 );
        smooth(:, idx) = nanmean( iso(:, igd), 2);
    end
else 
    % case 2: not using window, all together
    iso_mean = nanmean(iso, 2);
    smooth = iso_mean * ones( size(yday) );
end

%% calculate eta from Iso and Iso_smooth
eta = -(iso - smooth); %note the minus sign 

new = nan(length(z), length(yday));
%% project eta from varname-coordinates to z-coordinates
for idx = 1 : length(yday)
%    idx
    data = eta(:, idx);
    diso = iso(:, idx);
    igd  = find( ~isnan(diso)&~isnan(data) );
    
    if length(igd) > 3
        new(:, idx) = interp1(diso(igd), data(igd), z);
    end
end
eta = new;

%% save parameters
% remove old values
fnames = {'eta'; 'para_eta'; ['iso_' FP.varname]; ...
          ['iso_' FP.varname '_smooth']; ['iso_' FP.varname '_vals']};
for id = 1 : length(fnames)
    fname = fnames{id};
    if isfield(MMP, fname)
        MMP = rmfield(MMP, fname);
    end
end

% save new values
MMP.eta      = eta;
MMP.para_eta = FP;
MMP.(['iso_' FP.varname]) = iso;
MMP.(['iso_' FP.varname '_smooth']) = smooth;
MMP.(['iso_' FP.varname '_vals'])   = vals;

%%
warning on

%% 
FP.VarNameList = {'eta'};
FP.where = 'top-bottom-middle';    
FP.BottomMean = 1;
FP.good_percent = 0.4;
MMP = ReplaceNanInMMP( MMP, FP );
MMP.eta( isnan(MMP.(FP.varname)) ) = nan;

return
function MMP = AddDisplacementToMMP_grad( MMP, FP )
%function MMP = AddDisplacementToMMP_grad( MMP, FP )
%   calculate the vertical displacement from MMP.(FP.varname)
%   MMP.(FP.time):     yday (default)
%   MMP.(FP.varname):  data used (t or sgth), sgth default
%   FP.window:         whole-time days (defaut)
%
%   Output:
%       MMP.eta:       vertical displacement
%       MMP.para_eta:  parameter
%       MMP.*MEAN:     spatially-average 
%       MMP.*GRAD:     vertical difference 
%
%   NOTE: !!!!!!
%       In this program, the eta is calculated using 
%       vertical gradient. Real data shows that eta is
%       very senstive to spikes (or bad data) in the raw sgth data.
%       It is strongly suggested that spikes are removed 
%       before running this program.
%
%   NOTE: !!!!!!
%       In some cases, the time-series data has strong time variations
%       Thus, the calculation is conducted in small window
%       which is given by FP.window, its default value is for 
%       all data (no smaller window)
%       
%   See also AddDisplacementToMMP_iso
%
% ZZ @ APL-UW, March 8th, 2010
% ZZ @ APL-UW, March 16th, 2010
% ZZ @ APL-UW, June 11th, 2010
% ZZ @ APL-UW, June 30th, 2011


%%
disp(['Calling function ' mfilename ])
    

%% check FP and its parameters
% FP
if ~exist( 'FP', 'var') 
    FP = struct; 
end
% FP.time
if ~isfield( FP, 'time' )
    FP.time = 'yday';    % yday
end
% FP.varname
if ~isfield( FP, 'varname' )
    FP.varname = 'sgth'; % density 
end
% FP.window
if ~isfield( FP, 'window' )
    FP.window = nan;     % days
end
% FP.vsmooth
if ~isfield( FP, 'vsmooth' )
    FP.vsmooth = 6;      % layers (not days)
end
% FP.hsmooth
if ~isfield( FP, 'hsmooth' )
    FP.hsmooth = 6;      % columns (not days)
end


%% start to work
warning off


%% DATA and parameters
DATA  = MMP.(FP.varname);
yday  = MMP.(FP.time);
z     = MMP.z;
dz    = nanmean( diff(z) );

%% smoothing DATA using FP.window
if ~isnan(FP.window)
    % case 1: using window
    MEAN = nan( size(DATA) );
    for idx = 1 : length(yday)
        yday0 = yday(idx);
        igd = find( abs(yday-yday0)<=FP.window/2 );
        MEAN(:, idx) = nanmean( DATA(:, igd), 2);
    end
else 
    % case 2: not using window, all together
    DATA_mean = nanmean(DATA, 2);
    MEAN = DATA_mean * ones( size(yday) );
end

% %% smoothing GRAD
% Fv = FP.vsmooth;  %
% Fh = FP.hsmooth;
% MEAN = nanmoving_average2(MEAN, Fv, Fh, 0);

%% gradient of MEAN
GRAD = diffs( MEAN, 1) / dz;
if strcmp( lower(FP.varname), 'sgth' )
    GRAD( GRAD<0 ) = nan;
elseif strcmp( lower(FP.varname), 't' )
    GRAD( GRAD>0 ) = nan;
end


%% calculate perturbations with respect to MEAN
% difference DIFF
DIFF = DATA - MEAN;
% eta
eta  = DIFF ./ GRAD;


%% save
MMP.eta      = eta;
FP.method = 'gradient';
MMP.para_eta = FP;
MMP.([FP.varname 'MEAN'])  = MEAN;
MMP.([FP.varname 'GRAD'])  = GRAD;

%%
warning on
return
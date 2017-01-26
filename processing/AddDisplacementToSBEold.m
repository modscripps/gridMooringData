function SBE = AddDisplacementToSBE( SBE, FP )
%function SBE = AddDisplacementToSBE( SBE, FP )
%   calculate the vertical displacement from SBE.(FP.varname)
%   SBE.(FP.time):     yday (default)
%   SBE.(FP.varname):  data used, (t, default)
%   FP.window:         5 days (defaut)
%
%   Output:
%       SBE.para_eta:  parameter       
%       SBE.tDIFF:     removing low-pass filtered DATA over FP.window 
%       SBE.eta:       vertical displacement
%
% ZZ @ APL-UW, April 30th, 2010


%%
disp(['Calling function ' mfilename ])
    

%% check FP and its parameters
%% FP
if ~exist( 'FP', 'var') 
    FP = struct; 
end

%% FP.time
if ~isfield( FP, 'time' )
    FP.time = 'yday'; % time-series is 'yday' 
end

%% FP.varname
if ~isfield( FP, 'varname' )
    FP.varname = 't'; % density 
end

%% FP.window
if ~isfield( FP, 'window' )
    yday = SBE.(FP.time);
    FP.window = nanmax(yday)-nanmin(yday);    % default
end

%% FP.dtdz (if FP.varname = 't')
if ~isfield( FP, 'dtdz' )
    FP.dtdz = nan;  % default
end


%% save parameters
SBE.(['para_eta']) = FP;


%% 
DATA = SBE.(FP.varname);
yday = SBE.(FP.time);
Len_yday = nanmax(yday)-nanmin(yday);

%% using function nanmoving_average2
%% to do the smoothing
% number of points of time-average
if FP.window < Len_yday
    DATA  = SBE.(FP.varname);
    NumOfPrf   = round( FP.window / nanmean( diff(yday) ) );
    Fr = NumOfPrf/2;      %half window length
    [MEAN, A] = nanmoving_average(DATA, Fr, 2, 0);  
end

%% Method 3:
%% using the mean from all profiles
if FP.window >= Len_yday
    DATA = SBE.(FP.varname);
    MEAN = nanmean( DATA, 2 );
    MEAN = repmat( MEAN, 1, length(yday) );
end


%%
tDiff = DATA - MEAN;


%% calculate perturbations
SBE.dtdz = interp1(FP.yday, FP.dtdz, SBE.yday);
SBE.([FP.varname 'DIFF'])  = tDiff;
SBE.eta = SBE.([FP.varname 'DIFF']) ./ SBE.dtdz;


%% check the results
% figure(9),  clf, hold on
% plot( yday, DATA, 'b', 'linewidth', 1.2)
% plot( yday, tDiff, 'r', 'linewidth', 1.2)
% plot( yday, DATA-tDiff, 'g', 'linewidth', 1.5)

return;
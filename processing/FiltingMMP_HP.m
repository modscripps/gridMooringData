function MMP = FiltingMMP_HP(MMP, FP)
%function MMP = FiltingMMP_HP(MMP, FP)
%   buttorworth filter on MMP.(FP.VarNames)
%
% see also DoHarmonicToMMP, filtfilt, myfiltfilt
%
% ZZ 08/17/2006 @ APL-UW
% ZZ 03/17/2010 @ APL-UW
% ZZ 06/10/2010 @ APL-UW


%% display
disp(['Calling function ' mfilename ])


%% check FP and its parameters
%% FP
if ~exist('FP', 'var')
    FP = struct;
end
%% FP.CentralFreq
if ~isfield(FP, 'CentralFreq' )
    FP.CentralFreq  = 24/8;  %3 cycles per day 
end
%% FP.RefTime
if ~isfield(FP, 'RefTime')
    FP.RefTime = 'yday';  %refrence time 
end
%% FP.VarNames
if ~isfield(FP, 'VarNames')
    FP.VarNames = {'u'; 'v'};
end
%% FP.order
if ~isfield(FP, 'order')
    FP.order = 4;
end

%% save the filter parameter 
MMP.para_filter = FP;

%% Form the filter parameters: a, b
FP.samplefreq  = 1 / nanmean(diff(MMP.(FP.RefTime)));
fn             = FP.samplefreq/2;    %nyquist
fcut           = FP.CentralFreq;
[b, a]         = butter(FP.order, fcut/fn, 'high');

%% loop for filtering
for idx_var = 1 : length(FP.VarNames)
    varname = FP.VarNames{idx_var};
    disp(['   DoFiltingToMMP is working on ' varname])

    %% temporal result
    TEMP  = nan( size( MMP.(varname) ) );
    
    %% loop on depth layers
    for iz = 1 : length(MMP.z)
        TEMP(iz, :) = myfiltfilt( b, a, MMP.(varname)(iz, :) );
    end

    %% save result back, overwrite the old data
    MMP.(varname) = TEMP;
end

return
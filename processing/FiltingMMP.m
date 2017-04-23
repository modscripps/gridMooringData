function MMP = FiltingMMP(MMP, FP)
%function MMP = FiltingMMP(MMP, FP)
%   buttorworth filter on MMP.(FP.VarNames)
%
% see also DoHarmonicToMMP, filtfilt, myfiltfilt
%
% ZZ @ APL-UW 08/17/2006 
% ZZ @ APL-UW 03/17/2010 
% ZZ @ APL-UW 05/17/2011 

%% display
disp(['Calling function ' mfilename ])

%% check FP and its parameters
%% FP
if ~exist('FP', 'var')
    FP = struct;
end
%% FP.CentralFreq
if ~isfield(FP, 'CentralFreq' )
    FP.CentralFreq  = 24/12.42; %M2
end
%% FP.bandwidth
if ~isfield(FP, 'bandwidth')
    FP.bandwidth = 0.3;  %bandwidth of the filter
end
%% FP.RefTime
if ~isfield(FP, 'RefTime')
    FP.RefTime = 'yday';  %refrence time 
end
%% FP.VarNameList
if ~isfield(FP, 'VarNameList')
    FP.VarNameList = {'u'; 'v'; 'eta'};
end
%% FP.order
if ~isfield(FP, 'order')
    FP.order = 4;
end

%% save the filter parameter 
MMP.para_filter = FP;

%% Form the filter parameters: a, b
FP.samplefreq  = 1 / nanmedian(diff(MMP.(FP.RefTime)));
fn             = FP.samplefreq/2;    %nyquist
fc1            = FP.CentralFreq*(1-FP.bandwidth/2);
fc2            = FP.CentralFreq*(1+FP.bandwidth/2);
[b, a]         = butter(FP.order, [fc1/fn fc2/fn]);

%% loop for filtering
for idx_var = 1 : length(FP.VarNameList)
    varname = FP.VarNameList{idx_var};
    disp(['   DoFiltingToMMP is working on ' varname])

    %% temporal result
    TEMP  = nan( size( MMP.(varname) ) );
    
    %% loop on depth layers
    for iz = 1 : length(MMP.z)
       TEMP(iz, :) = filtfiltZZ(b, a, MMP.(varname)(iz, :));        
    end

    %% save result back, overwrite the old data
    MMP.(varname) = TEMP;
end

return
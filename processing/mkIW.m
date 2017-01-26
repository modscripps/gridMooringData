function IW = mkIW( MMP, FP )
%function IW = mkIW( MMP, FP )
%   creastes a data structer IW, which 
%   has some basic common data fields
%   
%   Some data fields are from MMP
%   Some data fields are from FP
%
% see also mkMooring, mkMMP, DoHarmonicToMMP, FiltingMMP
%
% ZZ @ APL-UW, April 15th, 2010
% ZZ @ APL-UW, May 16th, 2011


%% display
disp(['Calling function ' mfilename])

%% check MMP
if ~exist( 'MMP', 'var' )
    clear IW, IW = struct; return
end

%% create FP
if ~exist( 'FP', 'var' )
    FP = struct;
end
%% buoyancy frequency
if ~isfield( FP, 'BuoyancyFreq' )
    FP.BuoyancyFreq = 'n2mean';
end
%% Frequency band
if ~isfield( FP, 'FreqBand' )
    FP.FreqBand = 'SEMI';     % 'DIURNAL', 'M2', 'S2', 'NI'
end
FP.FreqBand = upper( FP.FreqBand ); %uppercase

%% bandwidth
if ~isfield( FP, 'bandwidth' )
    FP.bandwidth = 0.2;
end
%% bandwidth
if ~isfield( FP, 'label' )
    FP.label = '';
end

%% create IW
clear IW; IW = struct;

%% Initialize IW's data fields
InfoNames = {'Project' 'SN'}; 
for idx = 1 : length(InfoNames)
     name = InfoNames{idx};
     IW.(name)  = 'unknown';
end

%% Initialize IW's data fields
VarNames = {'lon'  'lat'  'year' 'depth' 'yday' 'z' 'u' 'v' ...
            'eta'  'sgth'  'n2'  'CTD' 't'};
for idx = 1 : length(VarNames)
     name = VarNames{idx};
     IW.(name)  = nan;
end

%% updating IW from MMP
AllNames = [InfoNames VarNames];
for idx = 1 : length(AllNames)
   name = AllNames{idx};
   if isfield( MMP, name) 
       IW.(name) = MMP.(name);
   else
       IW.(name) = nan(length(IW.z), length(IW.yday)); 
   end
end

%% more information
InfoNames = {'UID' 'FreqBand'  'period' 'CentralFreq' 'bandwidth' ...
             'BuoyancyFreq'};
for idx = 1 : length(InfoNames)
     name = InfoNames{idx};
     IW.(name)  = 'unknown';
end


%% check n2 or n2mean
%% if BuoyancyFreq is n2mean, replacing n2 using its time-mean
if strcmp( FP.BuoyancyFreq, 'n2mean')
    IW.n2 = nanmean(IW.n2, 2);
    IW.CTD.n2 = nanmean(IW.CTD.n2, 2);
end

%% updating IW from FP
for idx = 1 : length(InfoNames)
   name = InfoNames{idx};
   if isfield( FP, name) 
       IW.(name) = FP.(name);
   end
end


%% update central frequency and period from IW.FreqBand
if strcmp( 'SEMI', IW.FreqBand)
    IW.CentralFreq  = 24 / 12.4;
elseif strcmp( 'DIURNAL', IW.FreqBand)
    IW.CentralFreq = 24 / 24;  
elseif strcmp( 'NI',  IW.FreqBand )
    IW.CentralFreq = 2*sin(IW.lat/180*pi);    
elseif strcmp( 'M2', IW.FreqBand)
    IW.CentralFreq = 24 / 12.42;  
elseif strcmp( 'S2',  IW.FreqBand )
    IW.CentralFreq = 24 / 12;  
elseif strcmp( 'O1',  IW.FreqBand )
    IW.CentralFreq = 24 / 25.8;  
elseif strcmp( 'K1',  IW.FreqBand )
    IW.CentralFreq = 24 / 23.9;  
elseif strcmp( 'S1',  IW.FreqBand )
    IW.CentralFreq = 24 / 24;  
end    

%% update period 
IW.period  = 24 / IW.CentralFreq;

%% separate two cases
if strfind( 'SEMI-DIURNAL-NI', IW.FreqBand )
    FP.CentralFreq = IW.CentralFreq;
    FP.bandwidth   = IW.bandwidth;    
    IW = FiltingMMP(IW, FP);
end
if strfind( 'M2-S2-O1-K1-S1', IW.FreqBand ) 
    IW = DoHarmonicToMMP(IW, FP);
end

%% update IW.UID
if ~isempty(FP.label)
    IW.UID = ['IW-' IW.Project '-' IW.SN '-' FP.label '-' IW.FreqBand ...
                '-' IW.BuoyancyFreq];
else
    IW.UID = ['IW-' IW.Project '-' IW.SN '-' IW.FreqBand ...
                '-' IW.BuoyancyFreq];    
end

return
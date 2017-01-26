function Mooring = mkMooring( FP )
%function Mooring = mkMooring( FP )
%   creastes a data structer Mooring, which
%   has some basic parameters
%   
%   parameters are default or from FP
%
% see also mkMMP, mkIW, AddInstrumentToMooring
%
% ZZ @ APL-UW, April 15th, 2010


%% display
disp(['Calling function ' mfilename])

%% check FP
if ~exist( 'FP', 'var' )
    FP = struct;
end

%% create data struct Mooring
clear Mooring 
Mooring = struct;


%% setting Mooring's information I
InfoNames = {'Project' 'SN' 'UID'};
for idx = 1 : length(InfoNames)
     name = InfoNames{idx};
     Mooring.(name)  = 'unknown';
end


%% setting Mooring's information II
VarNames = {'lon'  'lat'  'year' 'depth'};
for idx = 1 : length(VarNames)
     name = VarNames{idx};
     Mooring.(name)  = nan;
end

%% updating Mooring from FP
AllNames = [InfoNames VarNames];
for idx = 1 : length(AllNames)
   name = AllNames{idx};
   if isfield( FP, name) 
       Mooring.(name) = FP.(name);
   end
end
Mooring.UID = ['Mooring-' Mooring.Project '-' Mooring.SN];


%% setting Mooring's instrument list
InstrumentList = {'MP' 'SBE' 'ADCP'};
Mooring.InstrumentList    = InstrumentList;
Mooring.InstrumentNumber  = zeros( size(InstrumentList) );

%% DataList
Mooring.DataList  = {};
Mooring.DataNumber = 0;

return
function MMP = mkMMP( Mooring, FP )
%function MMP = mkMMP( Mooring, FP )
%   creates a data structure MMP, which
%   has some basic common data fields
%
%   Some data fields are from Mooring
%   Some data fields are from FP
%   
% see also mkMooring, mkIW, AddDATAToMMP
%
% ZZ @ APL-UW, April 15th, 2010
% ZZ @ APL-UW, February 25th, 2011
% ZZ @ APL-UW, May 16th, 2011

%% display
disp(['Calling function ' mfilename])

%% if no Mooring, return with an empty MMP
if ~exist( 'Mooring', 'var' )
    clear MMP; MMP = struct; return
end

%% check Mooring
if ~exist( 'FP', 'var' )
    FP = struct;
end
%% FP.yday (or Mooring.yday_grid)
if ~isfield( FP, 'yday')
    FP.yday  = Mooring.yday_grid;
end
%% FP.z (or Mooring.z_grid)
if ~isfield( FP, 'z')
    FP.z     = Mooring.z_grid;
end
%% FP.label
if ~isfield( FP, 'label')
    FP.label  = '';
end

%% FP.VarNameList
if ~isfield( FP, 'VarNameList' )
    FP.VarNameList = {'u' 'v' 't' 's' 'sgth'};
end

%% create data struct Mooring
clear MMP;  MMP = struct;

%% initialize MMP information
InfoNameList = {'Project' 'SN' 'UID'};
for idx = 1 : length(InfoNameList)
     name = InfoNameList{idx};
     MMP.(name)  = 'unknown';
end

%% initialize MMP information
ParaNameList = {'lon'  'lat'  'year' 'depth'};
for idx = 1 : length(ParaNameList)
     name = ParaNameList{idx};
     MMP.(name)  = nan;
end

%% updating MMP from Mooring
AllNames = [InfoNameList ParaNameList];
for idx = 1 : length(AllNames)
   name = AllNames{idx};
   if isfield( Mooring, name) 
       MMP.(name) = Mooring.(name);
   end
end
MMP.UID = ['MMP-' MMP.Project '-' MMP.SN];
if ~isempty( FP.label )
    MMP.UID = [MMP.UID '-' FP.label];
end


%% update parameters from FP
GridNameList = {'yday'; 'z'};
for idx_var = 1 : length(GridNameList)
   varname = GridNameList{idx_var};
   if isfield( FP, varname )
       MMP.(varname) = FP.(varname);
   end
end

%% rotate z if necessay
if size(MMP.z, 1) == 1 & size(MMP.z, 2)>1
    MMP.z = MMP.z(:);
end

%% dz and dyday
%MMP.dz    = nanmean( diff(MMP.z) );
MMP.dz    = nanmedian( diff(MMP.z) );
MMP.dyday = nanmean( diff(MMP.yday) );


%% data fields for gridding size
for idx_var = 1 : length(FP.VarNameList)
   varname = FP.VarNameList{idx_var};
   MMP.(varname) = nan( length(MMP.z), length(MMP.yday) );
end


%% If FP contains the fields with the maximum gap
% for interpolation, pass to the MMP structure:

if isfield(FP, 'MaxTimesDZ')
    MMP.MaxTimesDZ = FP.MaxTimesDZ;
end


if isfield(FP, 'MaxTimesDT')
    MMP.MaxTimesDT = FP.MaxTimesDT;
end



%% project mooring's data to MMP data
for idx_str = 1 : length(Mooring.DataList)
    DataName      = Mooring.DataList{idx_str};
    DATA          = Mooring.(DataName);
    DATA.name     = DataName;    
    MMP   = AddDATAToMMP(MMP, DATA);  % call function 
end

return
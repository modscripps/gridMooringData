function CTD = MakeCTD_from_MMP( MMP, FP)
% function CTD = MakeCTD_from_MMP( MMP, FP)
%   makes a CTD using an MMP:
%   the resultant CTD has CTD structure, or a simple MMP
%   
% see  MakeCTD_Levitus2005
% ZZ @ APL-UW, April 27th, 2011


%% display funcation name
disp(['Calling function ' mfilename])


%% setting feault values for the parameters or from FP
if ~exist( 'FP', 'var')
    FP = struct;
end

%% FP.H
if ~isfield( FP, 'depth')
    FP.depth = MMP.depth;
    disp('!!Warning: setting water depth (CTD.H) using MMP.depth')
end

%% create a CTD from MMP
clear CTD 

%% checking MMP's name
if isfield( MMP, 'UID')
    CTD.name = MMP.UID;
else
    CTD.name = 'unknown MMP';
end

%% copy information from MMP to CTD
VarNames = {'year'; 'yday'; 'lon'; 'lat'};
for id = 1 : length( VarNames )
    varname = VarNames{id}; 
    CTD.(varname) = MMP.(varname);
end

%% water depth
CTD.H = FP.depth;

%% vertical grid
dz = nanmean(diff(MMP.z));
CTD.z  = 0 : dz : CTD.H; 
CTD.z  = CTD.z(:);
CTD.dz = dz;

%% interpolate n2 from MMP to CTD
VarNames = {'n2'};
for id = 1 : length( VarNames )
    varname = VarNames{id}; 
    CTD.(varname) = interp1(MMP.z, MMP.(varname), CTD.z);   
end

%% 
CTD.updated = datestr(now);

return

function ADCP = GriddingADCP(ADCP, FP)
%function ADCP = GriddingADCP(ADCP, FP)
%   grids ADCP.(FP.VarNameList) onto time-/z-grid
%
%   Input:
%       ADCP: data structure
%       FP:   parameters
% 
%   Usage: 
%      Standard grid is provided by FP.yday_grid and FP.z_grid
%      If no FP.yday_grid, it is constructed from ADCP.yday
%      If no FP.z_grid,    it is constucted  from ADCP.z
%
%   Output:
%      gridded data fields in ADCP
%      ADCP.yday_grid, ADCP.z_grid, and ADCP.varname_grid
%
%   Step 1: interpolate on z_grid,
%   Step 2: interpolate on yday_grid,
%   
%   NOTE: 
%       This program has codes to check the interval between gridded 
%       data and raw data. If the minimal raw data is too far,
%       this new data is set to be nan.
%       The check is done for yday_grid and z_grid
%
% see also GriddingMMP.m
%
% ZZ @ APL-UW, February 23rd, 2011
% ZZ @ APL-UW, February 24th, 2011

%% display
disp(['Calling function ' mfilename])


%% check FP and its parameters
%% FP
if ~exist('FP', 'var')
    FP = struct;
end

%% FP.yday
if ~isfield(FP, 'yday_grid' )
    disp(' !! No FP.yday_grid.')
    disp(' Constructing  yday_grid from ADCP.yday')
    
    %% yday -> yday_grid
    if length( ADCP.yday ) > 1
        dt = nanmean( diff(ADCP.yday) );
        FP.yday_grid  = nanmin(ADCP.yday) : dt : nanmax(ADCP.yday); 
    else
        FP.yday_grid = ADCP.yday;
    end
end


%% FP.z
if ~isfield(FP, 'z_grid' )
    disp(' !! no FP.z_grid, ')
    disp(' Constructing z_grid from ADCP.z ')
    
    %% z -> z_grid
    if length( ADCP.z ) > 1
        dz = nanmean( diff(ADCP.z) );
        FP.z_grid = nanmin( ADCP.z ) : dz : nanmax( ADCP.z ); 
    else
        FP.z_grid = ADCP.z;
    end
end


%% FP.VarNames
if ~isfield(FP, 'VarNameList' )
    error('There is no variable: see FP.VarNameList = {''t'';''s''}')
end


%% check ADCP and FP.VarNameList
idx_gd = [];
for idx = 1 : length(FP.VarNameList)
    if isfield( ADCP, FP.VarNameList(idx) )
        idx_gd = [idx_gd idx]; 
    end
end
FP.VarNameList = FP.VarNameList(idx_gd);


%% check FP.VarNames again
if length(FP.VarNameList) < 1
    error(' !!! No valid varNames, usage: FP.VarNameList = {''t'';''s''};' )
end


%% save the gridded parameter FP
ADCP.('para_gridding') = FP;
ADCP.yday_grid = FP.yday_grid;
ADCP.z_grid    = FP.z_grid(:);


warning off
%% loop for each variable given in FP.VarNames 
for idx_var = 1 : length(FP.VarNameList)
    varname = FP.VarNameList{idx_var};
    disp(['    working on variable: ' varname])

    %% step 1 
    TEMP = interp1( ADCP.z, ADCP.(varname), ADCP.z_grid);
    
    %% step 2
    GRID = interp1( ADCP.yday, TEMP', ADCP.yday_grid );
                 
    %% 
    ADCP.([varname '_grid']) = GRID';
end

return
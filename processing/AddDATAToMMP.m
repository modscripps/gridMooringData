function MMP = AddDATAToMMP( MMP, DATA )
%function MMP = AddDATAToMMP( MMP, DATA )
%   projects DATA onto MMP with yday-/z-grid
%   
%   if isfield( DATA, 'ydayc' )
%     (DATA.ydayc, DATA.z, DATA.varname) -> (MMP.yday, MMP.z, MMP.varname)
%   else DATA.yday (no ydayc)
%     (DATA.yday, DATA.z, DATA.varname)  -> (MMP.yday, MMP.z, MMP.varname)
%   end
%
%   Step 1:  calling GriddingMMP to grid  DATA.varname
%   Step 2:  copy gridded varname back to MMP.varname
%
% See also AddMooringToMMP
%
% ZZ @ APL-UW March 12th, 2010
% ZZ @ APL-UW April 16th, 2010
% ZZ @ APL-UW February 25th, 2011


%% display
disp(['Calling function ' mfilename])


%% check DATA and its data fields
%% FP
if ~exist( 'DATA', 'var')
    error( ' !!! usage: MMP = AddDATAToMMP(MMP, DATA)')
end

%% DATA.VarNameList
if ~isfield(DATA, 'VarNameList' )
%     DATA.VarNameList = {'u'; 'v'; 'w'; 's'; 't'; 'sgth'; 'eta'; 'uz';'vz'};
    DATA.VarNameList = {'u'; 'v'; 's'; 't'; 'sgth'; 'eta'; 'uz';'vz'};
end

%% check DATA and DATA.VarNames
checkList = zeros( size(DATA.VarNameList) );
for idx = 1 : length(DATA.VarNameList)
    if isfield(DATA, DATA.VarNameList(idx) ), checkList(idx) = 1; end
end
checkList = find( checkList );
DATA.VarNameList = {DATA.VarNameList{checkList}};


%% check FP.VarNames again
if length(DATA.VarNameList) < 1
    error(' !! No valid VarName, usage: DATA.VarNames = {''t'';''s''};' )
end

%% DATA.OriginalTime
if ~isfield(DATA, 'OriginalTime' )
    DATA.OriginalTime = 'ydayc';
end

%% if there is no 'ydayc
if ~isfield(DATA, DATA.OriginalTime )
    DATA.OriginalTime = 'yday';
end

%% give DATA a name to save parameters
if ~isfield(DATA, 'name')
    DATA.name = 'unknown';
end

%% save parametes to MMP
MMP.(['para_' DATA.name]).OriginalTime = DATA.OriginalTime;
MMP.(['para_' DATA.name]).VarNameList  = DATA.VarNameList;

% Print to the screen the data structure and
% which of its variables will be gridded:
DATA
DATA.VarNameList

% --------------------------------------------
% OBM - temporary!!!
if iscolumn(DATA.yday)
    DATA.yday = DATA.yday';
end

if isvector(DATA.(DATA.VarNameList{1})) && iscolumn(DATA.z)
    DATA.z = DATA.z';
end
% --------------------------------------------

close all
for idx_var = 1 : length(DATA.VarNameList)
    varname = DATA.VarNameList{idx_var};
    
    % if varname is not in MMP yet, create one
    if ~isfield(DATA, varname)
        DATA.(varname) = NaN( length(MMP.z), length(MMP.yday) );
    end
    
    if iscolumn(DATA.(varname))
          
        DATA.(varname) = DATA.(varname)';
    end
end


%% Calls Grids the variables calling GriddingOnMMPstruct:

PP.yday_grid    = MMP.yday;
PP.z_grid       = MMP.z;
PP.MaxTimesDZ   = MMP.MaxTimesDZ;
PP.MaxTimesDT   = MMP.MaxTimesDT;

PP.OriginalTime = DATA.OriginalTime;
PP.VarNameList  = DATA.VarNameList;


if strncmp(DATA.name, 'ADCP', 4)
    PP.rcinterp = [1, 2];
else
    PP.rcinterp = [2, 1];
end

NewDATA = GriddingOnMMPstruct(DATA, PP);


%% Now assign the gridded variables of NewDATA to
% the appropriate locations in the MMP structure:

% looping to work on DATA.VarNameList
for idx_var = 1 : length(DATA.VarNameList)
    varname = DATA.VarNameList{idx_var};    

%% new codes after 02-21-2011                
    %% copy varname from NewDATA to MMP
    for idx_yday = 1 : length(MMP.yday)
        
        %% new data % ZZ Feb 21, 2011
        newdata   = NewDATA.([varname '_grid'])(:, idx_yday);
        z_idx_new = find( ~isnan(newdata) );
        z_new     = NewDATA.z_grid( z_idx_new ); 
        
        %% Data already exist there 
        origdata   = MMP.(varname)(:, idx_yday);
        z_idx_orig = find( ~isnan(origdata) );
        z_orig     = MMP.z( z_idx_orig );
        
        %% set difference
        z_new      = setdiff(z_new, z_orig);
            
        %% z: intersect(MMP.z, NewDATA.z_grid)
        [z, idx_z_MMP, c] = intersect( MMP.z, z_new );
        [z, idx_z_NewDATA, c] = intersect( NewDATA.z_grid, z_new );

        %% set difference
        MMP.(varname)(idx_z_MMP, idx_yday ) =  ...
              NewDATA.([varname '_grid'])( idx_z_NewDATA, idx_yday );
    end
    
end

return
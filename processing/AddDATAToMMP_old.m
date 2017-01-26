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
    DATA.VarNameList = {'u'; 'v'; 'w'; 's'; 't'; 'sgth'; 'eta'; 'uz';'vz'};
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

DATA.VarNameList

DATA

% --------------------------------------------
% OBM - temporary!!!
if iscolumn(DATA.yday)
    DATA.yday = DATA.yday';
end

if iscolumn(DATA.z)
    DATA.z = DATA.z';
end
% --------------------------------------------

%% looping to work on DATA.VarNameList
for idx_var = 1 : length(DATA.VarNameList)
    varname = DATA.VarNameList{idx_var};

    %% if varname is not in MMP yet, create one
    if ~isfield(MMP, varname)
        MMP.(varname) = nan( length(MMP.z), length(MMP.yday) );
    end
    
    %% calling GriddingMMP
    PP.yday_grid    = MMP.yday;
    PP.z_gri what the hell hellod       = MMP.z;
    PP.VarNameList  = {varname};
    PP.OriginalTime = DATA.OriginalTime;
        
    close all
    if iscolumn(DATA.(varname))
        DATA.(varname) = DATA.(varname)';
    end
    
    NewDATA = GriddingOnMMPstruct(DATA, PP);
    
%     if strfind( DATA.name, 'MMP' )
%         NewDATA         = GriddingMMP(DATA, PP);
%     elseif strfind( DATA.name,  'ADCP' )
%         NewDATA         = GriddingADCP(DATA, PP);
%     %%%%Added BSB for Aanderaa 05 Aug 2015
%     elseif strfind( DATA.name,'AA')
%         NewDATA         = GriddingAA(DATA,PP);
%     %%%%Added BSB for SBE based on Aanderaa Pattern 10 Aug 2015    
%     elseif strfind( DATA.name,'SBE')
%         NewDATA         = GriddingSBE_Knockdown(DATA,PP);
%     else %for other, using GriddingMMP for now
%         NewDATA         = GriddingMMP(DATA, PP);        
%     end
    

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
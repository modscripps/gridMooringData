function griddedDATA = GriddingOnMMPstruct(DATA, GP)
% griddedDATA = GRIDDINGONMMPSTRUCT(DATA, GP)
%
% Function GRIDDINGONMMPSTRUCT grids the variables
% DATA.(GP.VarNames) onto the time/z grid specified
% by the fields GP.yday_grid and GP.z_grid.
%
%   Input:
%       DATA: data structure.
%       GP: grid parameters.
%
%   Ouput:
%       griddedDATA: gridded data structure. It is the same as
%                    input DATA, but with the additional fields
%                    "para_gridding", "yday_grid", "z_grid" and
%                    "varname_grid", where varname are the
%                    variable that has been gridded.
%
%   NOTE: 
%       This program checks the interval between the grid and
%       the time/depth where there actually is data. If the data
%       is too far from a grid point, the value at this grid point
%       is set to NaN.
%
% An addition of this function in comparison with the previous ones
% is the field GP.rcinterp, which can be:
%       - [1]: interpolate only in depth.
%       - [2]: interpolate only in time.
%       - [1, 2]: interpolate first in depth, then in time.
%       - [2, 1]: the inverse of the above.
% Default option is GP.rcinterp = [1, 2].
%
% This function is an unification of several similar functions
% written by ZZ @ APL-UW. Older functions GriddingADCP, GriddingAA,
% GriddingMMP and GriddingSBE_Knockdown are not necessary anymore.
%
% OBM @ SIO-UCSD, January 06th, 2017.

% ------------------------------------------------------------------------
% ------------------------------------------------------------------------
griddedDATA = DATA;
% SHOULD I USE THE SAME NAME FOR THE OUTPUT AS THE INPUT????? FOR INPUTS
% WITH A LOT OF DATA, THIS MAY MAKE SOME DIFFERENCE.
% ------------------------------------------------------------------------
% ------------------------------------------------------------------------


%   Usage: 
%      Standard grid is provided by GP.yday_grid and GP.z_grid
%      If no GP.yday_grid, it is constructed from MMP.yday
%      If no GP.z_grid,    it is constucted  from MMP.z
%
%      GP.OriginalTime is for original yday in MMP
%        'yday'  for general-case ADCP/VEL/SBE
%        'ydayc' for the profiling MP 
%
%   Step 1: interpolate on yday_grid,
%   Step 2: interpolate on z_grid,
%   Step 3: conditinally (GP.trim) trim column and layer with all NaN


%% Print message to the screen

disp(['Calling function ' mfilename])


%%
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% ---------------------- Check GP and its parameters ----------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% OBM's note: I think this function does not make any sense without
% the specification of fields yday_grid and z_grid in GP input. I
% wrote this string to be printed as warning messages in some of the
% if cases below:
warningStrMsg = ['OBM''s note: to me, it seems wrong to define a '  ...
                     'grid based on a specific instrument. The whole ' ...
                     'point of ' mfilename ' is to grid data from '    ...
                     inputname(1) ' onto a common grid specified by '  ...
                     'the second input (GP). I would not allow this '  ...
                     'function to go on without proper specfication '  ...
                     'of it. However, since I did not originally '     ...
                     'write this code, I''m keeping this original '     ...
                     'functionality. BE CAREFUL!!!'];

                 
% It is mandatory that VarNameList is a field of GP, containing
% the variable names to be gridded. It is also necessary that
% VarNameList has variables names that are present in DATA. Stops
% the execution with error messages otherwise:
if ~exist('GP', 'var')
    warning(warningStrMsg)
    error('Input GP (grid parameteres) was not given.')
    
else

    if ~isfield(GP, 'VarNameList' )
        error(['There is no VarNameList in ' inputname(2) '. This  ' ...
               'is mandatory since that is how ' mfilename ' knows ' ...
               'what variables to grid. Specify GP.VarNameList as '  ...
               'cell array with the names of the variables to grid.'])
    else
        
        % Only keep the variables in GP.VarNameList
        % that are fields of DATA:
        GP.VarNameList = GP.VarNameList(isfield(DATA, GP.VarNameList));

        % If there are no variables left GP.VarNameList
        % (the variables to be gridded), then throw error:
        if isempty(GP.VarNameList)
            error([' !!! None of the variables in ' inputname(2) '.' ...
                   'VarNameList is found as fields of structure '    ...
                   '' inputname(1) '.'])
        end
    end    
end


% Check "OriginalTime" field. The use of this "OriginalTime"
% allows the use of different variables for the time of the
% data. In particular moored profiler data may be specified
% at the time of each measurement rather than the mean time
% of each profile (see function Add_correct_yday_MP2.m). In
% this case, the time variable is a matrix rather than a vector:
if ~isfield(GP, 'OriginalTime')
    
    disp(' !! No GP.OriginalTime specified. Using DATA.yday as GP.OriginalTime.')
    GP.OriginalTime = 'yday';
end


% Check the existence of GP.yday_grid and create if it doesn't already:
if ~isfield(GP, 'yday_grid' )
    
    warning(warningStrMsg)
    disp(' !! No GP.yday_grid.')
    disp([' Constructing  GP.yday_grid from ' ...
            inputname(1) '.' GP.OrignalTime '.'])
    
	% If GP.OriginalTime is NOT a field of DATA, throw an error:
    if ~isfield(DATA.(GP.OriginalTime))
        error(['No yday_grid was found in ' inputname(2) ' and the ' ...
               'attempt to create a time grid from the data failed ' ...
               'because the time ' GP.OriginalTime ' is not a '      ...
               'field of the data structure ' inputname(1) '.'])
    end
        
    % Get absolute minimum and maximum time to create the time grid.
    absmintime = min(DATA.(GP.OriginalTime)(:));
    absmaxtime = max(DATA.(GP.OriginalTime)(:));
    
    % If there is only one time with data (such that
    % absmintime==absmaxtime), then the time grid is
    % only one time point (OBM has no idea why ZZ took
    % this case into account; maybe to deal with a CTD
    % station that has only one cast):
    if absmintime==absmaxtime
       
        GP.yday_grid = absmintime;
        
    else
        
        % Create the time step of the time grid. In the case where
        % DATA.(GP.OriginalTime) is a matrix, dt is created using
        % (arbitrarily) the first row of the matrix (which is the
        % same syntax for using a row vector):
        dt = nanmean(diff(DATA.(GP.OriginalTime)(1, :)));
        if iscolumn(DATA.(GP.OriginalTime))
            error(['Your time vector is a column vector. ' ...
                   'Make it a row vector to avoid weird '  ...
                   'behaviour in the data processing.'])
        end

        GP.yday_grid = absmintime : dt : absmaxtime;
    end
    
end


% Check the existence of GP.z_grid and create if it doesn't already:
if ~isfield(GP, 'z_grid' )
    
    warning(warningStrMsg)
    disp(' !! no GP.z_grid, ')
    disp([' Constructing z_grid from ' inputname(1) '.z.'])
    
    % If there is only one depth point, then this is what
    % the grid is. Otherwise, create a depth grid vector:
    if length(DATA.z) > 1
        dz = nanmean(diff(DATA.z));
        GP.z_grid = min(DATA.z) : dz : max(DATA.z);
        GP.z_grid = GP.z_grid(:);  % make it column vector
    else
        GP.z_grid = DATA.z;
    end

end


% If there is no GP.trim option, use default of no trimming:
if ~isfield(GP, 'trim' )
    disp(' !! No GP.trim')
    disp([' Using GP.trim = false, no removal of ' ...
          'columns/rows with NaN-only.'])
    GP.trim = false;  % no trimming
end

% -------------------------------------------------
if ~isfield(GP, 'rcinterp')
    GP.rcinterp = [2, 1];
end

% Should check the dimensions of the data (VarNameList)
% and throw warning if you try, for example, to
% interpolate in depth a single thermistor data.
% -------------------------------------------------


% Check the existence of parameters (MaxTimesDZ and MaxTimesDT) defining
% the maximum length of the gaps that will be interpolated through. The
% default values are arbitrary. Example, if the time-grid has a 10-minute
% resolution, then GP.MaxTimesDT = 3 determines that gaps longer than 30
% minutes will not be interpolated:
%
if ~isfield(GP, 'MaxTimesDZ')
	GP.MaxTimesDZ = 3;
end
%
if ~isfield(GP, 'MaxTimesDT')
    GP.MaxTimesDT = 3;
end


% Save the gridded parameter of GP in the output variable:
griddedDATA.('para_gridding') = GP;
griddedDATA.yday_grid = GP.yday_grid;
griddedDATA.z_grid    = GP.z_grid;

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------


%%
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% ------------- Now do the real work of gridding the variables ------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------


%% Loop through variables given in GP.VarNameList

string_dx = {'MaxTimesDZ', 'MaxTimesDT'};


% Loop through variables:
for ivar = 1 : length(GP.VarNameList)
    
    varname = GP.VarNameList{ivar};
    disp(['    Working on variable: ' varname])
    
    
	% Loop through the dimensions to be gridded
    % (in the order they are specified by GP):
    clear auxvargrid
    
    for idim = 1:length(GP.rcinterp)

        if GP.rcinterp(idim)==1
            maxdist = GP.(string_dx{idim}) * ...
                                         nanmean(diff(griddedDATA.z_grid));
        else
            maxdist = GP.(string_dx{idim}) * ...
                                      nanmean(diff(griddedDATA.yday_grid));
        end
                       
        keyboard
        
        % This if exists because, on the second iteration of the
        % for loop, we want to operate on the result of the first
        % iteration of the for loop
        if idim==1
            
            % Grid in depth:
            if GP.rcinterp(idim)==1
                
                auxvargrid = GriddingOrAssigning(1, maxdist,            ...
                                                 griddedDATA.z,         ...
                                                 griddedDATA.(varname), ...
                                                 griddedDATA.z_grid);
               
            % Grid in time:
            else
                
                if isfield(DATA, 'efluorgain')
                    keyboard
                end
                
                if ivar==1
                
                    [auxvargrid, lgridclose] = GriddingOrAssigning(2, maxdist,            ...
                                                               griddedDATA.yday,      ...
                                                               griddedDATA.(varname), ...
                                                               griddedDATA.yday_grid);
                else
                    
                    auxvargrid = GriddingOrAssigning(2, maxdist,            ...
                                                     griddedDATA.yday,      ...
                                                     griddedDATA.(varname), ...
                                                     griddedDATA.yday_grid, ...
                                                     lgridclose);
                    
                end
                                             
                                             
                % If the variable is a single time series (at a "single"
                % depth") and its depth is given at every time stamp, also
                % put the time series of depth on the time grid:
                if isrow(griddedDATA.z) && length(griddedDATA.z)>1
                    griddedDATA.z = interp1(griddedDATA.yday(:), ...
                                            griddedDATA.z(:), ...
                                            griddedDATA.yday_grid(:));
                end
                                             
                
            end
            
            
            
        else
           
            % Grid in depth:
            if GP.rcinterp(idim)==1
                
                auxvargrid = GriddingOrAssigning(1, maxdist,    ...
                                                 griddedDATA.z, ...
                                                 auxvargrid,    ...
                                                 griddedDATA.z_grid);
               
            % Grid in time:
            else
                
                if isfield(DATA, 'efluorgain')
                    keyboard
                end
                auxvargrid = GriddingOrAssigning(2, maxdist,    ...
                                                 griddedDATA.yday, ...
                                                 auxvargrid,    ...
                                                 griddedDATA.yday_grid);
                if isfield(DATA, 'efluorgain')
                    keyboard
                end
            end
 
        end
                       
        
    end  % end for loop over dimension
    
    %
    griddedDATA.([varname '_grid']) = auxvargrid;

end






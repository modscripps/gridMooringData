%% Template for writing the Mooring and MMP structure variables.
%
% This template is part of the gridMooringData toolbox. Change the
% information on this file for the mooring that you are interested
% in and run this script.
%
% This script has 7 sections:
%   - (1) Data information the user needs to specify;
%   - (2) Loading the data.
%   - (3) Looking/editing the RAW data.
%   - (4) Extra data formatting and knockdown correction.
%   - (5) Looking at the edited data.
%   - (6) Creating the Mooring structure.
%   - (7) Creating the MMP structure.
%
% It is only required that you change the information from the
% template on section (1).
%
% Section (3) has no code in the template. The purpose of this
% section is so that the user make sures the raw data looks good
% and correct problems. For example, if there is a compass offset
% that hasn't yet been corrected in the current meter processing,
% then you may add this correction in section (3).
%
% TO DO:
%       1 - Option for putting station rather than mooring.
%
% Olavo Badaro Marques, Jan-2017.

clear
close all


%% Section 1
%  ------------------------------------------------------------------------
%  ------------------------------------------------------------------------
%  ------------- CHANGE THE VARIABLES IN THE CODE BLOCKS BELOW ------------
%  ------------------------------------------------------------------------
%  ------------------------------------------------------------------------


%% Mooring identification and data directory

moorid = 'M2';

moordir = '/Volumes/Ahua/data_archive/WaveChasers-DataArchive/TTIDE/Moorings/M2/';

cd(moordir)


%% Script with information of all instruments on the mooring:

dir_script_allinstruments = ['/Users/olavobm/Documents/MATLAB/'  ...
                             'olavo_research/TTIDE/scripts_mooring_processing/' ...
                             'scripts_instruments/'];

scriptname = 'TTIDE_M2_allinstruments.m';

moorvarname = 'M2sensors';

script_fullpath = fullfile(dir_script_allinstruments, scriptname);


%% Metadata of current mooring (FP = Forward Parameters):

clear FP  % make sure it does not already exist

FP.Project = 'TTIDE';
FP.year = 2015;
FP.SN = moorid;

FP.depth = 1670;
FP.lon = 148 + (54.297/60);
FP.lat = -41 - (19.775/60);

% FP.deploymenttime MUST BE in datenum format and UTC-referenced:
FP.deploymenttime = [datenum(2015, 1, 15), datenum(2015, 3, 4)];


%% Destination directories

% These will be used repeatedly:
Figure_dir = moordir;
Data_dir = moordir;

% This is a specific invocation of the directories:
FP.Figure_dir = Figure_dir;
FP.Data_dir = Data_dir;


%% Grid where data will be interpolated on (MMP structure). Note
% the time endpoints of the grid MUST BE contained in
% FP.deploymenttime (the dates, not the actual values, since one
% is given in datenum and yday). Otherwise, it is likely to get
% errors if there are no pressure-recording instruments and
% knockdown correction can not be applied:

FPforMMP = FP;

ydaybeg = 14.3;
ydayend = 62;
dtmin = 10;          % time interval in minutes

FPforMMP.yday = ydaybeg : dtmin/60/24 : ydayend;

FPforMMP.z = 0 : 2 : FP.depth;

% Maximum length of gaps that can be interpolate through:
FPforMMP.MaxTimesDZ = 3;
FPforMMP.MaxTimesDT = 3;


%% Set up variables, flags and labels:

savemmp = false;   % logical variable (true or false)
label = 'Interp';  % interpolate or not

intwhere = 'top-bottom-middle';     % where to fill gaps
UID = ['TTIDE-' moorid '-' label];  % ID for output struct variables



%% Section 2
%  ------------------------------------------------------------------------
%  ------------------------------------------------------------------------
%  ---------------------------- LOAD THE DATA -----------------------------
%  ------------------------------------------------------------------------
%  ------------------------------------------------------------------------


%% Run script contaning all instrument serial numbers and nominal depths:

% Run script that creates the variable with instruments info:
run(script_fullpath)

% Copy the created variable to one with the generic name "moorsensors":
moorsensors = eval(moorvarname);

% Clear the variable that has been copied:
eval(['clear ' moorvarname])

% Print variable to the screen so the user can
% make sure the intended sensors were loaded:
disp(['The variable created from ' script_fullpath ' is:'])
  
eval('moorsensors')
            

%% Load all the data to the workspace:

instrmntTypes = fieldnames(moorsensors);

loadedData = emptyStructArray(instrmntTypes, 1);

% Loop over the types of instruments:
for i1 = 1:length(instrmntTypes)
    
    % Now loop over each instrument of the i1'th type:
    for i2 = 1:size(moorsensors.(instrmntTypes{i1}), 1)
        
        % Call the load_mooring_datafile function:
        auxDataStruct = loadMooringData(moordir, ...
                                   instrmntTypes{i1}, ...
                                   moorsensors.(instrmntTypes{i1}){i2, 1});
        
        % Assign auxDataStruct to loadedData:
        if i2 == 1
        % Assign right away:
        
            loadedData.(instrmntTypes{i1})(i2) = auxDataStruct;
            
        else
        % Make sure the new structure has the same fields as
        % the existing array. Add fields with empty content
        % if the field names don't match:
            
            auxFieldNames = sort(fieldnames(auxDataStruct));
            datFieldNames = sort(fieldnames(loadedData.(instrmntTypes{i1})));
            
            if ~isequal(auxFieldNames, datFieldNames);
                
                loadedData.(instrmntTypes{i1}) = ...
                        matchStructArray(loadedData.(instrmntTypes{i1})(1:(i2-1)), ...
                                         auxDataStruct);
            else

                auxDataStruct = orderfields(auxDataStruct, ...
                               fieldnames(loadedData.(instrmntTypes{i1})));
                    
                loadedData.(instrmntTypes{i1})(i2) = auxDataStruct;
                
            end
            
        end
        
    end
    
end



%% Section 3
%  ------------------------------------------------------------------------
%  ------------------------------------------------------------------------
%  ---- THIS IS WHERE YOU SHOULD ADD CODE TO PLOT OR EDIT THE RAW DATA ----
%  ------------------------------------------------------------------------
%  ------------------------------------------------------------------------


%% Section 4
%  ------------------------------------------------------------------------
%  ------------------------------------------------------------------------
%  -------- DATA IS FORMATTED AND CORRECTED FOR MOORING KNOCKDOWNS --------
%  ------------------------------------------------------------------------
%  ------------------------------------------------------------------------

%% After loading the data, there is few minor processing
% that still needs to be done. Each type of instrument/data
% needs something different:
     
% I have to create a new empty structure because Matlab
% does not allow substituting a sructure by another
% one with different fields:
editedData = emptyStructArray(instrmntTypes, 1);

% Loop over the types of instruments:
for i1 = 1:length(instrmntTypes)
    
    % Now loop over each instrument of the i1'th type:
    for i2 = 1:size(moorsensors.(instrmntTypes{i1}), 1)
        
        % Call the extraDataEditting function:
        editedData.(instrmntTypes{i1})(i2) = ...
             extraDataEditing(loadedData.(instrmntTypes{i1})(i2), ...
                              instrmntTypes{i1}, ...
                              FP.lat, moorsensors.(instrmntTypes{i1}){i2, 2});
    end
    
end


%% Generate depth-perturbation grid for mooring knockdown correction.
% Based on vertical displacements from instruments that measure
% pressure, this function estimates the vertical displacement of
% an instrument anywhere in the water column:

interpObj = mooring_zperturbgrid(FP, moorsensors, editedData);

% If function aboved returned NaN, then we create an interObj that works
% as if there is NO knockdown at all. No correction is applied. This is
% a complicated way of transforming a nominal depth scalar into a vector
% where the scalar is repeated in every entry. However, this is suitable
% because this fits in the correctKnockDownZ.m:
if ~isa(interpObj, 'interp1class') && isnan(interpObj) 
    
    interpObj = interp1class({[FP.deploymenttime],  ...
                              [FP.deploymenttime]}, ...
                             {[0, 0], [FP.depth, FP.depth]});
    
end

% Create common time for interpolating 
mintimeoverlap = max(cellfun(@min, interpObj.xarrays));
maxtimeoverlap = min(cellfun(@max, interpObj.xarrays));
timestep = 2/(24*60);  % 2 minutes

timegrid = mintimeoverlap : timestep : maxtimeoverlap;

% Correct the depth for instruments that do not measure
% pressure. From now on, their variables are interpolated
% onto timegrid:
correctedData = correctKnockDownZ(interpObj, moorsensors, editedData, timegrid);



%% Section 5
%  ------------------------------------------------------------------------
%  ------------------------------------------------------------------------
%  ---- THIS IS ANOTHER PLACE WHERE YOU MIGHT WANT TO LOOK AT THE DATA ----
%  ------------------------------------------------------------------------
%  ------------------------------------------------------------------------


%% Section 6
%  ------------------------------------------------------------------------
%  ------------------------------------------------------------------------
%  ----------------------- CREATE MOORING STRUCTURE -----------------------
%  ------------------------------------------------------------------------
%  ------------------------------------------------------------------------
%
% Function AddInstrumentToMooring is used to add data from each
% instrument. We clear the original variables as we go to free
% up memory.


%% Creates a "blank" mooring structure
%  using the FP (Forward Parameters).

% Add field to FP including the translated instrument types,
% with no repetitions (see explanation in translateInstrTypes):
FP.InstrumentList = unique(translateInstrTypes(instrmntTypes));

% Create Mooring structure with metadata so far:
Mooring = mkMooring(FP);


%% Add all the data to the Mooring structure:
 
% Loop over the types of instruments:
for i1 = 1:length(instrmntTypes)
    
    auxInstrName = translateInstrTypes(instrmntTypes(i1));
    auxInstrName = auxInstrName{1}; % convert from cell to char class
    
    % Now loop over each instrument of the i1'th type:
    for i2 = 1:length(correctedData.(instrmntTypes{i1}))
        
        eval([auxInstrName ' = correctedData.(instrmntTypes{i1})(i2);']);
        
        Mooring = eval(['AddInstrumentToMooring(Mooring, ' auxInstrName ');']);
    end
    
end


%% Plot the mooring data - EXCEPT THAT THERMISTOR DATA WON'T BE
% PLOTTED BECAUSE IT IS A VECTOR AND NOT A MATRIX:
% Keep in mind that the "Mooring" has raw data and
% raw timing (raw timing even after the 2min thing????)

% % Uncomment if you've got the RAM, AND WHEN THIS IS WELL-WRITTEN.
% if savemmp
%     PlotMooring(Mooring)
% else
%     ShowMooring(Mooring)
% end



%% Saves a .txt file on the current
% directory (moordir) with some info:
Mooring = CheckMooring(Mooring);


%% Save the Mooring structure:
if savemmp
    fileid = saveDATA(Mooring);
end


%% Section 7
%  ------------------------------------------------------------------------
%  ------------------------------------------------------------------------
%  ------------------ CREATES MMP STRUCTURE (GRIDDED DATA) ----------------
%  ------------------------------------------------------------------------
%  ------------------------------------------------------------------------


%% Create MMP Structure: Here we interpolate all
% instruments to a common depth-time grid:

% Make the Structure
MMP = mkMMP(Mooring, FPforMMP);
MMP.UID = UID;


%% Plot the data on MMP structure:

MMP.VarNamesToShow = {'u', 'v', 's', 't', 'sgth'};

MMP.Figure_dir = Figure_dir;
MMP.Data_dir = Data_dir;
MMP.Figure_name = ['Fig=' MMP.UID '-raw'];

% PlotMMP(MMP)


%% Save MMP:

if savemmp
    MMP.UID = UID;
    MMP.MakeInfo = ['Structure made on ' date ', with ' mfilename '.m'];
    fileid = saveDATA( MMP );
end

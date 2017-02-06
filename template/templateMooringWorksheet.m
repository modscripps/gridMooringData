%% Template for writing the Mooring and MMP structure variables.
%
% This template is part of the gridMooringData toolbox. Change the
% information on this file for the mooring that you are interested
% in and run this script.
%
% This script has 5 sections: (1) Data information the user needs
% to specify, (2) Loading the data, (3) Looking/editing data, (4)
% Creating the Mooring structure and (5) Creating the MMP structure.
% It is only required that you change the information from the
% template on section (1).
%
% Section (3) has no code in the template. The purpose of this
% section is so that the user add code to deal with processing
% specific to a mooring. For example, if there is a compass offset
% that hasn't yet been corrected in the current meter processing,
% then you may add this correction in section (3).
%
% Three important things left to do:
%
%       1 - Option for not doing knockdown correction.
%       2 - Option for adding station data, fit S from T
%           and estimate salinity on thermistor data.
%       3 - Option for putting station rather than mooring.
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

moorid = 'T1';

% moordir = ['/Users/olavobm/Documents/MATLAB/olavo_research/' ...
%            'TTIDE/data_asigot/Tmoorings_1to6/T1'];

moordir = '/Volumes/Ahua/data_archive/WaveChasers-DataArchive/TTIDE/Moorings/T1/';

cd(moordir)


%% Script with information of all instruments on the mooring:

% dir_script_allinstruments = moordir;
dir_script_allinstruments = ['/Users/olavobm/Documents/MATLAB/olavo_research/' ...
           'TTIDE/data_asigot/Tmoorings_1to6/T1'];

scriptname = 'TTIDE_T1_allinstruments.m';

moorvarname = 'T1sensors';

script_fullpath = fullfile(dir_script_allinstruments, scriptname);


%% Metadata of current mooring (FP = Forward Parameters):

clear FP  % make sure it does not already exist

FP.Project = 'TTIDE';
FP.year = 2015;
FP.SN = moorid;

FP.depth = 1978;
FP.lon = -148 - (59.2920/60);
FP.lat = -41  - (20.0760/60);


%% Destination directories

% These will be used repeatedly:
Figure_dir = moordir;
Data_dir = moordir;

% This is a specific invocation of the directories:
FP.Figure_dir = Figure_dir;
FP.Data_dir = Data_dir;


%% Grid data will be interpolated on in the MMP structure:

FPforMMP = FP;

ydaybeg = 20;
ydayend = 60;
dtmin = 10;          % time interval in minutes

FPforMMP.yday = ydaybeg : dtmin/60/24 : ydayend;

FPforMMP.z = 0 : 2 : FP.depth;


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
        loadedData.(instrmntTypes{i1})(i2) = ...
               load_mooring_datafile(moordir, ...
                                     instrmntTypes{i1}, ...
                                     moorsensors.(instrmntTypes{i1})(i2, 1));
    end
    
end


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
                              FP.lat, moorsensors.(instrmntTypes{i1})(i2, 2));
    end
    
end

% I probably want to erase loadedData to free up space

%% Generate depth-perturbation grid for mooring knockdown correction.
% Based on vertical displacements from instruments that measure
% pressure, this function estimates the vertical displacement of
% an instrument anywhere in the water column:

interpObj = mooring_zperturbgrid(FP, moorsensors, editedData);

% Create common time for interpolating 
mintimeoverlap = max(cellfun(@min, interpObj.xarrays));
maxtimeoverlap = min(cellfun(@max, interpObj.xarrays));
timestep = 2/(24*60);  % 2 minutes

timegrid = mintimeoverlap : timestep : maxtimeoverlap;



% THERE MUST BE AN OPTION FOR NOT RUNNING THIS FUNCTION,
% which means that I would have to create depth vectors
% for the instruments that do not measure pressure!!!
correctedData = correctKnockDownZ(interpObj, moorsensors, editedData, timegrid);


% % Interp correction to data timestamp:
% for i1 = 1:length(instrmntTypes)
%     
%     % Now loop over each instrument of the i1'th type:
%     for i2 = 1:size(moorsensors.(instrmntTypes{i1}), 1)
%         correctedData = interpstructfields(correctedData, f, tgiven, tinterp);
%     end
%     
% end



%% Section 3
%  ------------------------------------------------------------------------
%  ------------------------------------------------------------------------
%  ------- THIS IS WHERE YOU CAN ADD CODE TO PLOT OR EDIT THE DATA --------
%  ------------------------------------------------------------------------
%  ------------------------------------------------------------------------


%% Section 4
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


%% Section 5
%  ------------------------------------------------------------------------
%  ------------------------------------------------------------------------
%  ------------------ CREATES MMP STRUCTURE (GRIDDED DATA) ----------------
%  ------------------------------------------------------------------------
%  ------------------------------------------------------------------------


%% Create MMP Structure: Here we interpolate all
% instruments to a common depth-time grid:

% Make the Structure
MMP = mkMMP(Mooring, FP);
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


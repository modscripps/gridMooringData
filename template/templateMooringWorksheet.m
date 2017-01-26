%% Template for writing the Mooring and MMP structure variables.
%
% This template is part of the ......... toolbox. Change the
% information on this file for the mooring that you are
% interested in and run this script.
%
% This script has 4 sections: (1) Data information the user needs
% to specify, (2) Loading the data, (3) Creating the Mooring
% structure and (4) Creating the MMP structure. It is only required
% that you change the information from the template on section (1).
%
% Three important things left to do:
%       1 - Load data in an organized way
%       2 - CHOOSE WHETHER WE DO OR DON'T DO KNOCKDOWN CORRECTION.
%       3 - Leave room for plotting/adjusting things that
%           may be wrong with the data.
%       4 - LEAVE OPTION FOR ADDING STATION DATA, FIT S FROM T
%           AND ESTIMATE SALINITY ON THERMISTOR DATA.
%       5 - AddInstrumentToMooring recursively.
%       6 - Option for putting station rather than mooring.
%       7 - NAME OF THE VARIABLE FROM ALL INSTRUMENTS SCRIPT!!!!
%
% Olavo Badaro Marques, 01/05/2017.

clear
close all


%%
%  ------------------------------------------------------------------------
%  ------------------------------------------------------------------------
%  ------------- CHANGE THE VARIABLES IN THE CODE BLOCKS BELOW ------------
%  ------------------------------------------------------------------------
%  ------------------------------------------------------------------------


%% Mooring identification and data directory

moorid = 'T1';

moordir = ['/Users/olavobm/Documents/MATLAB/olavo_research/' ...
           'TTIDE/data_asigot/Tmoorings_1to6/T1'];

cd(moordir)


%% Script with information of all instruments on the mooring:

script_moor_allinstruments = 'TTIDE_T1_allinstruments.m';


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



%%
%  ------------------------------------------------------------------------
%  ------------------------------------------------------------------------
%  ---------------------------- LOAD THE DATA -----------------------------
%  ------------------------------------------------------------------------
%  ------------------------------------------------------------------------


%% Run script contaning all instrument serial numbers and nominal depths:

run(script_moor_allinstruments)

% Print variable to the screen so the user can
% make sure the intended sensors were loaded:
disp(['Script ' script_moor_allinstruments ' creates ' ...
      'the following variable:'])
  
eval([moorid 'sensors'])


%% Generate depth-perturbation grid. Based on vertical
%  displacements from instruments that measure pressure,
%  this function estimates the vertical displacement of
%  an instrument anywhere in the water column:

[ z_1m_perturb, time_2min ] = mooring_zperturbgrid(moordir, moorid, T1sensors);

% THERE MUST BE AN OPTION FOR NOT RUNNING THIS FUNCTION!!!

% This should come after loading all the data!!!!!!!!


%% Load ADCP data
% There are different versions of processed ADCP. This code implements
% the use of ADCP gridded with a 10-minute time resolution.


% % Middle ADCP
% ADCP_MID = load_mooring_datafile(moordir, 'RDIadcp', T1sensors.RDIadcp(2, 1));
% 
% ADCP_MID.yday(isnan(ADCP_MID.yday)) = ...
%                         datenum2yday(ADCP_MID.dtnum(isnan(ADCP_MID.yday)));
% 
% % Possible NaNs in time variable are removed. There should
% % never be NaN in an independent variable!!!!
% 
% %  Bottom ADCP:
% ADCP_BOT = load_mooring_datafile(moordir, 'RDIadcp', T1sensors.RDIadcp(1, 1));
% 
% 
% ADCP_BOT.yday(isnan(ADCP_BOT.yday)) = ...
%                         datenum2yday(ADCP_BOT.dtnum(isnan(ADCP_BOT.yday)));

                    
%% Load all the data to the workspace:

instrmntTypes = fieldnames(T1sensors);

loadedData = createEmptyStruct(instrmntTypes, 1);

% Loop over the types of instruments:
for i1 = 1:length(instrmntTypes)
    
    % Now loop over each instrument of the i1'th type:
    for i2 = 1:size(T1sensors.(instrmntTypes{i1}), 1)
        
        loadedData.(instrmntTypes{i1})(i2) = ...
               load_mooring_datafile(moordir, ...
                                     instrmntTypes{i1}, ...
                                     T1sensors.(instrmntTypes{i1})(i2, 1));
        
    end
    
    
end


%% After loading the data, there are few
% things to do that are instrument-specific:
                    
% ADCP (or any instrument): remove NaNs in independent variable.
% SBEs and RBRs: compute yday.
% Rename variables: go from (capital) T to lower case t.
% Compute potential density.
% Compute z from pressure (?).
% Correct knockdown on thermistors.



%%
%  ------------------------------------------------------------------------
%  ------------------------------------------------------------------------
%  ----------------------- CREATE MOORING STRUCTURE -----------------------
%  ------------------------------------------------------------------------
%  ------------------------------------------------------------------------
%
% Function AddInstrumentToMooring is used to add data from each
% instrument. We clear the original variables as we go to free
% up memory.


%% Creates a ``blank" mooring structure using
%  the FP (Forward Parameters).
Mooring = mkMooring(FP);

% Set Mooring Directories
Mooring.Figure_dir = Figure_dir;
Mooring.Data_dir = Data_dir;


%% Add ADCPs to Mooring
 
% Middle ADCP
Mooring = AddInstrumentToMooring(Mooring, ADCP_MID);

% Bottom ADCP
Mooring = AddInstrumentToMooring(Mooring, ADCP_BOT);

clear ADCP_TOP ADCP_MID


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


%% Check the mooring:
% Saves a .txt file (at Data_dir or Figure_dir ???) with some info:
Mooring = CheckMooring(Mooring);


%% Save the Mooring structure:
if savemmp
    fileid = saveDATA(Mooring);
end


%%
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


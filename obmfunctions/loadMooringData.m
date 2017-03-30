function instrdata = loadMooringData(moordir, instrtype, sn)
%
% instrdata = LOADMOORINGDATA(moordir, instrtype, sn)
%
%  inputs:
%    - moordir: mooring directory where all the data are in subfolders.
%    - instrtype: string indicating instrument type (see all
%                 possibilities in the cases defined in the code).
%    - sn: instrument serial number.
%
%  output:
%    - instrdata: data structure variable.
%
% Function to load mooring data from a single-instrument *.mat data
% file. We load data from an instrument of type instrtype with serial
% number sn.
%
% The thing about this function is that there is no "inter-instrument"
% convention of how the mooring data is saved. So this function has a
% particular case for each instrument type.
%
% It is expected that each data file has only one structure variable
% with all the data. This structure is the output. Note these
% structures have standard names for each instrument, but they are
% renamed when this function is called by whatever name is as the output.
%
% Feel free to add more cases for new kinds of instrument that might
% be on a mooring. When creating a new case, I advise creating a new
% instrtype string that contains the brand and what kind of instrument
% it is. Remember that a data file should contain only one structure
% variable.
%
% Olavo Badaro Marques, 07/15/2016.


%% We can check the inputs:



%% Load the data:

switch instrtype

    case 'SBE37'

        dataloaded = load(fullfile(moordir, 'SBE37', num2str(sn), ...
                                     ['SBE37_SN' num2str(sn) '.mat']));
                  
	case 'SBE39'

        dataloaded = load(fullfile(moordir, 'SBE39', num2str(sn, '%04d'), ...
                                     ['SBE39_SN' num2str(sn, '%04d') '.mat']));
                                 
	case 'SBE56'

        dataloaded = load(fullfile(moordir, 'SBE56', num2str(sn, '%04d'), ...
                                 ['SBE056' num2str(sn, '%05d') '.mat']));
                                 
    case 'RBRSolo'

        dataloaded = load(fullfile(moordir, 'RBRSolo', ...
                                 ['RBRSolo_' num2str(sn, '%06d') '.mat']));
    
    case 'RBRConcerto'

        dataloaded = load(fullfile(moordir, 'RBRConcerto', ...
                                   num2str(sn, '%06d'), ...
                                   [num2str(sn, '%06d') '.mat']));
                               
    case 'RDIadcp'

        % We first use * and dir because the ADCP filenames have the
        % name of the project in it (in the place of *). Doing like
        % this makes its usage independent of project name:
        dirpath = fullfile(moordir, 'ADCP', ['SN' num2str(sn)], ...
                                                           'data_mat');
        flullpath = fullfile(dirpath, ...
                                ['SN' num2str(sn) '_*_AVE_10min.mat']);
        flstrc = dir(flullpath);
        
        dataloaded = load(fullfile(dirpath, flstrc.name));
        
    case 'MP' % McLane Profiler
        
        dirpath = fullfile(moordir, 'MP', ['sn' num2str(sn)], 'processed');
        flullpath = fullfile(dirpath, ['MPall_*_sn' num2str(sn) '.mat']);
        flstrc = dir(flullpath);
        
        dataloaded = load(fullfile(dirpath, flstrc.name));
        
    case 'AA'
        
        dirpath = fullfile(moordir, 'Aanderaa');
        flullpath = fullfile(dirpath, ['AA' num2str(sn) '_*.mat']);
        flstrc = dir(flullpath);
        
        dataloaded = load(fullfile(dirpath, flstrc.name));
        
        
	% ---------------------------------------------------------------------
    %                   ADD NEW INSTRUMENT CASE HERE.
    % ---------------------------------------------------------------------
        
    otherwise
        
        error(['Loading a ' instrtype ' instrument has not been ' ...
               'implemented in the function ' mfilename '. Create ' ...
               'a new case in function ' mfilename '.'])

end


%% Pass the data structure to the output:

% Get the name of the variable loaded (there
% should be only one variable):
datastructname = fieldnames(dataloaded);

% Check there is only one variable and pass to the output:
if length(datastructname) == 1 
    
    instrdata = dataloaded.(datastructname{1});
    
else  
    error(['Data file of instrument ' instrtype ' / SN ' ...
           num2str(sn) ' does not have only one variable.'])
end

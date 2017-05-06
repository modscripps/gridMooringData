function plotMoorDataSection(correctedData, varcell, lfakeinterp)
% PLOTMOORDATASECTION(correctedData, varcell, lfakeinterp)
%
%   inputs:
%       - correctedData:
%       - varcell:
%       - lfakeinterp: logical variable, where true does a fake
%                      interpolation (see below). Default is false.
%
% ........ Input correctedData is the output of extraDataEditing.m, in
% other words, this input has the fromatted mooring data, but separate for
% each instrument.
%
% Lots of things still to be added.
%
% Olavo Badaro Marques, 05/May/2017.


%% Types of instruments supported by this function:

list_instr = {'SBE56', 'SBE39', 'SBE37', ...
              'RBRSolo', 'RBRConcerto', ...
              'AA', 'RDIadcp', 'MP'};

          
%% Variables supported by this function:

list_vars = {'t', 's', 'sgth', 'u', 'v'};

Nvars = length(list_vars);


%% Map the variables with the instruments that measure them:

% The fields in the setsInstrs structure MUST have be
% named with elements of the cell array list_vars:
setsInstrs.t = {'SBE56', 'SBE39', 'SBE37', 'RBRSolo', 'RBRConcerto', 'MP'};
setsInstrs.s = {'SBE37', 'RBRConcerto', 'MP'};
setsInstrs.sgth = {'SBE37', 'RBRConcerto', 'MP'};
setsInstrs.u = {'AA', 'RDIadcp', 'MP'};
setsInstrs.v = {'AA', 'RDIadcp', 'MP'};

% Be ca
cellsetsIntrs = cell(1, Nvars);

for i = 1:Nvars
    cellsetsIntrs{i} = setsInstrs.(list_vars{i});
end

% Create map to go from a string identifying the variable name to
% a cell array of strings with the names of instrument types
% that measure the variables:
var2instr = containers.Map(list_vars, cellsetsIntrs);


%% Look at all variables if input varcell is not given:

if ~exist('varcell', 'var') || isempty(varcell)
    varcell = list_vars;
end


%%

for i1 = 1:length(varcell)
    
    figure
        hold on
        
        %
        auxinstrlist = var2instr(varcell{i1});
    
        % Loop over the instruments that
        % measure variable varcell{i1}:
        for i2 = 1:length(auxinstrlist)
            
            auxInstr = auxinstrlist{i2};
            
            pcolor(correctedData.(auxInstr).yday, ...
                   correctedData.(auxInstr).z, ...
                   correctedData.(auxInstr).varcell{i1});
        
        end
        
        shading flat, axis ij
        box on
        set(gca, 'FontSize', 14)
        
    
    
end
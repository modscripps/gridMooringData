function hfigs = plotMoorDataSection(correctedData, varcell)
% hfigs = PLOTMOORDATASECTION(correctedData, varcell)
%
%   inputs:
%       - correctedData: structure where each field is a structure (array)
%                        with data from a certain instrument type.
%       - varcell: cell array with variables to be plotted.
%
%   outputs:
%       - hfigs: vector of figure handles.
%
% Make time-depth pcolor plots of the mooring data (one plot/figure per
% variable). Input correctedData is the output of extraDataEditing.m. In
% other words, this input has the formatted mooring data, that is separated
% for each instrument on the mooring.
%
% Olavo Badaro Marques, 05/May/2017.


%% Types of instruments supported by this function:

% list_instr = {'SBE56', 'SBE39', 'SBE37', ...
%               'RBRSolo', 'RBRConcerto', ...
%               'AA', 'RDIadcp', 'MP'};
          
          
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


%% Pre-allocate 

Nfigs = length(varcell);

hfigs = gobjects(1, Nfigs);


%% Make plots:

% Loop over variables to plot (one plot per variable):
for i1 = 1:Nfigs
    
    %
    hfigs(i1) = figure;
    
        hold on
        
        % Use the map variable to see which instruments
        % measure variable varcell{i1}:
        auxInstrFromVar = var2instr(varcell{i1});
    
        % From auxInstrFromVar, select only those that
        % are present on the mooring data structure:        
        auxInstrList = intersect(fieldnames(correctedData), auxInstrFromVar);
        
        
        % Loop over the instruments that measure variable
        % varcell{i1} and add it to the plot:
        for i2 = 1:length(auxInstrList)
            
            auxInstr = auxInstrList{i2};
            
            nInstr = length(correctedData.(auxInstr));
            
            for i3 = 1:nInstr
                  
                zplt = correctedData.(auxInstr)(i3).z;
                    
                auxdataplot = correctedData.(auxInstr)(i3).(varcell{i1});
                
                % Create a matrix in case data is a vector:
                if size(auxdataplot, 1)
                    
                    zplt = [zplt-5; zplt];  %#ok<AGROW>
                    auxdataplot = repmat(auxdataplot, 2, 1);
                       
                end

                pcolor(correctedData.(auxInstr)(i3).yday, ...
                       zplt, auxdataplot);

            end
            
        end
        
        % Edit plot appearance:
        shading flat, axis ij
        box on
        set(gca, 'FontSize', 14)
        colorbar
        title(varcell{i1})
        
end


%% If no output is given, erase the variable such that
% the output variable is not printed on the screen:

if nargout==0
    clear hfigs
end
function loadedData = loadAllMoorData(moordir, moorsensors)
% loadedData = LOADALLMOORDATA(moordir, moorsensors)
%
%   inputs:
%       - moordir:
%       - moorsensors:
%
%   outputs:
%       - loadedData
%
% Olavo Badaro Marques, 11/Jul/2017.



          
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



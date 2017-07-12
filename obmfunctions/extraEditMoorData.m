function editedData = extraEditMoorData(lat, loadedData, moorsensors)
% editedData = EXTRAEDITMOORDATA(lat, loadedData, moorsensors)
%
%   inputs:
%       - lat: latitude.
%       - loadedData:
%       - moorsensors:
%
%   outputs:
%       - editedData:
%
%
%
% Olavo Badaro Marques, 11/Jul/2017.

%%

instrmntTypes = fieldnames(moorsensors);


%%
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
                              lat, moorsensors.(instrmntTypes{i1}){i2, 2});
    end
    
end
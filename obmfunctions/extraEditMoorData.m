function editedData = extraEditMoorData(lat, loadedData, moorsensors)
% editedData = EXTRAEDITMOORDATA(lat, loadedData, moorsensors)
%
%   inputs:
%       - lat: latitude (necessary to switch between depth and pressure).
%       - loadedData: data structure with the loaded data.
%       - moorsensors: structure with serial number and nominal
%                      depths of moored instruments.
%
%   outputs:
%       - editedData: data structure similar to the input, but
%                     formatted, following the toolbox standards.
%
% EXTRAEDITMOORDATA calls extraDataEditing.m, which formats the
% loaded data structure following the toolbox standards. This
% is only a necessary step because there are often NO standards
% when people offload data from different instruments. For
% example, it is not uncommon to see temperature saved as "t"
% from some instruments, but as "temp" for others.
%
% Look into the called function to see the specifics.
%
% See also: extraDataEditing.m
%
% Olavo Badaro Marques, 11/Jul/2017.


%% Get the instrument types for this mooring

instrmntTypes = fieldnames(moorsensors);


%% Loop over instruments and edit each of them

% Initialize output variable
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
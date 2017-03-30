function structoutvars = matchStructs(structvar1, structvar2)
% structoutvars = MATCHSTRUCTS(structvar1, structvar2)
%
%   inputs:
%       - structvar1: (scalar) structure variable.
%       - structvar2: another (scalar) structure variable.
%
%   outputs:
%       - structoutvars: 1x2 structure array.
%
% When creating a structure array, all elements must have the same
% number of fields and with the same names. MATCHSTRUCTS compares
% the field names of both inputs. Fields that exist in one input but
% not the other are added to later. The content in this newly created
% field is an empty (double) variable.
% 
% Olavo Badaro Marques, 30/Mar/2017.


%% Add empty fields to the structures
% so they both have the same fields:

fields1 = fieldnames(structvar1);
fields2 = fieldnames(structvar2);

fieldsNotin1 = setdiff(fields2, fields1);
fieldsNotin2 = setdiff(fields1, fields2);


for i = 1:length(fieldsNotin1)
    
    structvar1.(fieldsNotin1{i}) = [];
    
end

for i = 1:length(fieldsNotin2)
    
    structvar2.(fieldsNotin2{i}) = [];
end


%% Assign outputs:

% Order fields.
% This is not necessary for the concatenation below
% (as of Matlab 2015a), but looks as good coding practice:
structvar2 = orderfields(structvar2, fieldnames(structvar1));

% Assign the concatenation to output:
structoutvars = [structvar1, structvar2];

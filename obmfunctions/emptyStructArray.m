function outstruct = emptyStructArray(listfields, n)
% outstruct = EMPTYSTRUCTARRAY(listfields, n)
%
%   inputs:
%       - listfields: cell array with field names of the
%                     structure array to be created (such
%                     as the output of fieldnames.m).
%       - n: size of the structure array.
%
%   outputs
%       - outstruct: empty structure array of size n and
%                    fields listfields.
%
% Function EMPTYSTRUCTARRAY creates an empty structure of size n
% and fields listfields. It seems to me that this does not work
% effectively as a memory pre-allocation, but, at least, this
% function may help one to organize several 1x1 structure variables
% (with the same fields) into a structure array of size n.
%
% So far, I create 1xn structure vector, but could later adapt
% such that one can create a matrix of structures (which I have
% not used so far).
%
% Olavo Badaro Marques, 20/Jan/2017.


%% Create string that goes as the input of the function
% struct. For example, if this string looks like:
%           'field1', cell(1, n), 'field2', cell(1, n),
% Then outstruct is a 1xn struct array with fields field1 and field2.
% It is a bit ugly because I have to use eval on the struct function.

strcreatestruct = '';

% Loop over field names:
for i = 1:length(listfields)
    strappendaux = ['''' listfields{i} ''', cell(1, ' num2str(n) '),'];
    strcreatestruct = strcat(strcreatestruct, strappendaux); 
end

% Remove the comma at the end of the string:
strcreatestruct = strcreatestruct(1:end-1);


%% Create the empty structure array:

outstruct = eval(['struct(' strcreatestruct ');']);

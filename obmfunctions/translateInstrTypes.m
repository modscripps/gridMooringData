function listout = translateInstrTypes(listin)
% listout = TRANSLATEINSTRTYPES(listin)
%
%   inputs:
%       - listin: cell array with of strings with instrument types.
%
%   outputs:
%       - listout: cell array, same length as listin, with different
%                  strings associated with the same instruments.
%
% Function TRANSLATEINSTRTYPES has a list of instrument types (defined
% below). This function takes the input "listin" and, to each of its
% elements, associates a new string for the instrument type. It returns
% the result as the output "listout".
%
% The translation from one string to another is defined below. It was
% defined as it is in order to bridge the choices made by OBM with
% the definitions of ZZ. In particular, ZZ decided to make the toolbox
% count the number of instruments of the same type on the mooring (see
% AddInstrumentToMooring.m).
%
% OBM implemented (what he thinks) a more adaptable way of naming
% instruments. Using OBM's implementations, a much simpler and
% flexible AddInstrumentToMooring.m can be written. On the other hand,
% the field InstrumentList of the Mooring structure and the para_*
% fields of the MMP structure would have different names.
%
% Function TRANSLATEINSTRTYPES was written only to use OBM's changes
% but still complying with ZZ's instrument name definitions. If the
% suggestion of the last paragraph is followed, then function
% TRANSLATEINSTRTYPES has no more purpose.
%
% Olavo Badaro Marques.


%% Create a map object, creating the association between the entries
% of possibleInput and possibleOutput. If input does not match any
% entry of possibleInput, then output will be the same as input.
% Note that elements of valueOutput MUST not have lower case letters:

keyInput = {'RDIadcp', 'SBE37', 'SBE39', 'SBE56', 'RBRSolo', 'RBRConcerto'};
valueOutput = {'ADCP',   'SBE',   'SBE',   'SBE', 'RBRSOLO', 'RBRCONCERTO'};

instrumentMap = containers.Map(keyInput, valueOutput);


%% Assign to the output variable according to the map instrumentMap:

N = length(listin);

% Pre-allocate space for output
listout = cell(1, N);

% Loop over elements of the input:
for i = 1:N
    
    % Use map if listin{i} matches with
    % an element possibleInput:
    if any(strcmp(keyInput, listin{i}))
        
        listout{i} = instrumentMap(listin{i});
     
	% Otherwise, pass input to output
    % (with upper case letters only):
    else
        
        listout{i} = upper(listin{i});
        
    end
    
end




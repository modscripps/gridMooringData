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


%% Create a map object, creating the association between
% the entries of possibleInput and possibleOutput:

possibleInput = {'MP', 'RDIadcp', 'SBE37', 'SBE56', 'RBRSolo'};
possibleOutput = {'MP', 'ADCP',   'SBE',   'SBE',   'SBE'};

instrumentMap = containers.Map(possibleInput, possibleOutput);


%% Assign to the output variable according to the map instrumentMap:

N = length(listin);

% Pre-allocate space for output
listout = cell(1, N);

% Loop over elements of the input:
for i = 1:N
    
    % Assign to the output only if listin{i}
    % matches with an element possibleInput:
    if any(strcmp(possibleInput, listin{i}))
        
        listout{i} = instrumentMap(listin{i});
     
	% Otherwise, gives an error:
    else
        
        error(['Instrument type ' listin{i} ' has no '        ...
                'translation. You need to add ' listin{i} ' ' ...
                'to the possibleInput and possibleOutput '    ...
                'variables inside the function ' mfilename '.m.'])
        
    end
    
end




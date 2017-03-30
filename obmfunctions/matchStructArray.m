function outstructarray = matchStructArray(structarray, newstruct)
% outstructarray = MATCHSTRUCTARRAY(structarray, newstruct)
%
%   inputs:
%       - structarray: 1xN structure array (must be row vector).
%       - newstruct: (scalar) structure.
%
%   outputs:
%       - outstructarray: 1x(N+1) structure array with newstruct
%                         concatenated to the input array.
%
% MATCHSTRUCTARRAY calls matchStructs.m to concatenate
% a structure newstruct to the array structarray, where
% newstruct has a different set of fields than the array
% structarray.
%
% Olavo Badaro Marques, 30/Mar/2017.


%% Match newstruct with structarray(end):

structoutvars = matchStructs(structarray(end), newstruct);


%% Match the fields of all existing structures in
% structarray with the ones in structoutvars:

%
allfieldnames = fieldnames(structoutvars);

%
nnew = length(structarray) + 1;


%
if length(structarray)>1
    
    outstructarray = emptyStructArray(allfieldnames, nnew);
    
    arrayfieldnames = fieldnames(structarray(1));


    if ~isequal(sort(arrayfieldnames), sort(allfieldnames))
        
        
        for i = 1:(nnew-2)
            
            structaux = matchStructs(structarray(i), structoutvars(1));
            
            outstructarray(i) = structaux(1);

        end
        
    else
        
        structarray = orderfields(structarray, allfieldnames);
        
        outstructarray(1:(nnew-2)) = structarray;
        
        
    end

    outstructarray(nnew-1:end) = structoutvars;
    
else
    
    outstructarray = structoutvars;
    
    
end


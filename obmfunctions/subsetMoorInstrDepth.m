function submoorstruct = subsetMoorInstrDepth(moorsensors, moorstruct, depthran)
% submoorstruct = SUBSETMOORINSTRDEPTH(moorsensors, moorstruct, depthran)
%
%   inputs:
%       - moorsensors: structure with serial numbers and nominal
%                      depths from moored instruments.
%       - moorstruct: structure with mooring data, where each field
%                     is a type of instrument.
%       - depthran: 1x2 array with a depth range.
%
%   outputs:
%       - submoorstruct: subset of the input moorstruct, retaining
%                        only those instruments with nominal depth
%                        within depthran.
%
% SUBSETMOORINSTRDEPTH subsets the mooring data structure based on the
% nominal depth of the instruments. This code does NOT work with
% profiling instruments (i.e. they will never appear in the output).
%
% Olavo Badaro Marques, 11/Jul/2017.


%% Call inDepthRange.m to see which instruments
% have nominal depth within depthran

%
lstruct = inDepthRange(moorsensors, depthran);

%
instrlist = fieldnames(lstruct);

%
submoorstruct = emptyStructArray(instrlist, 1);


%% Subset mooring data structure

for i = 1:length(instrlist)
    
    submoorstruct.(instrlist{i}) = moorstruct.(instrlist{i})(lstruct.(instrlist{i}));
    
    % Remove fields when there are no instruments
    % of its type within depthran
    if isempty(submoorstruct.(instrlist{i}))
        submoorstruct = rmfield(submoorstruct, instrlist{i});
    end
    
end
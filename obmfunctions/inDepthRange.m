function [lstruct, submoorsensors] = inDepthRange(moorsensors, depthran)
% [lstruct, submoorsensors] = INDEPTHRANGE(moorsensors, depthran)
%
%   inputs:
%       - moorsensors: structure with serial numbers and nominal
%                      depths from moored instruments.
%       - depthran: 1x2 array with a depth range.
%
%   outputs:
%       - lstruct: struct array with logical values whether the instruments
%                  are in the depth range (true) or not (false).
%       - submoorsensors: structure array with the same fields as
%                         moorsensors, but only with the instrument with
%                         nominal depth within depthran.
%
% INDEPTHRANGE can be used to see which instruments have a nominal depth
% within a user-specified depth range.
% 
% This code does not work with profiling instruments because they have
% NaN as nominal depth (i.e. output lstruct is false for any profiling
% instrument).
%
% Olavo Badaro Marques, 11/Jul/2017.


%% Get input field names and initialize output variables

%
allInstr = fieldnames(moorsensors);

%
lstruct = emptyStructArray(allInstr, 1);
submoorsensors = emptyStructArray(allInstr, 1);


%% Loop over types instruments and instruments and
% check which have nominal depth within depthran

for i1 = 1:length(allInstr)
    
    for i2 = 1:length(moorsensors.(allInstr{i1}))
        
        %
        nomdepth_aux = [moorsensors.(allInstr{i1}){:, 2}];
        linrange = (nomdepth_aux >= depthran(1)) & (nomdepth_aux <= depthran(2));
        
        %
        lstruct.(allInstr{i1}) = linrange;
        
        %
        subsensors = moorsensors.(allInstr{i1})(linrange, :);
        
        if ~isempty(subsensors)
            submoorsensors.(allInstr{i1}) = subsensors;
        end

    end
    
    % Remove empty fields
    if isempty(submoorsensors.(allInstr{i1}))
        submoorsensors = rmfield(submoorsensors, allInstr{i1});
    end
end

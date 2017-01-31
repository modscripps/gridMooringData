function correctedData = correctKnockDownZ(interpObj, moorsensors, editedData)
% correctedData = CORRECTKNOCKDOWNZ(interpObj, moorsensors, editedData)
%
%   inputs:
%       - interpObj:
%       - moorsensors:
%       - editedData:
%
%   outputs:
%       - correctedData: data corrected by mooring knockdown.
%
% Function CORRECTKNOCKDOWNZ
%
% Olavo Badaro Marques, 30/Jan/2017.


%% Type of instruments to be corrected by the knockdown. Those
% are the instruments that do not (or MAY not) measure pressure.
% For example, SBE37 should measure pressure, but one may deploy
% one that does not have the pressure sensor:

instr_correct = {'SBE56', 'SBE39', 'RBRSolo', 'AA'};


%% Check which of the instruments in
% instr_correct are present on the mooring:

instrC = intersect(instr_correct, fieldnames(moorsensors));

if isempty(instrC)
    warning(['Mooring ' FP.SN ' has no instruments of the types in ' ...
             'the variable instr_correct, those we want to correct ' ...
             'for knockdown. No knockdown correction applied.'])
         
else
    
    
    % First we check how many instruments
    % of each type will be corrected:
    ninstr = NaN(length(instrC), 1);

    for i = 1:length(instrC)
        ninstr(i) = size(moorsensors.(instrC{i}), 1);
    end
    
    % this block may be useless!!!
    
    %% Apply the mooring knockodown correction:
    
    for i1 = 1:length(instrC)
       
        for i2 = 1:ninstr(i1)
            
            editedData.(instrC{i}).z = ...
                        interpObj.interpxy(editedData.(instrC{i}).yday, ...
                                           editedData.(instrC{i}).z);
            
%             editedData.(instrC{i}).z = interpxy(interpObj, ...
%                                            editedData.(instrC{i}).yday, ...
%                                            editedData.(instrC{i}).z);
            
        end
        
    end
    
    correctedData = editedData;
    
end
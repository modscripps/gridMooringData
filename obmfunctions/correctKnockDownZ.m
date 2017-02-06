function correctedData = correctKnockDownZ(interpObj, moorsensors, editedData, timegrid)
% correctedData = CORRECTKNOCKDOWNZ(interpObj, moorsensors, editedData)
%
%   inputs:
%       - interpObj:
%       - moorsensors:
%       - editedData:
%       - timegrid (optional):
%
%   outputs:
%       - correctedData: data corrected by mooring knockdown.
%
% Function CORRECTKNOCKDOWNZ organizes the data for the mooring
% knockdown correction. The calculation itself is performed by
% the object interpObj. If you want to see how the interpolation
% is done, you should look at interp1class.m
%
% If data is high resolution and lreg is false, then the correction
% will be done separately for each instrument (for the different
% timestamps of each instrument) and it might take a very(!) long time.
% 
%
% Olavo Badaro Marques, 30/Jan/2017.


%% Type of instruments to be corrected by the knockdown. Those
% are the instruments that do not (or MAY not) measure pressure.
% For example, SBE37 should measure pressure, but one may deploy
% one that does not have the pressure sensor:

instr_correct = {'SBE56', 'SBE39', 'SBE37', 'RBRSolo', 'AA'};


%% Match instrument types on the mooring with those in instr_correct:

instrC = intersect(instr_correct, fieldnames(moorsensors));

%
if isempty(instrC)
    warning(['Mooring ' FP.SN ' has no instruments of the types in ' ...
             'the variable instr_correct, those we want to correct ' ...
             'for knockdown. No knockdown correction applied.'])
         
else
    
    % Check how many instruments of each type will be corrected:
    ninstr = NaN(length(instrC), 1);

    for i = 1:length(instrC)
        ninstr(i) = size(moorsensors.(instrC{i}), 1);
    end
    
    
    %% Apply the mooring knockodown correction

    if exist('timegrid', 'var')
    %% If there is a common timegrid, then do the
    % correction for all instruments together:
       
        % First get a timebase:
        
        nomdepths = NaN(sum(ninstr), 1);
        
        posnomdepths = cell(sum(ninstr), 2);
        
        for i1 = 1:length(instrC)
       
            for i2 = 1:ninstr(i1)

                % Only interpolate if field z is a scalar. This is done to
                % distinguish from instruments that may or may not measure
                % pressure. For example, a regular SBE37 measures pressure
                % and at this time would have a time series of z. However,
                % if it did not have a pressure sensor, then it would only
                % have a scalar z:
                if isscalar(editedData.(instrC{i1})(i2).z)

                        indnext = find(isnan(nomdepths), 1, 'first');
                        nomdepths(indnext) = editedData.(instrC{i1})(i2).z;
                        posnomdepths{indnext, 1} = instrC{i1};
                        posnomdepths{indnext, 2} = i2;
                        
                        if strcmp(instrC{i1}, 'SBE37')
                            wanrning('!!!!!')
                            keyboard
                        end
                        
                end
            end
        end
        
        posnomdepths = posnomdepths(~isnan(nomdepths), :);
        nomdepths = nomdepths(~isnan(nomdepths));
        
        % Do the interpolation for the depth correction:
        zcorrection = interpObj.interpxy(timegrid, nomdepths);
        
        % Now assign the interpolated depth corrections
        % to the appropriate variables:
        for i = 1:size(posnomdepths, 1)
            
            aux1 = posnomdepths{i, 1};  % type of instrument
            aux2 = posnomdepths{i, 2};  % index of the instrument
            
            editedData.(aux1)(aux2).z = zcorrection(i, :);
                                                     
            if length(timegrid)~=length(editedData.(aux1)(aux2).yday)
                
                % I need all types of instruments to have the field
                % time -- this must be done in extraDataEditting.m
                editedData.(aux1)(aux2).t = ...
                               interp1(editedData.(aux1)(aux2).time, ...
                                       editedData.(aux1)(aux2).t,    ...
                                       timegrid);

                editedData.(aux1)(aux2).yday = datenum2yday(timegrid); 
                
            end
        end

        
    else
	%% If there is no common timegrid, then interpolate depth
    % separately for each instrument onto their own timestamps:
    
%         warning()   % might want to give a warning that
%                     % this might take a long time
        
        for i1 = 1:length(instrC)    % Loop over instrument types
            for i2 = 1:ninstr(i1)    % Loop over instruments

                if isscalar(editedData.(instrC{i}).z)

                        editedData.(instrC{i}).z = ...
                                interpObj.interpxy(editedData.(instrC{i}).yday, ...
                                                   editedData.(instrC{i}).z);
                end

            end
        end
        
    end
    
    % Assign output:
    correctedData = editedData;
    
end
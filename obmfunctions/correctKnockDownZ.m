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


%% Types of instruments that usually measure pressure,
% but may have been deployed without measuring it.
% This list is used below to warn the user that, if these
% are the only instruments to correct for knockdown, maybe
% there is no correction to be applied, in the case they
% measured pressure:

instr_maybe_pres = {'SBE39', 'SBE37'};


%% List of measured quantities that should be corrected by the
% knowckdown. E.g. temperature and velocity are corrected, but
% yearday is not:

vars_correct = {'t', 's', 'sgth', 'u', 'v', 'w'};


%% Match instrument types on the mooring with those in instr_correct:

instrC = intersect(instr_correct, fieldnames(moorsensors));

%
if isempty(instrC)
    
    warning(['Mooring has no instruments of the types ' ...
             '' strjoin(instr_correct, ', ') ', the ones that may ' ...
             'need to be corrected for knockdown. No knockdown ' ...
             'correction applied.'])
         
	% Assign output:
    correctedData = editedData;
         
else
    
    % Print warning to the user if the only types of instruments
    % to be corrected, are the ones listed in instr_maybe_pres:
    if isequal(sort(instrC), sort(instr_maybe_pres))
        
        warning(['Instruments on mooring to correct for knockdown ' ...
                 'are of the types ' strjoin(instr_maybe_pres, ', ') ''...
                 '. The correction is only applied if they do not ' ...
                 'already measure pressure'])
    end
    
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
                                                
                end
            end
        end
        
        posnomdepths = posnomdepths(~isnan(nomdepths), :);
        nomdepths = nomdepths(~isnan(nomdepths));
        
        % Do the interpolation for the depth correction:
        zcorrection = interpObj.interpxy(timegrid, nomdepths);
        
        % Now assign the interpolated depth corrections
        % to the appropriate variables:
        for i1 = 1:size(posnomdepths, 1)
            
            aux1 = posnomdepths{i1, 1};  % type of instrument
            aux2 = posnomdepths{i1, 2};  % index of the instrument
            
            editedData.(aux1)(aux2).z = zcorrection(i1, :);
                                                     
            if length(timegrid)~=length(editedData.(aux1)(aux2).yday)
                
                % Fill yday field Convert timegrid to yday:
                editedData.(aux1)(aux2).yday = datenum2yday(timegrid); 

                % Get all the fieldnames and only interpolate
                % the fields that match with vars_correct:
                auxfields = fieldnames(editedData.(aux1)(aux2));
                
                % Loop over the list of variables to interpolate:
                for i2 = 1:length(vars_correct)
                    
                    auxi2var = vars_correct{i2};
                    
                    % Only interpolate if field name
                    % matches one in auxfields:
                    if any(strcmp(auxfields, auxi2var))
                        
                        editedData.(aux1)(aux2).(auxi2var) = ...
                            interp1(editedData.(aux1)(aux2).time,       ...
                                    editedData.(aux1)(aux2).(auxi2var), ...
                                                               timegrid);
                                                           
                        % I need all types of instruments to have the field
                        % "time": this can be done in extraDataEditting.m

                    end    
                end
                
                
            else
                warning('Can this ever happen???? I think this can almost never happen')
                keyboard
                
            end
        end

        
    else
	%% If there is no common timegrid, then interpolate depth
    % separately for each instrument onto their own timestamps:

%   THIS IS NOT FINISHED!
%         warning()   % might want to give a warning that
%                     % this might take a long time
%         
%         for i1 = 1:length(instrC)    % Loop over instrument types
%             for i2 = 1:ninstr(i1)    % Loop over instruments
% 
%                 if isscalar(editedData.(instrC{i}).z)
% 
%                         editedData.(instrC{i}).z = ...
%                                 interpObj.interpxy(editedData.(instrC{i}).yday, ...
%                                                    editedData.(instrC{i}).z);
%                 end
% 
%             end
%         end
        
    end
    
    % Assign output:
    correctedData = editedData;
    
end
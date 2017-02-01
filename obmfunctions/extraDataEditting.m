function datainstr = extraDataEditting(datainstr, datatype, lat, nomdepth)
% datainstr = EXTRADATAEDITTING(datain, datatype)
%
%   inputs:
%       - datainstr: data structure of an instrument on a mooring.
%       - datatype: type of instrument, as defined by the script with
%                   info for all instruments on the mooring.
%       - latitude: latitude, required to convert pressure into depth.
%
%   outputs:
%       - datainstr: data structure with additional editting/processing.
%
% Function EXTRADATAEDITTING does some minor editting such as:
% transposing and renaming variables; removing NaNs;
% estimating depth from pressure (using the seawater toolbox)
% as well as salinity/potential density when conductivity is measured.
%
% It is important that any time series in a vector (as opposed to
% a matrix, where each column is a different time) is output by
% this function as a ROW vector.
%
% IMPORTANT NOTE: in the editting below, some assuptions are made
%                 about the format of the data. The format may
%                 be defined by the MOD group data processing routines.
%                 There is a chance that data that has not been
%                 processed by those routines will not be editted
%                 correctly by the function EXTRADATAEDITTING.
%
% Olavo Badaro Marques.


%% For each type of instrument does a different of editting:

switch datatype

    case 'SBE37'
        
        % Make sure vectors are row vector, rename
        % variables and compute yday from datenum:
        datainstr.time = datainstr.time(:)';
        datainstr.yday = datenum2yday(datainstr.time);
        datainstr.t = datainstr.T(:)';
        
        datainstr = rmfield(datainstr, 'T');
        
        % MAKE SURE THAT SBE37 HAS MEASURED PRESSURE!!!
        
        % Compute depth from pressure:
        datainstr.P = datainstr.P(:)';
        datainstr.z = sw_dpth(datainstr.P, lat);
                       
        % NaN conductivities less than or equal to 0
        % (otherwise there might be complex density values):
        datainstr.C = datainstr.C(:)';
        datainstr.C(datainstr.C<=0) = NaN;
        
        % Compute salinity (including a factor of 10 to get
        % the units right) and potential density (referenced
        % to the surface):
        datainstr.s = sw_salt(10*datainstr.C ./ sw_c3515, datainstr.t, datainstr.z);
        datainstr.sgth = sw_pden(datainstr.s, datainstr.t, datainstr.P, 0) - 1000;


    case 'SBE39'

        % Make sure vectors are row
        % vector and rename variables:
        datainstr.yday = datainstr.yday(:)';
        datainstr.t = datainstr.temp(:)';
        
        datainstr = rmfield(datainstr, 'temp');
        
        % SBE39 THESE HAVE PRESSURE SENSORS SOMETIMES!!!
        
	case 'SBE56'

        % Make sure vectors are row vector, rename
        % variables and compute yday from datenum:
        datainstr.time = datainstr.time(:)';
        datainstr.yday = datenum2yday(datainstr.time);
        datainstr.t = datainstr.T(:)';
        datainstr.z = nomdepth;
        
        datainstr = rmfield(datainstr, 'T');
        
    case 'RBRSolo'
        
        % Make sure vectors are row vector, rename
        % variables and compute yday from datenum:
        datainstr.time = datainstr.time(:)';
        datainstr.yday = datenum2yday(datainstr.time);
        datainstr.t = datainstr.T(:)';        
        datainstr.z = nomdepth;
        
        datainstr = rmfield(datainstr, 'T');
        
    case 'RBRConcerto'

     
    case 'AA'
        
        % Make sure vectors are row vector
        % and compute yday from datenum:
        datainstr.yday = datenum2yday(datainstr.time(:))';
        datainstr.z = nomdepth;
        
    case 'RDIadcp'

%         this does not make any sense! It seems the explanation might
%         be the datenum2yday does not take NaN as input...
%         datainstr.yday(find(isnan(ADCP_TOP.yday)))=datenum2yday(ADCP_TOP.dtnum(find(isnan(ADCP_TOP.yday))));
        
    case 'MP'
        
        
    otherwise
        
        warning(['Data of type ' instrtype ' has not been implemented' ...
                 ' ' mfilename '. Add a new case block in this function.'])

end


%% Removed observation when timestamps are repeated. It has
% happened before (for SBE56s) to have a few instances of
% repeated timestamps. "A few" is usually a handful of data
% points. In this case, just keep the first measurement:

if length(datainstr.yday) ~= length(unique(datainstr.yday))
            
%     % Print a warning meassage:
%     warning(['SBE56 with serial number ' num2str(ithsn) ' has ' ...
% num2str(length(SBE56aux.yday) - length(unique(SBE56aux.yday))) '' ...
%              ' repeated time stamps.'])

    % Get rid of values at repeated time stamps:
    [datainstr.yday, indmkuniq, ~] = unique(datainstr.yday);
    
    datainstr.time = datainstr.time(indmkuniq);
    datainstr.t = datainstr.t(indmkuniq);
%     datainstr.z = datainstr.z(indmkuniq);
    
    % This should be done better....

end
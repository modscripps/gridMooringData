function datainstr = extraDataEditing(datainstr, datatype, lat, nomdepth)
% datainstr = EXTRADATAEDITING(datain, datatype)
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
% Function EXTRADATAEDITING does some minor editting such as:
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
%                 correctly by the function EXTRADATAEDITING.
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
        
        % If the SBE37 had a pressure sensor, use it.
        % Otherwise use nominal depth.
        if isfield(datainstr, 'P')
            
            if isempty(datainstr.P)
                datainstr.P = NaN(size(datainstr.t));
                datainstr.z = nomdepth;
            else
                datainstr.P = datainstr.P(:)';
                datainstr.z = sw_dpth(datainstr.P, lat);
            end
            
        else
        % Otherwise assign nominal depth to depth:
        
            datainstr.P = NaN(size(datainstr.t));
            datainstr.z = nomdepth;
            
        end
                       
        % NaN conductivities less than or equal to 0
        % (otherwise there might be complex density values):
        datainstr.C = datainstr.C(:)';
        datainstr.C(datainstr.C<=0) = NaN;
        
        % Compute salinity and potential density
        % (referenced to the surface):
        datainstr.s = computeS(datainstr.C, datainstr.t, datainstr.P);
        datainstr.sgth = sw_pden(datainstr.s, datainstr.t, datainstr.P, 0) - 1000;


    case 'SBE39'

        % Add a field called "time":
        datainstr.time = datainstr.dtnum;
        
        % Make sure vectors are row
        % vector and rename variables:
        datainstr.time = datainstr.time(:)';
        datainstr.yday = datainstr.yday(:)';
        datainstr.t = datainstr.temp(:)';
        
        % If the SBE39 recorded pressure,
        % change its name and compute depth:
        if isfield(datainstr, 'pr')
            
            if isempty(datainstr.pr)
                datainstr.P = NaN(size(datainstr.t));
                datainstr.z = nomdepth;
            else
                datainstr.P = datainstr.pr;
                datainstr.z = sw_dpth(datainstr.P, lat);
            end
            
            datainstr = rmfield(datainstr, 'pr');
        else
        % Otherwise assign nominal depth to depth:
        
            datainstr.P = NaN(size(datainstr.t));
            datainstr.z = nomdepth;
            
        end
        
        % Make sure they are row vectors:
        datainstr.P = datainstr.P(:)';
        datainstr.z = datainstr.z(:)';
        
        datainstr = rmfield(datainstr, 'temp');
        
        
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
        
        % Make sure variables are row vectors:
        datainstr.time = datainstr.time(:)';
        
        % add yday:
        datainstr.yday = datenum2yday(datainstr.time);
        
        %
        datainstr.C = datainstr.C(:)';
        datainstr.C(datainstr.C<=0) = NaN;
        
        datainstr.t = datainstr.T;
        datainstr.t = datainstr.t(:)';
        datainstr = rmfield(datainstr, 'T');
        
        % Compute depth from pressure and latitude:
        datainstr.P = datainstr.P(:)';
        datainstr.z = sw_dpth(datainstr.P, lat);
        
        % Compute salinity and potential density
        % (referenced to the surface):
        datainstr.s = computeS(datainstr.C, datainstr.t, datainstr.P);
        datainstr.sgth = sw_pden(datainstr.s, datainstr.t, datainstr.P, 0) - 1000;
        
        
    case 'AA'
        
        % Make sure vectors are row vector
        % and compute yday from datenum:
        datainstr.yday = datenum2yday(datainstr.time(:))';
        datainstr.z = nomdepth;
        
    case 'RDIadcp'

        % no editing for RDIadcp
        
    case 'MP'
        
        % no editing for McLane Profiler
        
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
    
    datainstr.t = datainstr.t(indmkuniq);
    
    datainstr.time = datainstr.time(indmkuniq);
%     datainstr.z = datainstr.z(indmkuniq);
    
    % This should be done better....

end

end


%% Nested function to compute Salinity from Conductivity.
% This is written as a separate function, to be able to
% in the same way for all instruments.
%
% It also includes an ATTEMPT of identification of the units of
% Conductivity, because instruments return it in units that
% usually differ by 10. This will probably NOT work where there is
% significant freshwater (near estuaries). This may not work
% if there are too many data points when the instrument was
% out of the water.

function s = computeS(c, t, p)

    % Factor to multiply the conductivity, so it is in mS/cm.
    if nanmedian(c) > 10
        cfactor = 1;
    else
        cfactor = 10;
    end
    
    % Using the Gibbs-SeaWater (GSW) Toolbox
    s = gsw_SP_from_C(c .* cfactor, t, p);

%     % Using the SeaWater toolbox (deprecated)
%     s = sw_salt((c.*cfactor) ./ sw_c3515, t, p);

end



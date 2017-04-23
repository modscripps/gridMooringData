function MMP = DoHarmonicToMMP( MMP, FP )
%function MMP = DoHarmonicToMMP( MMP, FP )
%   does harmonic analysis and extracts tidal constituents 
%   using toolbox package t_tide
%   
%   INPUT: MMP
%   
%   Parameters: FP
%       FP.RefTime:  yday(default)
%       VarNames:    data fields
%       band:        M2, S2, O1, K1
%
%   OUTPUT: MMP
%       original data fields are replaced with 
%       harmonically analyzed ones
%   
% see also FiltingMMP
%
% ZZ @ APL-UW 03-22-2010


%% display the calling
disp(['Calling function ' mfilename])


%% check FP and its parameters
%% FP
if ~exist( 'FP', 'var' )
    FP = struct;
end

%% FP.RefTime
if ~isfield(FP, 'RefTime')
    FP.RefTime = 'yday';
end

%% FP.VarNames
if ~isfield(FP, 'VarNames' )
    FP.VarNames = {'u'; 'v'; 'eta'};
end

%% FP.BandName
if ~isfield(FP, 'FreqBand')
    FP.FreqBand = 'M2';
end

%% check MMP and update FP.VarNamesToShow
checkList = zeros( size(FP.VarNames) );
for idx = 1 : length(FP.VarNames)
    if isfield(MMP, FP.VarNames(idx) ), checkList(idx) = 1; end
end
checkList = find( checkList );
FP.VarNames = {FP.VarNames{checkList}};

%% save parameters
MMP.para_harmonic = FP;
MMP.FreqBand      = FP.FreqBand;


%% start running
for idx_var = 1 : length( FP.VarNames )
    varname = FP.VarNames{idx_var};
    disp(['  Working on ' varname])
    
    %% create a data field of nan
    MMP.([varname MMP.FreqBand]) = nan( size(MMP.(varname)) );
    
    %% change from yearday to date number
    TIME = MMP.(FP.RefTime) + datenum(MMP.year, 1, 1);

    %% delta time in hours        
    delta_hour = nanmean( diff(MMP.(FP.RefTime)) ) * 24;
    
    %% loop for each depth
    for iz = 1 : length(MMP.z)
        iz;
        xin = MMP.(varname)(iz, :);
        gd  = find( ~isnan( xin ) );
                
        if length( gd ) > 0.3*length(xin)
            [NAME, FREQ, TIDECON, OUT] = t_tide( xin, 'interval', ...
                delta_hour, 'start time', TIME(1), 'output', 'none' );
            
            %% Now predict for single tidal constituent
            %             idx = find_in_NAME( NAME, MMP.FreqBand );
            idx = find(strcmp(cellstr(NAME),MMP.FreqBand)==1);
            xout = t_predic(TIME, NAME(idx,:), FREQ(idx), TIDECON(idx,:) );
            MMP.([varname MMP.FreqBand])(iz, :) = xout;
        end
    end
    
    MMP.(varname) = MMP.([varname MMP.FreqBand]);
    MMP = rmfield( MMP, [varname MMP.FreqBand]);
end

return
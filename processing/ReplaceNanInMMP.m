function MMP = ReplaceNanInMMP( MMP, FP )
%function MMP = ReplaceNanInMMP( MMP, FP )
%   replaces nans in MMP.(FP.VarNames).
%   NaNs could appear in three locations: top, bottom, and middle
%   
%   FP.VarNames: what variables to work on 
%   
%   Note: middle: linear interp;
%         top:    replace top nans using the first good data
%         bottom: replace bottom nans using the last good data
%
%   FP.where specify where the replacement applies
%         'top', 'bottom', 'middle' can combine 
%   
%
% ZZ @ APL-UW, April 19th, 2010
% ZZ @ APL-UW, May 17th, 2011
% ZZ @ APL-UW, December 2011


%% display 
disp(['Calling function ' mfilename])

%% FP 
if ~exist( 'FP', 'var')
    FP = struct;
end

%% FP.VarNames
if ~isfield( FP, 'VarNameList' )
    FP.VarNameList = {'u'; 'v'};
end

%% FP.where
if ~isfield( FP, 'where')
    FP.where = 'top-bottom-middle';
end
%% FP.BottomMean
if ~isfield( FP, 'BottomMean')
    FP.BottomMean = 1;
end

%% FP.good_percent
if ~isfield( FP, 'good_percent')
    FP.good_percent = 0.6;
end


%% check DATA and DATA.VarNames
checkList = zeros( size(FP.VarNameList) );
for idx = 1 : length(FP.VarNameList)
    if isfield(MMP, FP.VarNameList(idx) ), checkList(idx) = 1; end
end
checkList = find( checkList );
FP.VarNameList = {FP.VarNameList{checkList}};

%% convert to lower case
FP.where = lower( FP.where ); 


%% filling nans in the interior of one profile using
%% linear interpolation
if strfind( FP.where, 'middle')
    for idx_var = 1 : length( FP.VarNameList )
        varname = FP.VarNameList{idx_var};
        
        number_good = sum( ~isnan(MMP.(varname) ), 1 );
        MAX = nanmax( number_good );
        idx_SOME_GOOD = find( number_good > FP.good_percent * MAX );
        
        for idx_yday = idx_SOME_GOOD
            data = MMP.(varname)(:, idx_yday);
            idx_good = find( ~isnan(data) );

            MMP.(varname)(:, idx_yday) = ...
                       interp1( MMP.z(idx_good), data(idx_good), MMP.z );
        end
    end
end

%% filling nans at the bottom of a profile using 
%% the last one good data
if strfind( FP.where, 'bottom')
    for idx_var = 1 : length( FP.VarNameList )
        varname = FP.VarNameList{idx_var};
        number_good = sum( ~isnan(MMP.(varname) ), 1 );
        MAX = nanmax( number_good );
        idx_SOME_GOOD = find( number_good > FP.good_percent * MAX );
        
        for idx_yday = idx_SOME_GOOD
            data = MMP.(varname)(:, idx_yday);
            len  = length(data);
            idx_good = find( ~isnan(data) );
            idx_last = idx_good(end);

            if any( strcmp(varname, {'n2' 'u' 'v'}) ) %% mean
                FillData = nanmean( data(idx_good(end-FP.BottomMean+1:end)) );            
                data(idx_last+1:end) = FillData;
            %linear extrapolation (not good, return back to tapering)
            elseif any(strcmp(varname, {'eta' 't' })) %% linear extrapolation                            
                zgood = MMP.z(idx_last:-1:idx_last-20);
                gdata =  data(idx_last:-1:idx_last-20);
                [P,S] = polyfit(zgood, gdata, 1);
                bttom = MMP.z(idx_last:end);
                [Y, DELTA] = polyval(P, bttom, S);
                data(idx_last:end) = Y;
           % replaced with above codes (tried, returned)            
%             elseif any(strcmp(varname, {'eta' 't'}))
%                data(idx_last+1:len) = ...
%                    interp1( [idx_last len], [data(idx_last) 0], idx_last+1:len);
            end
            MMP.(varname)(:, idx_yday) = data;
        end
    end
end

%% filling nans at the top of one profile using 
%% the first one good data 
if strfind( FP.where, 'top')
    for idx_var = 1 : length( FP.VarNameList )
        varname = FP.VarNameList{idx_var};
        number_good = sum( ~isnan(MMP.(varname) ), 1 );
        MAX = nanmax( number_good );
        idx_SOME_GOOD = find( number_good > FP.good_percent * MAX );
        
        for idx_yday = idx_SOME_GOOD
            data = MMP.(varname)(:, idx_yday);
            idx_good = find( ~isnan(data) );
            idx_first = idx_good(1);
            
            if idx_first > 1
                if any(strcmp(varname, {'n2' 'eta'})) %for n2 or eta
                    data(1:idx_first) = ...
                interp1( [1 idx_first], [0 data(idx_first)], 1:idx_first);
                elseif any(strcmp(varname, {'u' 'v'})) %for u, v,
                    data(1:idx_first) = data(idx_first);
                end
                MMP.(varname)(:, idx_yday) = data;
            end
        end
    end
end

return
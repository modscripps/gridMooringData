function MMP = AddN2ToMMP( MMP, FP)
%function MMP = AddN2ToMMP( MMP, FP)
%   computates N2 from MMP.z, MMP.s, MMP.t
%   
%   Input:
%     MMP structure
%       MMP.yday     yday
%       MMP.t        temperature, degree
%       MMP.s        salinity, psu
%       MMP.z        depth (pressure), m (dbar)
% 
%     FP parameters
%       FP.window     smoothing over FP.window
%       FP.vsmooth    (default=3) vertical smooth on numbder of points
%       FP.bound      remove boundary layers
%
%   Output:
%       MMP.para_N2     para parameters
%       MMP.n2          time-variable (rad/s)^2
%
% ZZ @ APL-UW, March 16th, 2010
% ZZ @ APL-UW, June 12th, 2010
% ZZ @ APL-UW, July 30th, 2011
% ZZ @ APL-UW, August 11th, 2011


%%
disp( ['Calling function ' mfilename ])


%% check FP and its parameters
%% FP
if ~exist('FP', 'var' )
    FP = struct;
end
%% FP.window
if ~isfield( FP, 'window')
    yday = MMP.yday;
    FP.window = nanmax(yday)-nanmin(yday);  
end
%% FP.vsmooth
if ~isfield( FP, 'vsmooth')
    FP.vsmooth = 3;  % 3-point vertical smooth
end
%% FP.bound
if ~isfield( FP, 'bound' )
    FP.bound = 0;    % how many boundary layers to remove 
end

%% FP parameters
MMP.para_n2 = FP;

%%
warning off

%% length of time series
Len_yday = nanmax(MMP.yday) - nanmin(MMP.yday);

%% Method 1
%% calculate the mean using given window
if  FP.window < Len_yday
    VarNames = {'t'; 's'};
    for idx_var = 1 : 2
        %% DATA
        DATA = MMP.(VarNames{idx_var});  
        OUT  = DATA; 
        
        %% number of points of time-average
        NumOfPrf = round( FP.window / nanmean( diff(MMP.yday) ) );
        halfNumOfPrf  = round(NumOfPrf/2);
        COLUMN = size(DATA, 2);
        
        for idx = 1 : COLUMN
            if idx <= halfNumOfPrf
                OUT(:, idx) = nanmean( DATA(:, 1:NumOfPrf), 2);
            elseif idx >= COLUMN-halfNumOfPrf
                OUT(:, idx) = nanmean( DATA(:, end-NumOfPrf+1:end), 2);
            else
                OUT(:, idx) = nanmean( DATA(:, idx-halfNumOfPrf:idx+halfNumOfPrf), 2);
            end
        end
             
        %% save the time-variable mean
        eval([VarNames{idx_var} '= OUT;']);
    end
end

%% Method 2: all together if shorter
if  FP.window >= Len_yday
    VarNames = {'t'; 's'};
    for idx_var = 1 : 2
        %% DATA
        DATA = MMP.(VarNames{idx_var});  
        OUT  = nanmean( DATA, 2);
        OUT  = repmat( OUT, 1, length(MMP.yday) );
        eval([VarNames{idx_var} '= OUT;']);
    end   
end


%% vertical smooth
for idx_var = 1 : 2
    eval(['DATA = ' VarNames{idx_var} ';'])
    OUT = DATA;
    
    %% smooth vertically
    vsmooth = FP.vsmooth;
    halfvsmooth = fix(FP.vsmooth/2);
    LAYER = size(DATA, 1);
    
    for idx = 1 : LAYER
        if idx <= halfvsmooth
            OUT(idx, :) = nanmean( DATA(1:vsmooth, :), 1);
        elseif idx >= LAYER-halfvsmooth
            OUT(idx, :) = nanmean( DATA(end-vsmooth+1:end, :), 1);
        else
            OUT(idx, :) = nanmean( DATA(idx-halfvsmooth:idx+halfvsmooth, :), 1);
        end
    end   
    
    %% save the time-variable mean
    eval([VarNames{idx_var} '= OUT;']);
end  
    
%% check to remove layers of all-nan in raw data
for iz = 1 : length(MMP.z)
    VarNames = {'t'; 's'};
    for idx_var = 1 : 2
        %% DATA
        DATA = MMP.(VarNames{idx_var});
        data = DATA(iz,:);
        if all(isnan(data))
            eval([VarNames{idx_var} '(iz,:) = nan;']);
        end
    end
end

%% from s and t to sgth_smooth
for idx_var = 1 : 2
   vname = VarNames{idx_var};
   eval(['MMP.' vname '_smooth = ' vname]);
end

%% calculate n2 from t, s, and z(or p)
MMP.n2 = nan( length(MMP.z), length(MMP.yday) );
for idx_time = 1 : length( MMP.yday )
    %% calling function
    [BVFRQ, Pbar, N2] = bvfreq( s(:,idx_time), t(:,idx_time), MMP.z );
    %% where n2<0, --> nan
    N2( N2<0 ) = nan;
    %% save to MMP
    MMP.n2(:, idx_time) = interp1(Pbar, N2, MMP.z);
end

%% check boundary layers
data = nanmean( MMP.n2, 2 ); %mean profile 
ibad = isnan( data );        %bad data 
for idx = 1 : FP.bound
    shift = [ibad [1; ibad(1:end-1)] [ibad(2:end); 1] ]; %three columns 
    ibad = any(shift==1, 2);
end
MMP.n2(ibad, :) = nan;

%%
warning on;

return
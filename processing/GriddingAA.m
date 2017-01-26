function MMP = GriddingMMP(MMP, FP)
%function MMP = GriddingMMP(MMP, FP)
%   grids MMP.(FP.VarNames) onto time-/z-grid
%
%   Input:
%       MMP: data structure
%       FP:  parameters
% 
%   Usage: 
%      Standard grid is provided by FP.yday_grid and FP.z_grid
%      If no FP.yday_grid, it is constructed from MMP.yday
%      If no FP.z_grid,    it is constucted  from MMP.z
%
%      FP.OriginalTime is for original yday in MMP
%        'yday'  for general-case ADCP/VEL/SBE
%        'ydayc' for the profiling MP 
%
%   Output:
%      gridded data fields in MMP
%      MMP.yday_grid, MMP.z_grid, and MMP.varname_grid
%
%   Step 1: interpolate on yday_grid,
%   Step 2: interpolate on z_grid,
%   Step 3: conditinally (FP.trim) trim column and layer with all NaN
%   
%   NOTE: 
%       This program has codes to check the interval between gridded 
%       data and raw data. If the minimal raw data is too far,
%       this new data is set to be nan.
%       The check is done for yday_grid and z_grid
%
% ZZ @ APL-UW, March 12th, 2010
% ZZ @ APL-UW, April 23rd, 2010
% ZZ @ APL-UW, February 25th, 2011
% BSB @ APL-UW, 30 July 2015 - modified to accept tlogger salinity

%% temporally transfer this parameter this way, 
%% may need be modified in future

%% display
disp(['Calling function ' mfilename])


%% check FP and its parameters
%% FP
if ~exist('FP', 'var')
    FP = struct;
end

%% FP.OriginalTime 
if ~isfield(FP, 'OriginalTime')
    disp(' !! No FP.OriginalTime. Run FP.OriginalTime = ydayc;')    
    %% use MMP.ydayc
    FP.OriginalTime = 'ydayc';
end

%% FP.yday
if ~isfield(FP, 'yday_grid' )
    disp(' !! No FP.yday_grid.')
    disp(' Constructing  yday_grid from MMP.yday or MMP.ydayc ')
    
    %% ydayc -> yday
    if ~isfield( MMP, 'yday')
        if isfield( MMP, 'ydayc')
            MMP.yday = MMP.ydayc(1, :);
        else
            disp(' !! No yday or ydayc')
        end
    end
    
    %% yday -> yday_grid
    if length( MMP.yday ) > 1
        dt = nanmean( diff(MMP.yday) );
        FP.yday_grid  = nanmin(MMP.yday) : dt : nanmax(MMP.yday); 
    else
        FP.yday_grid = MMP.yday;
    end
end

%% FP.z
if ~isfield(FP, 'z_grid' )
    disp(' !! no FP.z_grid, ')
    disp(' Constructing z_grid from MMP.z ')
    
    %% z -> z_grid
    if length( MMP.z ) > 1
        dz = nanmean( diff(MMP.z) );
        FP.z_grid = nanmin( MMP.z ) : dz : nanmax( MMP.z ); 
    else
        FP.z_grid = MMP.z;
    end
end

%% check FP.trim
if ~isfield(FP, 'trim' )
    disp(' !! No FP.trim')
    disp(' Using FP.trim = 0, no delete columns/layers of all nan')
    FP.trim = 0;  % no trimming
end

%% FP.VarNames
if ~isfield(FP, 'VarNameList' )
    error('There is no variable: see FP.VarNameList = {''u'';''v''}')
end

%% check MMP and FP.VarNames
idx_gd = [];
for idx = 1 : length(FP.VarNameList)
    if isfield( MMP, FP.VarNameList(idx) )
        idx_gd = [idx_gd idx]; 
    end
end
FP.VarNameList = FP.VarNameList(idx_gd);


%% check FP.VarNames again
if length(FP.VarNameList) < 1
    error(' !!! No valid varNames, usage: FP.VarNameList = {''u'';''v''};' )
end

%% check FP.DeltaT
if ~isfield( FP, 'MaxTimesDT' )
   FP.MaxTimesDT = 1.5; %% 
end
if ~isempty(whos('global','MaxTimesDT'))
    global MaxTimesDT
    FP.MaxTimesDT = MaxTimesDT;
end

%% check FP.DeltaZ
if ~isfield( FP, 'MaxTimesDZ' )
   FP.MaxTimesDZ = 1.5; 
end


%% save the gridded parameter FP
MMP.('para_gridding') = FP;
MMP.yday_grid = FP.yday_grid;
MMP.z_grid    = FP.z_grid(:);

warning off

%% loop for each variable given in FP.VarNameList
for idx_var = 1 : length(FP.VarNameList)
    varname = FP.VarNameList{idx_var};
    disp(['    working on variable: ' varname])
    MMP.([varname '_grid']) = ...
                     nan( length(MMP.z_grid), length(MMP.yday_grid) );
    
    % tic
    %% step 1: interpolate on yday_grid
    %% create a temporal matrix TEMP that contains step-1 tempory result
    TEMP = nan(1, length(MMP.yday_grid) );

    %% 
    %for idx_z = 1 : length(MMP.z)
    %for idx_z=1:size(MMP.z,2) Only one pass...it's an Aanderaa
        data = MMP.(varname)(:);
        
        %% yday or ydayc, switch here
        if strcmp(FP.OriginalTime, 'yday')
            yday = MMP.yday;
        elseif strcmp(FP.OriginalTime, 'ydayc')
            yday = MMP.ydayc(idx_z, :);
        end
        
%         %% delete nan data
%         idx_gd  = find( ~isnan(yday) & ~isnan(data) );
%         data = data(idx_gd);
%         yday = yday(idx_gd);
%         
        %% interpolate
         if isempty( yday )
            disp(' ! yday is empty... ok')
%             %if no good data, do nothing
% %         elseif length(yday) == 1            
%             %if only one yday, two cases:
%             if yday >= min(MMP.yday_grid) & yday <= max(MMP.yday_grid)
%                 %% yday is in MMP.yday_grid, copy to the nearest one
%                 dis_yday = abs(yday-MMP.yday_grid);
%                 idx_nearest = find( dis_yday == min(dis_yday) );
%                 idx_nearest = idx_nearest(1);
%                 TEMP(idx_z, idx_nearest) = data;
%             else
%                 %% disp(' ! z is outside of MMP.z_grid ... ok')
%                 %% MMP.z is out of MMP.z_grid, do nothing
%             end
        else
            data_yday_grid = interp1( yday, data, MMP.yday_grid, [] );
            MMP.z=interp1(yday,MMP.z,MMP.yday_grid,[]);
            TEMP = data_yday_grid;
            
            %% check weather newly-gridded data is too far from raw data            
            %% DT is the grid size of MMP.yday_grid
            DT = nanmean( diff(MMP.yday_grid) );

            %% we just check where data_yday_grid is real data
            IDX_DATA = find( ~isnan(data_yday_grid) );
            for idx_check = 1 : length(IDX_DATA)
                 t0 = MMP.yday_grid( IDX_DATA(idx_check) );
                 dt = min( abs(t0-yday) );
                 if dt > FP.MaxTimesDT * DT
                    TEMP(idx_z, IDX_DATA(idx_check) ) = NaN; 
                 end
            end
        end
    %end
    %%toc
    
    %% step 2: interpolate on z_grid
    for  idx_yday = 1 : size( MMP.yday_grid,2 )
    
        data = TEMP( 1, idx_yday );
        %Added this to avoid problem out of bounds BSB 30 Jul '15
        %Removed to fix for AA
%         if numel(MMP.z)==1
            z=MMP.z;
%         else
%             z    = MMP.z(:,idx_yday);
%         end
%         %% delete nan data
%         idx_gd = find( ~isnan(z) );
%         data = data(idx_gd);
%         z    = z(idx_gd);
        
        %% interpolate
        if isempty( z )
            %% disp(' ! z is empty... ok')
            %% if no good data, do nothing
        elseif length(z) == 1
            %if only one z, two cases:
            if z >= min(MMP.z_grid) & z <= max(MMP.z_grid)
                %% MMP.z is in MMP.z_grid, copy to the nearest one
                dis_z    = abs(z-MMP.z_grid);
                idx_nearest = find( dis_z == min(dis_z) );
                idx_nearest = idx_nearest(1); % in the case of two idx_near, take 1
                MMP.([varname '_grid'])(idx_nearest, idx_yday) = data;
            else
                disp(' ! z is outside of MMP.z_grid ... ok')
                % MMP.z is out of MMP.z_grid, do nothing
            end
        else
            %This is where we work
            %I have data at a single point, and need to put it in the bin nearest
            %Approach, use hist c
            binsize=diff(MMP.z_grid);
            edges=MMP.z_grid+([binsize; binsize(end)])./2;
            [trash zbin]=histc(z(idx_yday),edges);
            %disp([zbin z(idx_yday)]);
            if (zbin==0 && isnan(data))
                zbin=1;
            end
            MMP.([varname '_grid'])(zbin, idx_yday) = data;
                                     

%             %% check weather newly-gridded data is too far from raw data            
%             %% DZ is the grid size of MMP.z 
%             DZ = nanmean( diff(MMP.z_grid) );
% 
%             %% we just check where data_yday_grid is real data
%             IDX_DATA = find( ~isnan(data_z_grid) );
%                 
%             %% check weather a point is from real data point
%             SEC = 40;
%             for idx_check = 1 : SEC : length(IDX_DATA)
%                 MAX = min( idx_check+SEC, length(IDX_DATA) );
%                 IDX = idx_check : MAX;
% 
%                 z0 = MMP.z_grid( IDX_DATA(IDX) );
%                 ZS = z0(:) * ones(1, length(z) );
%                 GS = z(:) * ones(1, length(z0) ); GS = GS';
%                 dff = min( abs(ZS-GS), [], 2 );
%                 MMP.([varname '_grid']) ...
%                     (IDX_DATA( IDX(dff>FP.MaxTimesDZ*DZ)), idx_yday) = NaN; 
%             end
        end
    end
end
%disp(edges);
%%toc

warning on


%% step 3: trim column and layer that contain all NaN
if FP.trim == 1
    
    %% layers
    MEAN = [];
    for idx_var = 1 : length(FP.VarNames)
        varname = FP.VarNames{idx_var};
        data = MMP.([varname '_grid']);
        
        datamean = nanmean( data, 2);
        MEAN = [MEAN datamean(:)];
    end
    MEAN = nanmean(MEAN, 2);

    IDX_GOOD = find( ~isnan(MEAN) );    
    for idx_var = 1 : length(FP.VarNames)
        varname = FP.VarNames{idx_var};
        MMP.([varname '_grid']) = MMP.([varname '_grid'])(IDX_GOOD, :);
    end 
    MMP.('z_grid')    = MMP.('z_grid')(IDX_GOOD, :);
    

    %% columns
    MEAN = [];
    for idx_var = 1 : length(FP.VarNames)
        varname = FP.VarNames{idx_var};
        data = MMP.([varname '_grid']);
        
        datamean = nanmean( data, 1);
        MEAN = [MEAN datamean(:)];
    end
    MEAN = nanmean(MEAN, 2);

    IDX_GOOD = find( ~isnan(MEAN) );    
    for idx_var = 1 : length(FP.VarNames)
        varname = FP.VarNames{idx_var};
        MMP.([varname '_grid']) = MMP.([varname '_grid'])(:, IDX_GOOD);
    end 
    MMP.('yday_grid')    = MMP.('yday_grid')(:, IDX_GOOD);    
    
end
%%toc

return
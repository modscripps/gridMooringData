function  ShowMooring( Mooring )
%function  ShowMooring( Mooring )
%   shows basic data fields in Mooring in four panels
%   
% see also PlotMooring
%
% ZZ @ APL-UW, April 6th, 2010
% ZZ @ APL-UW, April 14th, 2010
% ZZ @ APL-UW, April 16th, 2010
% ZZ @ APL-UW, May 16th, 2011

%% display
disp(['Calling function ' mfilename])

%% initialize what variables to show 
if ~isfield( Mooring, 'VarNamesToShow')
    Mooring.VarNamesToShow = {'u'; 'v'; 't'; 's'};
end

%% check yday range
yday0 = 9999;  yday1 = -9999;
for idx_instr = 1 : length( Mooring.DataList )
    instrument = Mooring.(Mooring.DataList{idx_instr});
    %% update yday0 and yday1
    if nanmin(instrument.yday) < yday0, yday0 = nanmin(instrument.yday); end
    if nanmax(instrument.yday) > yday1, yday1 = nanmax(instrument.yday); end
end

%% common yday range
t0 = -9999;   t1 = 9999;
for idx_instr = 1 : length( Mooring.DataList )
    instrument = Mooring.(Mooring.DataList{idx_instr});
    %% update yday0 and yday1
    if nanmin(instrument.yday) > t0, t0 = nanmin(instrument.yday); end
    if nanmax(instrument.yday) < t1, t1 = nanmax(instrument.yday); end
end

%% plot a figure
figure(1); clf, orient tall
NumOfPanels = length( Mooring.VarNamesToShow );
ax = MySubplot(0.1, 0.03, 0.1, 0.06, 0.1, 0.05, 1, NumOfPanels);
set(ax, 'fontsize', 12, 'linewidth', 1.0, 'fontweight', 'bold' )
set(ax, 'layer', 'bottom', 'box', 'on' )

%% for each panel
for idx_var = 1 : NumOfPanels
    varname = Mooring.VarNamesToShow{idx_var};
    
    %% panels
    axes( ax(idx_var) ), hold on, grid on
    
    %% show the results from various data fields
    for idx_instr = 1 : length( Mooring.DataList )
        instrument = Mooring.(Mooring.DataList{idx_instr});
    
        %% check how many variables in one instrument
        if isfield( instrument, varname )
            %% check how many layer in one instrument
            if length( instrument.z ) ~= 1 
                %% check how many layer in this data field
                if all( size( instrument.(varname), 1) ~= 1 )
                    pcolor( instrument.yday, instrument.z, instrument.(varname) )
                else
                    plot(instrument.yday, instrument.z(:)*ones(size(instrument.yday)), ...
                    'linewidth', 3, 'color', 'm' )                    
                end
            else
                %% multiple layer data
                plot(instrument.yday, instrument.z*ones(size(instrument.yday)), ...
                    'linewidth', 3, 'color', 'm' )
            end
        end
    end
    
    %% shading 
    shading flat
    set(gca, 'ydir', 'reverse' )

    %% add a red box
    plot( [t0 t0 t1 t1 t0], [0 Mooring.depth Mooring.depth 0 0], ...
                                             'r', 'linewidth', 2 )
    %% limits
    xlim([floor(yday0) ceil(yday1)])
    ylim([0 Mooring.depth])

    %% xlabel, ylabel, and title    
    if idx_var == NumOfPanels
        xlabel( 'Yearday')
    end
    ylabel( 'Depth' )
    title( [Mooring.UID '-' varname] )
end

return
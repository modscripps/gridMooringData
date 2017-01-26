function ezpcolor( CTD, data )
%function ezpcolor( CTD, data )
%   shows pcolor(CTD.yday, CTD.z, CTD.(data) ), or
%   shows pcolor(CTD.yday_grid, CTD.z_grid, CTD.(data) )
%   depends on if data is gridded or not
%   
% see also ezSBE
%
% ZZ @ APL-UW, March 12th, 2010

%%
if ~exist('data', 'var')
    disp('  !! please specify data field?')
    disp('  usage: ezpcolor( CTD, ''u'') or ezpcolor(CTD, ''u_grid'')' )
    return;
end

%% check if data have 'grid' 
if strfind(data, 'grid')
    % in case data contains 'grid', using gridded time and z
    yday = 'yday_grid';
    z    = 'z_grid';
else
    % in case data contains no 'grid'
    yday = 'yday';
    z    = 'z';
end


%% make the plot
figure(123), clf, hold on, box on, grid on
set(gca, 'fontsize', 12, 'fontweight', 'bold', 'linewidth', 1)

pcolor( CTD.(yday), CTD.(z), CTD.(data) ), shading flat
set(gca, 'ydir', 'reverse' )
xlim([nanmin(CTD.(yday)) nanmax(CTD.(yday))])
ylim([nanmin(CTD.(z))    nanmax(CTD.(z))])

xlabel( 'Yearday' )
ylabel( 'Depth' )
title( fixstr(data) )

MAX = nanmax( nanmax(CTD.(data)) );
MIN = nanmin( nanmin(CTD.(data)) );
caxis([MIN MAX])

%% colorbar
if strncmp(data, 'u', 1) | strncmp(data, 'v', 1) | strncmp(data, 'w', 1 )  
    colormap( bluered0 )
else
    colormap( jet )
end
colorbar;

return
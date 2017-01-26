function ezADCP( ADCP )

%%
if isfield( ADCP, 'xducer_depth')
    NumPanel = 4;
else
    NumPanel = 3;    
end

%%
h = figure(1); clf, orient tall
ax = Mysubplot( 0.1, 0.1, 0.04, 0.04, 0.08, 0.06, 1, NumPanel);
set(ax, 'fontsize', 12, 'fontweight', 'bold', 'linewidth', 0.8)

%%
VarNames = {'u';'v';'w'};
for id = 1 : 3
   axes(ax(id)), hold on, box on, grid on
   set(gca, 'ydir', 'reverse')

   varname = VarNames{id};
   pcolor( ADCP.yday, ADCP.z, ADCP.(varname) ) 
   MAX = nanmax( nanmax( abs(ADCP.(varname)) ) );
   shading flat
   colormap( redblue1 )
   caxis([-MAX MAX])
   colorbar
   
   xlim([nanmin(ADCP.yday) nanmax(ADCP.yday)])
   ylim([nanmin(ADCP.z) nanmax(ADCP.z)])
   ylabel([' Depth (m)'])
   xlabel('Yearday')
   
   SubplotLetterMW( varname, 0.04, 0.8, 12 )
   
   if id == 1
      title([ADCP.info.snADCP ' ' ADCP.info.MooringID ...
                              ' ' ADCP.info.Cruise])
   end
                          
end

if isfield( ADCP, 'xducer_depth')
    axes(ax(4)), hold on, box on, grid on
    plot( ADCP.yday, ADCP.xducer_depth )
    xlim([nanmin(ADCP.yday) nanmax(ADCP.yday)]) 
end
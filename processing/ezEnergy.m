function hd = ezEnergy( IW, FP )
%function hd = ezEnergy( IW, FP )
%   shows energy in IW
%
% see also ezFlux, ezpcolor, ezFlux_MD
%
% ZZ @ APL-UW Match 19th, 2010
% ZZ @ APL-UW May 16th, 2011


%%
disp(['Calling function ' mfilename])

%% check FP and its parameters
if ~exist('FP', 'var')
    FP = struct;
end

%%
if ~isfield( FP, 'Figure_dir' )
    FP.Figure_dir =  cd;
end

%% DATA.save_dir
if ~isfield( FP, 'Figure_name' )
    FP.Figure_name = ['Fig-' IW.UID '-Energy-full'];
end

%% plot
ch = figure(99); clf, orient tall,
hd = MySubplot(0.1, 0.05, 0.04, 0.04, 0.1, 0.03, 1, 4);
set(hd, 'fontsize',12,'fontweight', 'bold', 'linewidth', 1.0 );

%% pcolor panels
VarNames = {'pe'; 'ke'; 'e'};
for idx = 1 : 3
    varname = VarNames{idx};
    MAX(idx) = nanmax( nanmax(IW.(varname)) );
end
MAX = nanmax(MAX);
if isnan(MAX), MAX = 1; end

%%
for idx = 1 : 3
    varname = VarNames{idx};
    
    %%
    axes(hd(idx+1)), hold on, box on, grid on
    data = IW.(varname);
    
    pcolor( IW.yday, IW.z, data), shading flat
    caxis([0 MAX])
    set(gca, 'ydir', 'reverse')
    xlim([nanmin(IW.yday) nanmax(IW.yday)])
    ylim([nanmin(IW.z) nanmax(IW.z)])
    ylabel( 'Depth (m)')
    if idx == 3
        xlabel( ['Yearday (' num2str(IW.year(1)) ')'])
    end
    
    SubplotLetterMW( ['\bf' upper(varname)], 0.02, 0.1, 14);

%Incompatable with r2015a, colorbars are not axis obj    
%     h = colorbar;
%     set(h, 'fontsize',12,'fontweight', 'bold', 'linewidth', 1.0 );
%     axes(h), ylabel( 'Energy (J m^{-3})')
    
    axes(hd(idx+1))
    pos = get( gca, 'position' );
    xlen = pos(3);
end

%%
axes(hd(1)); hold on, box on, grid on
t1 = plot( IW.yday, IW.PE, 'r', 'linewidth', 1.2 );
t2 = plot( IW.yday, IW.KE, 'b', 'linewidth', 1.2 );
t3 = plot( IW.yday, IW.E, 'k', 'linewidth', 1.2 );

xlim([nanmin(IW.yday) nanmax(IW.yday)])
ylabel( 'E (kJ m^{-2})')
legend([t1 t2 t3], 'PE', 'KE', 'E', 'location', 'NorthEastoutside')

if isfield( IW, 'UID' )
    title( IW.UID )
else
    title( 'unknown')
end

pos = get( gca, 'position');
pos(3) = xlen;
set(gca, 'position', pos );
    

%% print 
FigName = fullfile( FP.Figure_dir, FP.Figure_name );    
print('-depsc', '-r200', FigName);
eps2pdf([FigName '.eps']);
delete([FigName '.eps']);

return
function hd = ezFlux( IW, FP )
%function hd = ezFlux( IW )
%   show full-profile flux in IW
%
% see also ezEnergy
%
% ZZ @ APL-UW Match 19th, 2010
% ZZ @ APL-UW June 7th, 2010

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
    FP.Figure_name = ['Fig-' IW.UID '-Flux-full'];
end

%%
ch = figure(97), clf, orient tall,
hd = MySubplot(0.1, 0.05, 0.04, 0.04, 0.1, 0.03, 1, 3);
set(hd, 'fontsize', 12, 'fontweight', 'bold', 'linewidth', 1.0 );

%% pcolor panels
VarNames = {'up'; 'vp'};

%% check the minimum and maximum of IW flux
MAXu = nanmax( nanmax( abs(IW.up) ) );
MAXv = nanmax( nanmax( abs(IW.vp) ) );
MAX  = nanmax([MAXu MAXv]);
if isnan(MAX), MAX = 1; end

%%
for idx = 1 : length(VarNames)
    varname = VarNames{idx};
    
    %%
    axes(hd(idx+1)), hold on, box on, grid on
    data = IW.(varname);
    
    pcolor( IW.yday, IW.z, data), shading flat
    caxis([-MAX MAX])
    %colormap( bluered0 )
    
    set(gca, 'ydir', 'reverse')
    xlim([nanmin(IW.yday) nanmax(IW.yday)])
    ylim([nanmin(IW.z) nanmax(IW.z)])
    ylabel( 'Depth (m)')
    if idx == length(VarNames)
        xlabel( ['Yearday (' num2str(IW.year(1)) ')'])
    end
    
    SubplotLetterMW( ['\bf' upper(varname)], 0.02, 0.1, 14);

% Incompatable with R2015a
%     h = colorbar;
%     set(h, 'fontsize',12,'fontweight', 'bold', 'linewidth', 1.2 );
%     axes(h), ylabel( 'Flux (W m^{-2})')
%     
    axes(hd(idx+1))
    pos = get( gca, 'position' );
    xlen = pos(3);
end

%%
axes(hd(1)), hold on, box on, grid on
t1 = plot( IW.yday, IW.Fu, 'r', 'linewidth', 1.6 );
t2 = plot( IW.yday, IW.Fv, 'b', 'linewidth', 1.6 );
t3 = plot( IW.yday, IW.F, 'k', 'linewidth', 1.6 );

xlim([nanmin(IW.yday) nanmax(IW.yday)])
ylabel( 'F (kW m^{-1})')
legend([t1 t2 t3], 'Fu', 'Fv', 'F', 'location', 'NorthEastoutside');

if isfield( IW, 'UID' )
    title( IW.UID )
else
    title( 'unknown')
end

pos = get( gca, 'position');
pos(3) = xlen;
set(gca, 'position', pos )
    

%% print 
FigName = fullfile( FP.Figure_dir, FP.Figure_name );    
print('-depsc', '-r200', FigName);
eps2pdf([FigName '.eps']);
delete([FigName '.eps']);

return
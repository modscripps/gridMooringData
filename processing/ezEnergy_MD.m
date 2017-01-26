function hd = ezEnergy_MD( IW, FP )
%function hd = ezEnergy_MD( IW )
%   show full-profile flux in IW
%
% see also ezFlux, ezEnergy, ezFlux_MD
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
    FP.Figure_name = ['Fig-' IW.UID '-Energy-MD'];
end

%%
ch = figure(99), clf, orient tall,
hd = MySubplot(0.12, 0.02, 0.06, 0.04, 0.1, 0.05, 2, 3);
set(hd, 'fontsize', 12, 'fontweight', 'bold', 'linewidth', 1.0 );

%%
axes( hd(1) ), hold on, box on, grid on
if isfield( IW, 'UID' )
    title( [IW.UID '-Energy'] )
else
    title( ['Energy'])
end

%% pcolor panels
VarNames = {'KE'; 'PE'; 'E'};

for idx = 1 : 3
    varname = VarNames{idx};
    data = IW.([varname '_md']);
    datamn = nanmean( data, 1); 
    
    axes(hd(idx*2-1)), hold on, box on, grid on 
    plot( IW.yday, data)
    xlabel('Yearday')
    ylabel([varname '(kJ m^{-2})'])
    xlim([nanmin(IW.yday) nanmax(IW.yday)])
    
    axes(hd(idx*2)), hold on, box on, grid on 
    bar(1:IW.Nmode, datamn )
    xlabel('Mode')
    xlim([0 IW.Nmode+0.5])
end

  
%% print 
FigName = fullfile( FP.Figure_dir, FP.Figure_name );    
print('-depsc', '-r200', FigName);
eps2pdf([FigName '.eps']);
delete([FigName '.eps']);

return
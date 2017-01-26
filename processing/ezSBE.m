function ezSBE( SBE, FP )
%function ezSBE( SBE )
%   show time series data and its spectra
%
% 
% ZZ @ APL-UW, April 12th 2010


%% display
disp(['Calling function ' mfilename])


%% check FP and its parameters
if ~exist( 'FP', 'var')
    FP = struct;
end

%% FP.VarNames
if ~isfield( FP, 'VarNames')
    FP.VarNames = {'temp';'cond';'pr';'sal'};
end

%% check SBE and FP.VarNames
idx_gd = [];
for idx = 1 : length(FP.VarNames)
    if isfield( SBE, FP.VarNames(idx) ), 
        idx_gd = [idx_gd idx]; 
    end
end
FP.VarNames = {FP.VarNames{idx_gd}};
Num_panel = length( FP.VarNames );


%% figure
h = figure(1); clf, 

if Num_panel > 2
    orient tall
else
    orient landscape
end

ax = Mysubplot( 0.1, 0.4, 0.04, 0.04, 0.08, 0.04, 1, Num_panel);
bx = Mysubplot( 0.7, 0.04, 0.04, 0.04, 0.08, 0.04, 1, Num_panel);
set(ax, 'fontsize', 12, 'fontweight', 'bold', 'linewidth', 0.8)
set(bx, 'fontsize', 12, 'fontweight', 'bold', 'linewidth', 0.8)

%% time series
for idx = 1 : Num_panel
    varname = FP.VarNames{idx};
    yday = SBE.yday;
    data = SBE.(varname);
    
    axes(ax(idx)), hold on, box on, grid on
    t = plot( yday,  data );
    set(t, 'linewidth', 1.2, 'color', 'b' );
    
    xlim([min(yday) max(yday)])
    ylim([min(data) max(data)])
    ylabel(varname)
    
    if idx == Num_panel
        xlabel( 'Yearday' )
    end
    
    if idx == 1
        title(SBE.serial_no)
    end
end


%% spectra
for idx = 1 : Num_panel
    varname = FP.VarNames{idx};
    yday = SBE.yday;
    data = SBE.(varname);

    dt    = nanmean( diff(yday) );
    ydayn = nanmin(yday):dt:nanmax(yday);
    data  = interp1( yday, data, ydayn);
    
    axes(bx(idx)), hold on, box on, grid on

    data = detrend( data );
    data = data - nanmean( data );
    data( isnan(data) ) = 0;
    
    [P,F] = spectrum(data, length(data) );
    F = F / dt / 2;
    
    t = bar( F,  P(:,1), 'k' );
    set(t, 'linewidth', 1.0);
    xlim([0.5 2.5])
    
    if idx == Num_panel
        xlabel( 'F (cpd)' )
    end

end

return;
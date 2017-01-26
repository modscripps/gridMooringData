function ShowModeFit( IW )
%function ShowModeFit( IW )
%   shows the modal structure and fitted amplitudes of 
%   un, vn, and etan
%
% See also PlotModeFit
%
% ZZ @ APL-UW, April 2010
% ZZ @ APL-UW, May 16th 2011

%% disp
disp(['Calling function ' mfilename])

%% modes
if ~isfield( IW, 'ModeToShow')
    N = nanmax(IW.Nmode, 3);
    IW.ModeToShow = 1 : N;
end

%% figure
ch = figure(93); clf, 
hda = MySubplot(0.1,  0.75, 0.04, 0.04, 0.1, 0.04, 1, 3);
hdb = MySubplot(0.35, 0.05, 0.04, 0.04, 0.1, 0.04, 1, 3);
hd = [hda hdb];
set(hd, 'fontsize',12,'fontweight', 'bold', 'linewidth', 1.0 );

%%
VarNames  = {'un'; 'vn'; 'etan'};
ModeNames = {'hori_full'; 'hori_full';'vert_full'};

%%
for idx = 1 : 3
    varname = VarNames{idx};
    modename = ModeNames{idx};
    
    %% hori_full and vert_full
    axes(hda(idx)), hold on, box on, grid on
    if ndims(IW.(modename)) == 2
        plot( IW.(modename)(:, IW.ModeToShow), IW.z_full, 'linewidth', 1.2 )
    elseif ndims(IW.(modename)) == 3
        for i = 1 : 100 : size(IW.(modename),3)
            plot( IW.(modename)(:, IW.ModeToShow, i), IW.z_full, 'linewidth', 0.6 )        
        end
    end
    ylim([0 IW.depth])
    set(gca, 'ydir', 'reverse' )
    ylabel( fixstr(modename) )
    if idx == 3
        xlabel('Mode')
    end   

    %% un, vn, etan
    axes(hdb(idx)), hold on, box on, grid on
    plot( IW.yday, IW.(varname)(IW.ModeToShow, :), 'linewidth', 1.2 )
    xlim([nanmin(IW.yday) nanmax(IW.yday)])
    ylabel( fixstr(varname) )
    if idx == 3
        xlabel('Yearday')
    end    
    
    if idx == 1
        if isfield(IW, 'UID')
            title([IW.UID '-ModeFit'])
        else
            title('ModeFit')
        end
    end
end

return
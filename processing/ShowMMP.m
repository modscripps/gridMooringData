function  ShowMMP( MMP )
%function  ShowMMP( MMP )
%   checks data structure on MMP, and displays
%
% see also PlotMMP
%
% ZZ @ APL-UW, April 16th, 2010
% ZZ @ APL-UW, May 16th, 2011

%% display
disp(['Calling function ' mfilename])


%% check what variables to show
if ~isfield( MMP, 'VarNamesToShow' )
    MMP.VarNamesToShow = {'u'; 'v'; 's'; 't'; 'sgth'};
end


%% check MMP and update MMP.VarNamesToShow
checkList = zeros( size(MMP.VarNamesToShow) );
for idx = 1 : length(MMP.VarNamesToShow)
    if isfield(MMP, MMP.VarNamesToShow(idx) ), checkList(idx) = 1; end
end
checkList = find( checkList );
MMP.VarNamesToShow = {MMP.VarNamesToShow{checkList}};


%% plot a figure
figure(1), clf, orient tall
NumOfPanels = length( MMP.VarNamesToShow);
ax = MySubplot(0.1, 0.03, 0.1, 0.06, 0.1, 0.05, 1, NumOfPanels );
set(ax, 'fontsize', 12, 'linewidth', 1.0, 'fontweight', 'bold' )
set(ax, 'layer', 'bottom', 'box', 'on' )

%% variables
for idx_var = 1 : NumOfPanels
    varname = MMP.VarNamesToShow{idx_var};
    
    %% panels
    axes( ax(idx_var) ), hold on, grid on
    
    %% check if it is a matrix or not
    if ~any(size( MMP.(varname) )==1)
        pcolor( MMP.yday, MMP.z, MMP.(varname) )

    else
        tem = repmat( MMP.(varname), size(MMP.yday) );
        pcolor( MMP.yday, MMP.z, tem )
    end
    %% shading 
    shading flat
    set(gca, 'ydir', 'reverse' )
    
    if ~isempty(find(strcmp(varname,{'u','v','eta'})))
        colormap(gca,bluered); 
        eval(['clim = max([abs(nanmin(MMP.',varname,'(:))),nanmax(MMP.',varname,'(:))]);']);
        caxis(clim*0.75.*[-1 1]);
    end

    %% x, y, and title  
    if idx_var == NumOfPanels
        xlabel( 'Yearday')
    end
    ylabel( 'Depth' )
    if isfield( MMP, 'UID')
        title( [MMP.UID '-' varname ])
    else
        title( varname )
    end
    
    %%
    colorbar
end

%% limits
linkaxes(ax);
xlim([(min(MMP.yday)) (max(MMP.yday))])
ylim([(min(MMP.z))    (max(MMP.z))])

maxfigure;
return
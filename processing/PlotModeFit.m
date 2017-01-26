function PlotModeFit( IW )
%function PlotModeFit( IW )
%   demonstrates, in IW, the modal strutures and fitted 
%   amplitudes of un, vn and etan.
%
% See also AddModeToMMP, ShowModeFit, AddModeToIW_multi, DoModeFitToMMP
%
% ZZ @ APL-UW, March 29th, 2010
% ZZ @ APL-UW, May 16th, 2011


%% display
disp(['Calling function ' mfilename])

%% IW.SaveFigure_dir
if ~isfield( IW, 'Figure_dir' )
    IW.Figure_dir =  pwd;
end

%% IW.ModeFigure_name
if ~isfield( IW, 'Figure_ModeFit_name' )
    IW.Figure_ModeFit_name =  ['Fig-' IW.UID '-ModeFit'];
end


%% show the figure call ShowModeFit
ShowModeFit( IW )

%%
mkdir( IW.Figure_dir )
FigName = fullfile(IW.Figure_dir, IW.Figure_ModeFit_name);
print('-depsc', '-r300', FigName);
eps2pdf([FigName '.eps']);
delete([FigName '.eps']);

return
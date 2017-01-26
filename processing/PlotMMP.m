function  MMP = PlotMMP( MMP )
%function  MMP = PlotMMP( MMP )
%   check data structure on MMP, and
%   print out a figure
%
% see also ShowMMP
%
% ZZ @ APL-UW, April 16th, 2010
% ZZ @ APL-UW, May 16th, 2011

%% display
disp(['Calling function ' mfilename])

%% call function ShowMMP
ShowMMP( MMP )

%% checking MMP.Figure_dir
if ~isfield( MMP,  'Figure_dir' )
    MMP.Figure_dir = pwd;
end

%% checking MMP.Figure_name
if ~isfield( MMP,  'Figure_name' )
    MMP.Figure_name = ['Fig-' MMP.UID];
end

%% print out a figure
mkdir( MMP.Figure_dir )
FigName = fullfile(MMP.Figure_dir, MMP.Figure_name);
print('-depsc','-r200', FigName)
eps2pdf([FigName '.eps'])
delete([FigName '.eps'])

return
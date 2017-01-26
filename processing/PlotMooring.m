function  Mooring = PlotMooring( Mooring )
%function  PlotMooring( Mooring )
%   plots the basic data fields in Mooring
%   in four panels, and prints out a figure
%
% see also ShowMooring
%
% ZZ @ APL-UW, April 16th, 2010
% ZZ @ APL-UW, May 16th, 2011

%% display
disp(['Calling function ' mfilename])

%% call function to show
ShowMooring( Mooring )

%% checking Mooring.Figure_dir
if ~isfield( Mooring, 'Figure_dir' )
    Mooring.Figure_dir = pwd;
end

%% checking Mooring.Figure_name
if ~isfield( Mooring,  'Figure_name' )
    Mooring.Figure_name = ['Fig-' Mooring.UID];
end

%% print a figure and converts to PDF
mkdir( Mooring.Figure_dir )
FigName = fullfile(Mooring.Figure_dir, Mooring.Figure_name);
print('-depsc','-r200', FigName)

% BLOSS = Had to delete these, I don't have them.
eps2pdf([FigName '.eps'])
delete([FigName '.eps'])

return
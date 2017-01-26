function  Mooring = CheckMooring( Mooring )
%function  CheckMooring( Mooring )
%   check data structure on one mooring
%   and summarize their time-/depth-range
%   
%   results are printed out a *.txt file
%
% ZZ @ APL-UW, April 16th, 2010
% ZZ @ APL-UW, May 16th, 2011

%%% Comments with three leading % are annotations by B. Bloss, UW: May 2015

%% display
disp(['Calling function ' mfilename])

%% print out a summary of the mooring data
%%% Opens file for (over)writing 
fname = fullfile(pwd, [Mooring.UID '.txt']);
fid   = fopen( fname, 'w' );

%% mooring name or information
fprintf( fid, ['\n\n' Mooring.UID ' \n\n']);

%% ranges of yday and z
%%% Prints yday data for all (each) instrument on first loop, then all
%%% (each) instrument's z data
VarNames = {'yday'; 'z'};
units    = {'minute'; 'meter'};
factors  = [24*60 1];

for idx_var = 1 : length(VarNames)
    varname = VarNames{idx_var};
    unit    = units{idx_var};
    factor  = factors(idx_var);
    
    fprintf( fid, [varname ' range: \n']);
    
    for idx_instr = 1 : length( Mooring.DataList)
        instr_name = Mooring.DataList{idx_instr};
        instrument = Mooring.(instr_name);

        fprintf(fid, instr_name);
        fprintf(fid, '\n');
        
        data = instrument.(varname);
        
        fprintf(fid, ['   ' varname ':  ' ...
                              num2str( nanmin(data) ) ' - ' ...
                              num2str( nanmax(data) ) '\n']);
        
        delta = diff(data)*factor;
        
        fprintf(fid, ['   Interval: ' num2str( nanmin(delta)) ' - ' ...
                              num2str( nanmax(delta) )  ' ' unit '\n']);

        fprintf(fid, ['   Median interval: ' ...
                              num2str( nanmedian(delta)) ' ' unit '\n\n']);                 
    end
    fprintf(fid, '\n\n\n');    
end


%% common yday range
%%% This is accomplished by building in from the ends (common yeardays are
%%% built from a contracting interval).
t0 = -999; t1 = 999;
for idx_instr = 1 : length( Mooring.DataList )
    instrument = Mooring.(Mooring.DataList{idx_instr});
    %% update yday0 and yday1
    if nanmin(instrument.yday) > t0, t0 = nanmin(instrument.yday); end
    if nanmax(instrument.yday) < t1, t1 = nanmax(instrument.yday); end
end
fprintf( fid, 'Suggested yday range (common for all instruments): \n');
fprintf(fid, ['    '  num2str( t0 ) ' - ' num2str( t1 ) '\n\n']);


%% Largest deltaT in yday
%%% Note the use of median value
deltaT = -999;
for idx_instr = 1 : length( Mooring.DataList )
    instrument = Mooring.(Mooring.DataList{idx_instr});
    %% update deltaT
    if nanmedian(diff(instrument.yday)) > deltaT
        deltaT = nanmedian(diff(instrument.yday)); 
    end
end
fprintf( fid, 'Suggested yday interval (largest intervals): \n');
fprintf(fid, ['    '  num2str( deltaT ) '\n\n']);


%%
fprintf( fid, 'Suggested z range (must be full-water depth) :\n');
fprintf(fid, ['    '  num2str(0) ' - ' num2str( Mooring.depth ) '\n\n']);

%% smallest dz 
%%% iterates through instruments finding the largest _mean_ dz step
dz = -999;
for idx_instr = 1 : length( Mooring.DataList )
    instrument = Mooring.(Mooring.DataList{idx_instr});
    %% update deltaT
    if nanmean(diff(instrument.z)) > dz
        dz = nanmean(diff(instrument.z)); 
    end
end
fprintf( fid, 'Suggested dz (smallest dz): \n');
fprintf(fid, ['    '  num2str(dz) '\n\n\n']);


%% save the suggested gridding parameters to Mooring
%%% Remember you can manually override these values after this function has
%%% been called.
Mooring.dt        =  deltaT;
Mooring.yday_grid = t0 : deltaT : t1;
Mooring.dz        = dz;
Mooring.z_grid    = 0 : dz : Mooring.depth;

fclose( fid );

return

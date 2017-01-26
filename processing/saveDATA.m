function fid = saveDATA( DATA )
%function fid = saveDATA( DATA )
%   saves DATA and returns its absolute address
%
%   here DATA could be: Mooring or MMP or IW
%   
% ZZ @ APL-UW, April 16th, 2010
% ZZ @ APL-UW, April 19th, 2010
% ZZ @ APL-UW, May 16th, 2011

%% display
disp(['Calling function ' mfilename])

%% check input data
if nargin == 0
    fid = 'no DATA to save';
    return;
end

%% DATA.save_dir
if ~isfield( DATA, 'Data_dir' )
    DATA.Data_dir = pwd;
end

%% DATA.save_dir
if ~isfield( DATA, 'Data_name' )
    DATA.Data_name = DATA.UID;
end

%% create a file name
fid = fullfile(DATA.Data_dir, DATA.Data_name);

%% convert DATA to its original realname
DataName = inputname(1);
eval([DataName '=DATA;'])
save( fid, DataName )

return
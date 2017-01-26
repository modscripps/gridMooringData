function MMP = AddMooringToMMP( MMP, Mooring )
%function MMP = AddMooringToMMP( MMP, Mooring )
%
%   Based on MMP.DataList,
%   adding data from Mooring to MMP 
%
% see also AddDATAToMMP
%
% ZZ @ APL-UW, April 16th, 2010
% ZZ @ APL-UW, February 25th, 2011


%% display
disp(['Calling function ' mfilename])


%% MMP
if ~exist( 'MMP', 'var' ) 
    MMP = struct;
    return;
end

%% Mooring
if ~exist( 'Mooring', 'var' ) 
    return;
end

%% copy data from Mooring to MMP
for idx_str = 1 : length(MMP.DataList)
    DataName      = MMP.DataList{idx_str};
    DATA          = Mooring.(DataName);
    DATA.name     = DataName;    
    MMP = AddDATAToMMP(MMP, DATA);  % call function 
end

return
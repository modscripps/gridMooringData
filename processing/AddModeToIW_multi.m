function IW = AddModeToIW_multi(IW, FP)
%function IW = AddModeToIW_multi(IW, FP)
%   (1) computates modal structures from IW.CTD, which is done 
%       by calling AddModesToCTD_multi
%
%   (2) interpolating the results to IW
%    
% See also AddModesToCTD_multi
%
% ZZ @ APL-UW, April 28th, 2011
% ZZ @ APL-UW, May 16th, 2011


%% (0) display 
disp( ['Calling function ' mfilename])


%% step (1) calculate modes
CTD  = IW;
CTD.FreqBand = IW.FreqBand;
CTD  = AddModesToCTD_multi(CTD, FP);

%% step (2) copy modes from CTD to IW
IW.Nmode = FP.Nmode; % save this parameters

warning off
% case 1: one column
if ndims(CTD.vert_full) < 3
    VarNameList = {'para_vmode'; 'z_full';    'n2_full'; ...
                   'vert_full';  'hori_full'; 'ce'; 'ce_bt'; ...
                   'cg'; 'cp';   'WLen'};
    for iv = 1 : length(VarNameList)
        varname = VarNameList{iv}; 
        IW.(varname) = CTD.(varname);
    end
end
% case 2: multiple columns
if ndims(CTD.vert_full) == 3
    % data field 
    VarNameList = {'para_vmode'; 'z_full'};
    for iv = 1 : length(VarNameList)
        varname = VarNameList{iv}; 
        IW.(varname) = CTD.(varname);
    end    
    % data field
    VarNameList = {'n2_full'; 'ce'; 'cg'; 'cp'; 'WLen'; 'ce_bt'};
    for iv = 1 : length(VarNameList)
        varname = VarNameList{iv}; 
        data = CTD.(varname);
        newdata = interp1(CTD.yday, data', IW.yday);
        IW.(varname) = newdata';
    end     
    %data field
    VarNameList = {'vert_full'; 'hori_full'};
    for iv = 1 : length(VarNameList)
        varname = VarNameList{iv};
        data = CTD.(varname);
        IW.(varname) = nan( size(data,1), size(data,2), length(IW.yday));
        for imd = 1 : size(data,2)
            data_imd = squeeze(data(:,imd,:))';
            newdata = interp1( CTD.yday, data_imd, IW.yday);
            IW.(varname)(:, imd, :) = newdata';
        end
    end      
end
warning on

%%
return
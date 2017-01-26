function MMP = AddWOACTDToMMP( MMP )
%function MMP = AddWOACTDToMMP( MMP )
%   gets CTD structure from CTD2005 database
%
%   INOUT:
%      MMP:  standard MMP data structure
%   
%   OUTPUT:
%      MMP.CTD: CTD from WOA 2005
%      MMP.n2:  n2 from MMP.CTD
%
% see also MakeCTD_Levitus2005
% 
% ZZ @ APL-UW, April 21st, 2010
% ZZ @ APL-UW, April 27th, 2011


%% display funcation name
disp(['Calling function ' mfilename])


%% step (1) Create a CTD structure from World Ocean Atlas 2005
FP.H    = MMP.depth;  %using the real MMP.depth
FP.dz   = 2;  % vertical grid
CTD     = MakeCTD_Levitus2005(MMP.lat, MMP.lon, FP);

%% step (1a) check modes to CTD
% FP.n_modes = 10;   % number of modes to calculate
% FP.plotit  = 0;
% CTD = AddModesToCTD(CTD, FP);

%% step (2) save to MMP.CTD
MMP.CTD = CTD;
MMP.CTD_note = 'WOA 2005';

%% step (3) put MMP.CTD.n2 to MMP.n2
MMP.n2 = interp1(MMP.CTD.z, MMP.CTD.n2, MMP.z);
MMP.n2_note = 'n2 from MMP.CTD, which from WOA 2005';

return
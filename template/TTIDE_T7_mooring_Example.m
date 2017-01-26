%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Bloss' T7 Mooring
%   Based on Andy Pickering's Example
%
% 20 Apr 2015
% 15 Jul 2015 - In Progress,
%   working example for iterative refinement with Kevin T.
% 10 August 2015 Major Cleanup Incorporating Knockdown handling and
%   improved t-logger handling
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all;
clear;

%%%This is my 'root' mooring directory
cd('/Users/Okeanos/Documents/MATLAB/RR1503_ADCP');

%% Set up variables, flags and labels

savemmp=1;

%choose to interpolate gaps in data
label='Interp';
%where do we want to fill in gaps?
intwhere='top-bottom-middle';

UID=['TestRUN-TTIDE-T7-' label];

%% Generate perturbation grid
%This generates a grid which indicates the perturbation
[ z_1m_perturb, time_2min ] = zCorrectFromADCP();

%% Load in the data files

%% load Tloggers (RBR and Temp only SBEs)

%This is a list of each [[RBR S/N][Nom Depth];
%                        ....]
% Where the nominal depth has been calculated from the mooring diagram

listRBR=[72141,278;
    72191,327;
    72192,377;
    72193,436;
    72194,495;
    72195,564;
    72196,634;
    72197,713;
    72198,802;
    72143,890;
    72199,989;
    72200,1227;
    72201,1246;
    72202,1266;
    72203,1289;
    72204,1304;
    72205,1319;
    72206,1329;
    72207,1338;
    72208,1348;
    72209,1358;
    72210,1368;
    72211,1378;
    72212,1388;
    72213,1400;
    72214,1410;
    72215,1420;
    72216,1430;
    72217,1440;
    72218,1449;
    72219,1459;
    72072,1469;
    72073,1479;
    72131,1489;
    72142,1494];

%time_2min comes from the z correction routine
% This assigns the correct variable names for each RBR
% The depth time-series for each is derived from the mooring perturbations
% above, and that is finally interpolated to the RBR's time points
for rbr=1:length(listRBR)
    temp=load(sprintf('T7/RBRSolo/RBRSolo_0%d.mat',listRBR(rbr,1)));
    temp=temp.dat;
    eval(['SBE_' num2str(listRBR(rbr,1)) '.t=interp1(temp.time(:),temp.T,time_2min);']);
    eval(['SBE_' num2str(listRBR(rbr,1)) '.yday=datenum2yday(time_2min);']);
    eval(['SBE_' num2str(listRBR(rbr,1)) '.z=z_1m_perturb(listRBR(rbr,2),:)+listRBR(rbr,2);']);
    eval(['SBE_' num2str(listRBR(rbr,1)) '.z=interp1(datenum2yday(time_2min), SBE_' num2str(listRBR(rbr,1)) '.z, SBE_' num2str(listRBR(rbr,1)) '.yday);']);
end

%% ADCPs
%I'm using the 10min ones here because of illustrative purposes / 10min
%output

%Top ADCP
ADCP_TOP=load('SN8122_TTIDE_AVE_10min.mat');
ADCP_TOP=ADCP_TOP.Vel;
ADCP_TOP.yday(find(isnan(ADCP_TOP.yday)))=datenum2yday(ADCP_TOP.dtnum(find(isnan(ADCP_TOP.yday))));

%Middle ADCP
ADCP_MID=load('SN15458_TTIDE_AVE_10min.mat');
ADCP_MID=ADCP_MID.Vel;
ADCP_MID.yday(find(isnan(ADCP_MID.yday)))=datenum2yday(ADCP_MID.dtnum(find(isnan(ADCP_MID.yday))));

%Bottom ADCP
ADCP_BOT=load('SN12819_TTIDE_AVE_10min.mat');
ADCP_BOT=ADCP_BOT.Vel;
ADCP_BOT.yday(find(isnan(ADCP_BOT.yday)))=datenum2yday(ADCP_BOT.dtnum(find(isnan(ADCP_BOT.yday))));

%% Aanderaa
AA=load('AA1531_T7.mat');
AA=AA.rcm;
AA.z=1186;
AA.z=interp1(time_2min,(z_1m_perturb(AA.z,:)+AA.z),AA.time);
AA.z=AA.z';
AA.yday=datenum2yday(AA.time);

%% Other SBEs
%Some variable wrangling is necessary to get them into 'stock' SBE form
%that the toolbox uses.

% This SBE claims to be ( .SN=[8721]), however the time period is right for T7
% Kevin also notes this as 8721 (likely from .SN)
% Also, the depth given MUST be wrong for this, I use 86m vice 509.
SBE_S37=load('SBE37_SN3638.mat');
SBE_S37=SBE_S37.dat;
SBE_S37.yday=datenum2yday(SBE_S37.time(:));
SBE_S37.t=SBE_S37.T;
%SBE_S37.s= some function of SBE_S37.C;
SBE_S37.z=SBE_S37.P; %I'm making an assumption here for shallow depth
SBE_S37.z=z_1m_perturb(86,:)+86;
SBE_S37.z=interp1(datenum2yday(time_2min),SBE_S37.z,SBE_S37.yday);

%Load SBE56 
SBE_S56=load('SBE05601554.mat');
SBE_S56=SBE_S56.dat;
SBE_S56.yday=datenum2yday(SBE_S56.time(:));
SBE_S56.t=SBE_S56.T;
SBE_S56.z=z_1m_perturb(50,:)+50;
SBE_S56.z=interp1(datenum2yday(time_2min),SBE_S56.z,SBE_S56.yday);

%Load SBE 39s
SBE_S39_0665=load('SBE39_SN0665');
SBE_S39_0665=SBE_S39_0665.SBE;
SBE_S39_0665.z=z_1m_perturb(108,:)+108.4;
SBE_S39_0665.t=SBE_S39_0665.temp';
SBE_S39_0665.yday=SBE_S39_0665.yday';
SBE_S39_0665.z=interp1(datenum2yday(time_2min),SBE_S39_0665.z,SBE_S39_0665.yday);

SBE_S39_3074=load('SBE39_SN3074');
SBE_S39_3074=SBE_S39_3074.SBE;
SBE_S39_3074.z=z_1m_perturb(148,:)+147.9;
SBE_S39_3074.t=SBE_S39_3074.temp';
SBE_S39_3074.yday=SBE_S39_3074.yday';
SBE_S39_3074.z=interp1(datenum2yday(time_2min),SBE_S39_3074.z,SBE_S39_3074.yday);

SBE_S39_3071=load('SBE39_SN3071');
SBE_S39_3071=SBE_S39_3071.SBE;
SBE_S39_3071.z=z_1m_perturb(187,:)+187.4;
SBE_S39_3071.t=SBE_S39_3071.temp';
SBE_S39_3071.yday=SBE_S39_3071.yday';
SBE_S39_3071.z=interp1(datenum2yday(time_2min),SBE_S39_3071.z,SBE_S39_3071.yday);

SBE_S39_3254=load('SBE39_SN3254');
SBE_S39_3254=SBE_S39_3254.SBE;
SBE_S39_3254.z=z_1m_perturb(237,:)+236.8;
SBE_S39_3254.t=SBE_S39_3254.temp';
SBE_S39_3254.yday=SBE_S39_3254.yday';
SBE_S39_3254.z=interp1(datenum2yday(time_2min),SBE_S39_3254.z,SBE_S39_3254.yday);

SBE_S39_3253=load('SBE39_SN3253');
SBE_S39_3253=SBE_S39_3253.SBE;
SBE_S39_3253.z=z_1m_perturb(1103,:)+1103;
SBE_S39_3253.t=SBE_S39_3253.temp';
SBE_S39_3253.yday=SBE_S39_3253.yday';
SBE_S39_3253.z=interp1(datenum2yday(time_2min),SBE_S39_3253.z,SBE_S39_3253.yday);

%% Populate Mooring information
clear FP %in case it exists
FP.Project = 'BLOSS_TestRUN-TTIDE';
FP.year=2015;
FP.SN='T7'; %Station Number
FP.depth=nanmean(ADCP_BOT.botdepth);
FP.lon = nanmean(ADCP_BOT.lon);
FP.lat = nanmean(ADCP_BOT.lat);

%% Destination Directories
%These will be used repeatedly
Figure_dir=cd;
Data_dir=cd;

%This is a specific invocation of the directories
FP.Figure_dir=Figure_dir;
FP.Data_dir=Data_dir;


%% First we need to add salinity to T-loggers based on the CTD relation

load('CTD_C2'); % A CTD Cast near T7
cast=All.ctd_down;

%Here we select only the first downcast
indg=find(cast.t(:,1)>0);
tmp=cast.t(indg);
smp=cast.s(indg);
sgmp=cast.sgth(indg);

tall=[tmp];
sall=[smp];

figure(71);
scatter(tall,sall)


% Fit t-s relation
[Ps,Ss]=polyfit(tall,sall,4);

%Apply the t-s relationship to the RBRs and calc sigma-theta
for rbr=1:length(listRBR)
    eval(['SBE_' num2str(listRBR(rbr,1)) '.s=polyval(Ps, SBE_' num2str(listRBR(rbr,1)) '.t);']);
    eval(['SBE_' num2str(listRBR(rbr,1)) '.sgth=sw_pden(SBE_' num2str(listRBR(rbr,1)) '.s,SBE_' num2str(listRBR(rbr,1)) '.t,sw_pres(SBE_' num2str(listRBR(rbr,1)) '.z,FP.lat),0)-1000;']);
end

%% Populate the Mooring Structure with Instruments]
%This creates the blank mooring structure using the FP (Forward Parameters)
Mooring=mkMooring(FP);

%%%%
%
%   Note: the name of the variable passed in to AddInst...(1,THIS ONE) is
%   used later
%
%%%%

%% Add Tloggers / RBRs / Temp only SBEs to Mooring

for rbr=1:length(listRBR)
    eval(['Mooring = AddInstrumentToMooring(Mooring, SBE_' num2str(listRBR(rbr)) ');']);
end

%% Add ADCPs to Mooring

% Top ADCP
Mooring = AddInstrumentToMooring(Mooring, ADCP_TOP);
 
% Bottom ADCP
Mooring = AddInstrumentToMooring( Mooring, ADCP_BOT);

% Middle ADCP
Mooring = AddInstrumentToMooring( Mooring, ADCP_MID);

%% Aanderaa

Mooring = AddInstrumentToMooring( Mooring, AA);

%% SBEs

Mooring = AddInstrumentToMooring( Mooring, SBE_S37);
Mooring = AddInstrumentToMooring( Mooring, SBE_S56);
Mooring = AddInstrumentToMooring( Mooring, SBE_S39_0665);
Mooring = AddInstrumentToMooring( Mooring, SBE_S39_3074);
Mooring = AddInstrumentToMooring( Mooring, SBE_S39_3254);
Mooring = AddInstrumentToMooring( Mooring, SBE_S39_3253);
 
%Set Mooring Directories
Mooring.Figure_dir=Figure_dir;
Mooring.Data_dir=Data_dir;

%% Plot the mooring
%This is a nice thought, but my little laptop runs out of memory when I add
%this many instruments. Keep in mind that the "Mooring" has raw data and
%raw timing

%Uncomment if you've got the RAM

% if savemmp==1
%     PlotMooring(Mooring)
% else
%     ShowMooring(Mooring)
% end

%% Clear Bare Variables to Free Up Memory

for rbr=1:length(listRBR)
    eval(['clear SBE_' num2str(listRBR(rbr,1))]);
end

clear ADCP_TOP ADCP_MID ADCP_BOT AA SBE_S37 SBE_S56 SBE_S39_0665 SBE_S39_3074 SBE_S39_3071 SBE_S39_3254 SBE_S39_3253

%% Check the mooring
Mooring = CheckMooring(Mooring);

%% Save the mooring
if savemmp==1
    fileid=saveDATA(Mooring);
end

%% Create MMP Structure: Here we grid all instruments to a common depth-time

%Andy Notes:
% if no z or yday is given, mkMMP will choose defaults based on dt and dz
% of the individual instruments
% We will choose the spacing here

%%%%% Yo Pay attention here %%%%%%%%%%%%%%%%%%%%%%%%%%
% We are manually overriding the suggested settings. %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dtmin=10; %Time interval in minutes
FP.z = 0:2:Mooring.depth; %depth interval in meters is middle value
FP.yday = 25: dtmin/60/24:63;

% Make the Structure
MMP = mkMMP(Mooring, FP);
MMP.UID=UID;

%% Plot the MMP / Set directories
MMP.VarNamesToShow= {'u','v','s','t','sgth'};
MMP.Figure_dir=Figure_dir;
MMP.Data_dir=Data_dir;
MMP.Figure_name = ['Fig=' MMP.UID '-raw'];

PlotMMP(MMP)

%% Save MMP

if savemmp==1
    MMP.UID=UID;
    MMP.MakeInfo=['Made ' date ' with TTIDE_T7_mooring_Example.m'];
    fileid = saveDATA( MMP );
end

%At this juncture you could start applying the Energy functions from the
%toolbox if you have sufficient coverage for Salinity etc.




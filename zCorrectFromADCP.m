function [ z_1m_perturb, time_2min ] = zCorrectFromADCP()

%% Get rid of this after testing
%clear all
%close all

%% From Where do we get pressure?
%%% We get it from the top, middle and bottom ADCPs
%%% We could refine this if we wanted using pressure from SBEs
cd('/Users/Okeanos/Documents/MATLAB/RR1503_ADCP');
bot=load('T7/ADCP/SN12819/SN12819_TTIDE_ALL.mat');
top=load('T7/ADCP/SN15458/SN15458_TTIDE_ALL.mat');
mid=load('T7/ADCP/SN8122/SN8122_TTIDE_ALL.mat'); 

Nom_bot_Depth=nanmean(bot.Vel.xducer_depth(1:floor(end/2)));

Nom_top_Depth=nanmean(top.Vel.xducer_depth(1:floor(end/2)));

Nom_mid_Depth=nanmean(mid.Vel.xducer_depth(1:floor(end/2)));

%%%This will create a 2m (2*1 day / (24hr*60min)) interval date vector from
%%%the latest early time to the earliest late time (picking the
%%%common/overlapping period)
time_2min = [max([min(top.Vel.dtnum(:)),min(mid.Vel.dtnum(:)),min(bot.Vel.dtnum(:))]):...
    2/(24*60):min([max(top.Vel.dtnum(:)),max(mid.Vel.dtnum(:)),max(bot.Vel.dtnum(:))])];

%% Z work: interpolating to the time vector we use
top_xdcr_inst=interp1(top.Vel.dtnum,top.Vel.xducer_depth,time_2min);
mid_xdcr_inst=interp1(mid.Vel.dtnum,mid.Vel.xducer_depth,time_2min);
bot_xdcr_inst=interp1(bot.Vel.dtnum,bot.Vel.xducer_depth,time_2min);

%% Plot depths
figure()
subplot(3,1,1);
plot(datenum2yday(time_2min),top_xdcr_inst);
xlim([25 63]);
ylim([0 300]);
axis ij
title('Top ADCP xducer Depth')
subplot(3,1,2);
plot(datenum2yday(time_2min),mid_xdcr_inst);
xlim([25 63]);
ylim([50 350]);
axis ij
title('Middle ADCP xducer Depth')
subplot(3,1,3);
plot(datenum2yday(time_2min),bot_xdcr_inst);
xlim([25 63]);
ylim([1370 1410]);
axis ij
title('Bottom ADCP xducer Depth')

%% Plot Knockdown Final Details

%%% Feel free to comment out all these plots once you see what's being done
figure(61)
plot(datenum2yday(time_2min),top_xdcr_inst);
xlim([52 63]);
ylim([0 300]);
axis ij
title('Top ADCP xducer Depth, after major knockdown')
%%
figure(62)
plot(time_2min,bot_xdcr_inst-top_xdcr_inst);
title('Mooring Height Between Top and Bottom ADCP');

%% Create Perturbation Depth Series for point instruments
z_grid_1m=nan(length([1:1:1505]),length(time_2min));

top_perturb=top_xdcr_inst-Nom_top_Depth;
mid_perturb=mid_xdcr_inst-Nom_mid_Depth;
bot_perturb=bot_xdcr_inst-Nom_bot_Depth;



for col=1:length(time_2min)
    z_grid_1m(:,col)=interp1([Nom_top_Depth Nom_mid_Depth Nom_bot_Depth],...
        [top_perturb(col) mid_perturb(col) bot_perturb(col)],[1:1:1505],'linear','extrap');
end

%% Plot Field of Corrections
figure(63)
pcolor(time_2min,[1:1505],z_grid_1m);
shading flat
caxis([0 300])
axis ij
title('Interpolated Depth Correction');
colorbar;

z_1m_perturb=z_grid_1m;
return


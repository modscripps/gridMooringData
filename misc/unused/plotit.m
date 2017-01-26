%plot if requested
if FP.plotit
    figure(1), clf,
    subplot(331), grid on
    plot(Guplot*uno(1:FP.Nm,wh), MMP.z_full, ...
        Gu*uno(1:FP.Nm,wh), MMP.z(FP.gooddepth), ...
        MMP.u(FP.gooddepth,wh), MMP.z(FP.gooddepth), 'k.',...
        MMP.u(:,wh), MMP.z, 'r-')
    axis ij
    ylim([0 MMP.H(1)])
    title(['#' num2str(wh) ', u'])
    disp('u')
    disp(['parameters:' num2str(m')])
    disp(['resid=' num2str(uno(FP.Nm+1,wh))])

    subplot(332), grid on
    h=plot(Guplot,MMP.z_full);
    ylim([0 MMP.H(1)])  
    axis ij
    strs=num2str(uno(1:FP.Nm,wh));
    lg=legend(h,strs,3);set(lg,'fontsize',8)

    subplot(333), grid on
    plot((1:FP.Nm), uno(1:FP.Nm, wh),'k*')
    xlim([0 FP.Nm])
    xlabel('mode #')


    subplot(334), grid on
    plot(Guplot*vno(1:FP.Nm,wh),MMP.z_full,...
        Gu*vno(1:FP.Nm,wh),MMP.z(FP.gooddepth),...
        MMP.v(FP.gooddepth,wh),MMP.z(FP.gooddepth),'k.',...
        MMP.v(:,wh),MMP.z,'r-')
    axis ij
    ylim([0 MMP.H(1)])
    title(['#' num2str(wh) ', v'])
    disp('v')
    disp(['parameters:' num2str(m')])
    disp(['resid=' num2str(vno(FP.Nm+1,wh))])

    subplot(335), grid on
    h=plot(Guplot,MMP.z_full);
    ylim([0 MMP.H(1)])  
    axis ij
    strs=num2str(vno(1:FP.Nm,wh));
    lg=legend(h,strs,3);set(lg,'fontsize',8)

    subplot(336), grid on
    plot((1:FP.Nm), vno(1:FP.Nm, wh),'k*') %zzx, 08/16/06, what is S?
    xlim([0 FP.Nm])
    xlabel('mode #')

    subplot(337), grid on
    plot(Gdplot*dno(1:FP.Nmd,wh), MMP.z_full, ...
         Gd*dno(1:FP.Nmd,wh), MMP.z(FP.gooddepthd),...
         MMP.eta(FP.gooddepthd,wh), MMP.z(FP.gooddepthd), 'k.', ...
        MMP.eta(:,wh), MMP.z,'r-')
    axis ij
    ylim([0 MMP.H(1)])
    title(['#' num2str(wh) ', d'])
    disp('eta')
    disp(['parameters:' num2str(m')])
    disp(['resid=' num2str(dno(FP.Nmd+1,wh))])

    subplot(338), grid on
    h=plot(Gdplot,MMP.z_full);
    ylim([0 MMP.H(1)])  
    axis ij
    strs=num2str(dno(1:FP.Nmd,wh));
    lg=legend(h,strs,3);set(lg,'fontsize',8)

    subplot(339), grid on
    if FP.Nmd > 1
    plot((1:FP.Nmd), dno(1:FP.Nmd, wh), 'k*')
    end
    xlim([0 FP.Nm])
    xlabel('mode #')

    pause
end
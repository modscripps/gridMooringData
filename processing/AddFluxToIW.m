function IW = AddFluxToIW( IW, FP)
%function IW = AddFluxToIW( IW, FP)
%   Computes energy flux 
%       Fu = rho * |<u'p'>|z 
%       Fv = rho * |<v'p'>|z
%       F  = (Fu^2+Fv^2)^(1/2)
%
%   (m, n) = size(IW.u) / size(IW.v) / size(IW.eta) 
%       m: length(IW.z):     vertical grid number
%       n: length(IW.yday):  time grid number
%   
%   Input: IW
%       IW.z:       (m,1): depth (meter)
%       IW.yday:    (1,n): depth (day)
%       IW.eta:     (m,n): displacement (meter)
%       IW.ubc:     (m,n): baroclinic velocity in u (m/s)
%       IW.vbc:     (m,n): baroclinic velocity in v (m/s)
%       IW.sgth:    (m,n)/(m,1)/(1,1): density, rho-1000 (defualt: 26)
%       IW.n2:      (m,n)/(m,1): BF squared, N^2 ((rad/s)^2)
%       IW.depth:   water depth
%       IW.mode:    the nth vertical mode (default: Mode-all)
%
%       FP.BuoyancyFreq:       'n2' or 'n2mean' 
%       FP.period:   cycle in hours
%
%   Output: IW
%       IW.up:     (m,n) <up>: W/m^2     
%       IW.vp:     (m,n) <vp>: W/m^2 
%       IW.p:      (m,n) pressure: N/m^2
%       IW.Fu:     (1,n) integrated up: kW/m
%       IW.Fv:     (1,n) integrated vp: kW/m
%       IW.F:      (1,n) sqrt(Fu^2+Fv^2): kW/m
%
% see also AddEnergyToIW
%
% ZZ @ APL-UW March 17th, 2010
% ZZ @ APL-UW May 16th, 2011


%% display
disp(['Calling function ' mfilename])

%% Now compute a mean density profile
if isfield(IW, 'sgth')
    rhoo = 1000 + nanmean(nanmean(IW.sgth));
else
    rhoo = 1026;
end
if isnan(rhoo), rhoo = 1026; end


%% now prepare n2
N2 = IW.n2;
if size(N2,1)==1 & size(N2,2)~=1
    N2 = N2';
end
%% make it a matrix N2, if N2 is not a matrix
if size(N2,2)==1
    N2 = repmat( N2, size(IW.yday) );
end

%% old codes
% %% now prepare n2 and n2mean
% % IW.n2    
% if size(IW.n2, 1)==1 & size(IW.n2,2)~=1
%     IW.n2 = IW.n2';
% end
% if size( IW.n2, 2 ) == 1
%     IW.n2 = repmat( IW.n2, size(IW.yday) );
% end
% %% IW.n2mean
% IW.n2mean = nanmean(IW.n2, 2);
% IW.n2mean = repmat( IW.n2mean, size(IW.yday) );
% 
% %% switch FP.BV from n2 or n2m
% N2 = IW.(IW.BuoyancyFreq);


%% calculate pressure p
IW.p = nan( size(IW.eta) );

%%
for c = 1 : length(IW.yday)
    ubc     = IW.ubc(:, c);
    vbc     = IW.vbc(:, c);
    eta     = IW.eta(:, c);
    n2      = N2(:, c);
    
    %% vertical grid
    dz = mean( diff(IW.z) );
    
    %% in case eta has nan
    igd = find( ~isnan(eta) );
    if length( igd ) > 3
        eta = interp1( IW.z(igd), eta(igd), IW.z );
    end
    
    phat  = rhoo * nancumsum(n2.*eta).*dz;
    psurf = -nanmean(phat);
    p     = phat + psurf;
    IW.p(:, c) = p;

    %% Fluxes in kW/m^2
    IW.up(:,c) = p .* ubc ;
    IW.vp(:,c) = p .* vbc ;   

    %% record sea surface pressure
    IW.psurf(c) = psurf;
end


%% interval in day
dyday = nanmean( diff(IW.yday) );
%% in order to make the results smoother, ke and pe are 
%% interpolated onto 0.1 current yday grids
yday_fine = nanmin(IW.yday) : 0.1*dyday : nanmax(IW.yday);
%% how many data points in one tidal cycle? DPC
DPC   = round( IW.period/(0.1*dyday)/24 );
%% loop for smooth
warning off
VarNames = {'up'; 'vp'};
for idx_var = 1 : length(VarNames) % for variable names
    name = VarNames{idx_var};
    data = interp1( IW.yday, (IW.(name))', yday_fine);
    data = nanmoving_average(data, DPC, 1, 0);
    newdata = interp1(yday_fine, data, IW.yday);
    IW.(name) = newdata';
end
warning on  

%% take care of end effect
DPC   = round( IW.period/dyday/24 );
for idx_var = 1 : length(VarNames) % for variable names
    name = VarNames{idx_var};
    
    for iz = 1 : length(IW.z)
        %% starte end
        data = IW.(name)(iz,3:DPC); data = data(:); 
        x = 3:DPC; x = x(:);
        [P S] = polyfit( x, data, 1);
        newdata = polyval(P, 1:DPC);
        IW.(name)(iz,1:DPC)=newdata;

        %% starte end
        data = IW.(name)(iz,end-DPC+1:end-2); data = data(:); 
        x = 1:DPC-2; x = x(:);
        [P S] = polyfit( x, data, 1);
        newdata = polyval(P, 1:DPC);
        IW.(name)(iz,end-DPC+1:end)=newdata;
    end
end


%% vertically integrated Fu and Fv
IW.Fu = nansum(IW.up, 1) .* dz / 1000; % W -> kW
IW.Fv = nansum(IW.vp, 1) .* dz / 1000;  

%% where all nans, set as nan
%idx_nan = all( isnan(IW.up) );
% have to have half-column profile
%idx_nan = all( isnan(IW.vp) );
% have to have half-column profile
idx_nan = sum(~isnan(IW.up), 1) < 0.5*length(IW.z);
IW.Fu( idx_nan ) = nan;
idx_nan = sum(~isnan(IW.vp), 1) < 0.5*length(IW.z);
IW.Fv( idx_nan ) = nan;  
IW.F  = sqrt( IW.Fu.^2 + IW.Fv.^2 );

return
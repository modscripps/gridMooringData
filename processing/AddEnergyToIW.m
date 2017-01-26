 function IW = AddEnergyToIW( IW )
%function IW = AddEnergyToIW( IW )
%   Computes kinetic energy and potential energy 
%       KE = 1/2 * rho * (ubc^2+vbc^2); 
%       PE = 1/2 * rho * N^2 * eta^2;
%
%   (m, n) = size(IW.ubc) / size(IW.vbc) / size(IW.eta) 
%       m: length(IW.z):    vertical grid number
%       n: length(IW.yday): time grid number
%   
%   Input: IW
%       IW.z:       (m,1): depth (meter)
%       IW.yday:    (1,n): depth (day)
%       IW.eta:     (m,n): displacement (meter)
%       IW.ubc:     (m,n): baroclinic velocity in u (m/s)
%       IW.vbc:     (m,n): baroclinic velocity in v (m/s)
%       IW.sgth:    (m,n)/(m,1)/(1,1): density, rho-1000 (defualt: 26)
%       IW.n2:      (m,n)/(m,1): BVf squared, N^2 ((rad/s)^2)
%       IW.depth:   water depth
%       IW.mode:    the nth vertical mode (default: Mode-all)
%
%       IW.BuoyancyFreq:       'n2' or 'n2mean' 
%       IW.period:  period in hours 
%
%   Output: IW
%           IW.e
%           IW.ke:      (m,n) k energy density: J/m^3     
%           IW.pe:      (m,n) p energy density: J/m^3 
%           IW.KE:      (1,n) integrated ke: KJ/m^2
%           IW.PE:      (1,n) integrated pe: KJ/m^2
%           IW.E:       (1,n) KE+PE: KJ/m^2
%
% see also AddFluxToIW
%  
% ZZ @ APL-UW March 17th, 2010
% ZZ @ APL-UW May 17th, 2011


%% display
disp(['Calling function ' mfilename])

%%
if ~isfield( IW, 'Result')
    IW.Result = 'all';
end

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
%% Matrix N2
if size(N2,2)==1
    N2 = repmat( N2, size(IW.yday) );
end

%% vertical grid
dz = mean( diff(IW.z) );

%% ke and pe
IW.ke = 1/2 * rhoo * (IW.ubc.^2 + IW.vbc.^2);
IW.pe = 1/2 * rhoo * N2 .* IW.eta.^2;  

%% interval in day
dyday = nanmean( diff(IW.yday) );
%% in order to make the results smoother, ke and pe are 
%% interpolated onto 0.1 current yday grids
yday_fine = nanmin(IW.yday) : 0.1*dyday : nanmax(IW.yday);
%% how many data points in one tidal cycle? DPC
DPC   = round( IW.period/(0.1*dyday)/24 );
%% loop for smooth
warning off
VarNames = {'ke'; 'pe'};
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

%% e
IW.e  = IW.ke + IW.pe;

%% integrated KE and PE
IW.KE = nansum(IW.ke, 1) * dz /1000; % J -> kJ
IW.PE = nansum(IW.pe, 1) * dz /1000;

%% where all nans, set as nan
%idx_nan = all( isnan(IW.ke) );
% have to have half-column profile
%idx_nan = all( isnan(IW.pe) );
% have to have half-column profile
idx_nan = sum(~isnan(IW.ke), 1) < 0.5*length(IW.z);
IW.KE( idx_nan ) = nan;
idx_nan = sum(~isnan(IW.pe), 1) < 0.5*length(IW.z);
IW.PE( idx_nan ) = nan;

%% integrated
IW.E  = IW.KE + IW.PE;

return
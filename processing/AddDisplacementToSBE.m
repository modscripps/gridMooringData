function SBE = AddDisplacementToSBE( SBE, FP )
%function SBE = AddDisplacementToSBE( SBE, FP )
%   calculate the vertical displacement from SBE.(FP.varname)
%   SBE.(FP.time):     yday (default)
%   SBE.(FP.varname):  data used, (t, default)
%   FP.window:         5 days (defaut)
%
%   Output:
%       SBE.para_eta:  parameter    
%       SBE.dzSBE:     displacement due to movement of SBE
%       SBE.eta:       vertical displacement
%
% ZZ @ APL-UW, April 30th, 2010
% ZZ @ APL-UW, November 8th, 2010
% last touch by ZZ @ APL-UW, March 9th, 2011


%%
disp(['Calling function ' mfilename ])
    

%% check FP and its parameters
%% FP
if ~exist( 'FP', 'var') 
    FP = struct; 
end

%% FP.time
if ~isfield( FP, 'time' )
    FP.time    = 'yday'; % time-series is 'yday' 
end

%% FP.varname
if ~isfield( FP, 'varname' )
    FP.varname = 't'; % or sgth
%    FP.varname = 'sgth';     
end

%% FP.dtdz / FP.dsgthdz
GRAD = ['d' FP.varname 'dz'];
if ~isfield( FP, GRAD )
    FP.(GRAD) = nan;
    warning(['!!! FP.' GRAD ' is required !!!']) 
end

%% save parameters
SBE.(['para_eta']) = FP;

%% step 1: copy dtdz from FP to SBE
%% interpolte actually
%SBE.dtdz = FP.dtdz; % old
if length( FP.yday )  == 1
    SBE.(GRAD) = FP.(GRAD) * ones(size(SBE.yday));
else
    SBE.(GRAD) = interp1(FP.yday, FP.(GRAD), SBE.yday);
end

%% step 2: calculate eta from varname t
DATA = SBE.(FP.varname);
MEAN = nanmedian( DATA );
SBE.eta  = (DATA-MEAN) ./ SBE.(GRAD);


%% step 3: check perturbation p: DisP 
% the baroclinic p is very small, compared with that associated with  
% hydrographic pressure of 
% mooring movement, so p indicates the SBE's vertical movement
% must correct it. For IWAP06, it is insignifcant, <2 m;
% for Luzon, it is a huge amount, ~30 m;
% since this correction, all cases will be corrected for this movement
% Note: using z = sw_dpth(SBE.p, SBE.lat) may get the very same result
if isfield( SBE, 'p' )
    PP = SBE.p;
else
    PP = zeros(size(SBE.(FP.varname)));
end
%dz is positive upward, negative p means positive vertical displavement
%dzSBE, p is dbar (1 dbar ~ 1 m)
SBE.dzSBE = -(PP-nanmedian(PP));


%% set 4: correct eta using DisP, where P is pressure
%eta is positive upward, so that
%where dzSBE is positive --> 
%SBE shifts upward from mean --> 
%dzSBE should be removed from eta
SBE.eta = SBE.eta - SBE.dzSBE;
SBE.eta = SBE.eta - nanmedian(SBE.eta); % a constant is subtracted

return;
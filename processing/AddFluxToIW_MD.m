function IW = AddFluxToIW_MD( IW )
%function IW = AddFluxToIW_MD( IW, FP)
%   Compute kinetic energy and potential energy 
%       KE = 1/2 * rho * (u^2+v^2); 
%       PE = 1/2 * rho * N^2 * eta^2;
%
%   (m, n) = size(IW.u) / size(IW.v) / size(IW.eta) 
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
%       IW.BuoyancyFreq:  'n2' or 'n2mean' 
%       IW.FreqBand:      'SEMI' / 'DIURNAL' / 'M2' / 'S2' / 'NI'
%       IW.period:        cycle in hours

%   Output: IW
%       IW.ModalResult = 'all'
%          IW.psurf_md: pressure at sea surface
%          IW.p_md:      pressure
%          IW.up_md:     (m,n) <up>: W/m^2     
%          IW.vp_md:     (m,n) <vp>: W/m^2 
%          IW.Fu_md:     (1,n) integrated up: kW/m
%          IW.Fv_md:     (1,n) integrated vp: kW/m
%          IW.F_md:      (1,n) sqrt(Fu^2+Fv^2): kW/m
%       IW.ModalResult = 'simple'
%          IW.psurf_md: pressure at sea surface
%          IW.Fu_md:     (1,n) integrated up: kW/m
%          IW.Fv_md:     (1,n) integrated vp: kW/m
%          IW.F_md:      (1,n) sqrt(Fu^2+Fv^2): kW/m
%
% see also AddFluxToIW
%
% ZZ @ APL-UW March 17th, 2010


%% display
disp(['Calling function ' mfilename])


%%
if ~isfield( IW, 'ModalResult' ) 
    IW.ModalResult = 'simple';
end


%% create data fields to save results
if strcmp(IW.ModalResult, 'all') 
    IW.p_md  = nan( length(IW.z_full), length(IW.yday), IW.Nmode );
    IW.up_md = nan( length(IW.z_full), length(IW.yday), IW.Nmode );
    IW.vp_md = IW.up_md;
    IW.Fu_md = nan( length(IW.yday), IW.Nmode );
    IW.Fv_md = IW.Fu_md;
    IW.F_md  = IW.Fu_md;
    IW.psurf_md  = IW.Fu_md;
elseif strcmp(IW.ModalResult, 'simple') 
    IW.up_md = zeros( length(IW.z_full), length(IW.yday));
    IW.vp_md = IW.up_md;
    IW.Fu_md = nan( length(IW.yday), IW.Nmode );
    IW.Fv_md = IW.Fu_md;
    IW.F_md  = IW.Fu_md;
    IW.psurf_md  = IW.Fu_md;
end


%%
for md = 1 : IW.Nmode
  
    %% create mmp using modal results
    clear mmp
    %% some data fields
    VarNames = {'lon'; 'lat'; 'year'; 'yday'; 'depth'; ...
                'FreqBand'; 'period'; 'BuoyancyFreq'}; 
    for idx = 1 : length(VarNames)
        varname = VarNames{idx};
        mmp.(varname) = IW.(varname);
    end
    %% MUST data fields
    VarNames      = {'eta';  'ubc'; 'vbc'};
    VarNames_md   = {'etan'; 'un';  'vn'};    
    VarNames_full = {'vert_full'; 'hori_full'; 'hori_full'};
    for idx = 1 : length(VarNames)
        varname     = VarNames{idx};
        varname_md  = VarNames_md{idx};
        varnamefull = VarNames_full{idx};
        
        if length(size(IW.(varnamefull))) < 3
            mmp.(varname) = IW.(varnamefull)(:, md) * IW.(varname_md)(md, :);

        elseif length(size(IW.(varnamefull))) == 3
            for wh = 1 : size(IW.(varnamefull), 3)
                mmp.(varname)(:, wh) = ...
                    IW.(varnamefull)(:, md, wh) * IW.(varname_md)(md, wh);            
            end
        end
    end    
    % mmp.eta   = IW.vert_full(:, md) * IW.etan(md, :);
    % mmp.ubc   = IW.hori_full(:, md) * IW.un(md, :);
    % mmp.vbc   = IW.hori_full(:, md) * IW.vn(md, :);
    %% more data fields:  z and n2
    mmp.z     = IW.z_full;
    mmp.n2    = interp1(IW.z, IW.n2, mmp.z);
    %% sgth
    if isfield( IW, 'sgth')
        mmp.sgth = interp1(IW.z, IW.sgth, mmp.z); 
    end
            
    % computate energy for each mode
    mmp = AddFluxToIW( mmp );
        
    % save results back to IW
    if strcmp(IW.ModalResult, 'all') 
        IW.psurf_md(:, md) = mmp.psurf;    
        IW.p_md(:, :, md) = mmp.p;
        IW.up_md(:, :, md) = mmp.up;
        IW.vp_md(:, :, md) = mmp.vp;
        IW.Fu_md(:, md) = mmp.Fu;
        IW.Fv_md(:, md) = mmp.Fv;
        IW.F_md(:, md)  = mmp.F;
    elseif strcmp(IW.ModalResult, 'simple') 
        IW.up_md = IW.up_md + mmp.up;
        IW.vp_md = IW.vp_md + mmp.vp;
        IW.psurf_md(:, md) = mmp.psurf;    
        IW.Fu_md(:, md) = mmp.Fu;
        IW.Fv_md(:, md) = mmp.Fv;
        IW.F_md(:, md)  = mmp.F;        
    end
    
end

return

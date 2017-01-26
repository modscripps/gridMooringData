function IW = AddEnergyToIW_MD(IW, FP)
%function IW = AddEnergyToIW_MD( IW, FP)
%   computates energy using modal decomposed results
%       KE = 1/2 * rho * (u^2+v^2); 
%       PE = 1/2 * rho * N^2 * eta^2;
%
%   (m, n) = size(IW.u) / size(IW.v) / size(IW.eta) 
%       m: length(IW.z):    vertical grid number
%       n: length(IW.yday): time grid number
%   
%   Input: IW
%       IW.z_full:          (m, 1): depth (meter)
%       IW.vert_full:       (m, md): depth (meter)
%       IW.hori_full:       (m, md): depth (meter)
%       IW.n2_full:         (m, n)/(m,1): BVf squared, N^2 ((rad/s)^2)
%       IW.yday:            (1,n): depth (day)
%       IW.etan:            (md, n): displacement (meter)
%       IW.un:              (md, n): baroclinic velocity in u (m/s)
%       IW.vn:              (md, n): baroclinic velocity in v (m/s)
%       IW.sgth:            (m,n)/(m,1)/(1,1): rho-1000 (defualt: 26)
%       IW.period:          period in hours
%       IW.BuoyancyFreq:    'n2' or 'n2mean' 
%
%   Output: IW
%       IW.ModalResult = 'all'
%         IW.ke:      (m, n, md) k energy density: J/m^3     
%         IW.pe:      (m, n, md) p energy density: J/m^3 
%         IW.KE:      (n, md) integrated ke: KJ/m^2
%         IW.PE:      (n, md) integrated pe: KJ/m^2
%         IW.E:       (n, md) KE+PE: KJ/m^2
%
%       IW.ModalResult = 'simple'
%         IW.KE:      (n, md) integrated ke: KJ/m^2
%         IW.PE:      (n, md) integrated pe: KJ/m^2
%         IW.E:       (n, md) KE+PE: KJ/m^2
% 
% see also AddEnergyToIW
%
% ZZ @ APL-UW March 24, 201


%% display calling
disp(['Calling function ' mfilename ])


%%
if ~isfield( IW, 'ModalResult' ) 
    IW.ModalResult = 'simple';
end

    
%% create data fields to save results
if strcmp(IW.ModalResult, 'all') 
    IW.ke_md = nan( length(IW.z_full), length(IW.yday), IW.Nmode );
    IW.pe_md = IW.ke_md;
    IW.KE_md = nan( length(IW.yday), IW.Nmode );
    IW.PE_md = IW.KE_md;
    IW.E_md  = IW.KE_md;
elseif strcmp(IW.ModalResult, 'simple') 
    IW.ke_md = zeros(length(IW.z_full), length(IW.yday));
    IW.pe_md = IW.ke_md;
    IW.KE_md = nan( length(IW.yday), IW.Nmode );
    IW.PE_md = IW.KE_md;
    IW.E_md  = IW.KE_md;
end


%% for each mode, call AddEnergyToIW
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
    
    %% computate energy for each mode by calling
    mmp = AddEnergyToIW( mmp );
    
    %% save results back to IW
    if strcmp(IW.ModalResult, 'all') 
        IW.ke_md(:, :, md) = mmp.ke;
        IW.pe_md(:, :, md) = mmp.pe;
        IW.KE_md(:, md) = mmp.KE;
        IW.PE_md(:, md) = mmp.PE;
        IW.E_md(:, md) = mmp.E;
    elseif strcmp(IW.ModalResult, 'simple') 
        IW.ke_md = IW.ke_md + mmp.ke;
        IW.pe_md = IW.pe_md + mmp.pe;
        IW.KE_md(:, md) = mmp.KE;
        IW.PE_md(:, md) = mmp.PE;
        IW.E_md(:, md) = mmp.E;
    end
end

return
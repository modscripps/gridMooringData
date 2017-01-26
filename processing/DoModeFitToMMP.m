function MMP = DoModeFitToMMP(MMP, FP)
%function MMP = DoModeFitToMMP(MMP, FP)
%   decomposes (u, v, eta) into discrete modes
%
%   INPUT:
%       a set of modes, defined over the whole water depth
%       MMP.z_full:         vertical grid
%       MMP.vert_full:      (m,n,k) vertical modes (eta, w)
%       MMP.hori_full:      (m,n,k) horizontal modes (u, v)
%
%       data fields
%       MMP.z :             depths of the measurements
%       MMP.u:              u velocity
%       MMP.v:              v velocity
%       MMP.eta:            eta displacement         
%
%
%   Forward Parameters: FP
%       FP.Nmode:         number of displacement modes to solve
%       FP.plotit:          plot for each profile (Default = off)
%       FP.good_percent:    Requiring less than FP.reqperc of nan points 
%                           (Default, FP.reqperc = 0.25)
%
%   Output:  Add more data fields to MMP
%       FP.un:              Amplitude of modal u
%       FP.vn:              Amplitude of modal v 
%       FP.etan:            Amplitude of modal eta
%
%       FP.un_resi:              residual
%       FP.vn_resi:              residual 
%       FP.etan_resi:            residual
%
%       FP.unbt:            Mode-0 or barotropic u
%       FP.vnbt:            Mode-0 or barotropic v
%
% see also PlotModeFit
% 
%% modified from MHA's ModeFitFCN.m 10/05
%% modified for IWAP moorins as ModeFitCTD_zx 08/08
%% modidied for MC09 and standardized for all MMP 03/10
%% modidied for variabel modal structure 04/2011
%% modified for (u, v) decomposition without removing mean, thus 
%  no (unbt, vnbt) results


%% display
disp(['Calling function ' mfilename])

%% check FP and its parameters
% FP
if ~exist('FP', 'var')
    FP = struct;
end
% FP.Nmode
if ~isfield(FP, 'Nmode')
    FP.Nmode = 5; % Number of modes to solve for.
end
% FP.showit
if ~isfield(FP, 'printit')
    FP.printit = 1;
end
% FP.reqperc
if ~isfield(FP, 'good_percent')
    FP.good_percent = .85;
end
% FP.fit_bt
if ~isfield(FP, 'fit_bt')
    FP.fit_bt = 1;
end

%% save FP
MMP.para_ModeFit = FP;


%% list of variables
VarNames = {'u'; 'v'; 'eta'};
%% list of modes
ModeNames = {'hori_full'; 'hori_full'; 'vert_full'};


%% add un, vn and etan to MMP
for idx_var = 1 : length(VarNames)
    varname = VarNames{idx_var};
    MMP.([varname 'n']) = nan(FP.Nmode, size(MMP.yday, 2));
end

%% add un_resi, vn_resi and etan_resi to MMP
for idx_var = 1 : length(VarNames)
    varname = VarNames{idx_var};
    MMP.([varname 'n_resi']) = nan( size(MMP.yday) );
end

%% add unbt and vnbt to MMP
for idx_var = 1 : 2
    varname = VarNames{idx_var};
    MMP.([varname 'nbt'])   = nan( size(MMP.yday) );
end


warning off
%% Now loop and do each profile requested
LENGTH = length( MMP.yday );

for wh = 1 : LENGTH
    
    %% displaying progress
    if rem(wh, 100) == 0
        disp(['   working on profile ' num2str(wh) ' of ' num2str(LENGTH)] )
    end
    
    %% running on u, v and eta
    for idx_var = 1 : 3  
        varname  = VarNames{idx_var};
        modename = ModeNames{idx_var};
        
        %% Number of layers 
        Num_Of_Layer = length( MMP.z );
        
        
        %% get data from MMP
        data = MMP.(varname)(:, wh);
       
        %% G is the matrix from modes
        if length(size(MMP.(modename))) < 3
            G = interp1( MMP.z_full, MMP.(modename), MMP.z );
            G = G(:, 1:FP.Nmode);
        elseif length(size(MMP.(modename))) == 3
            G = interp1( MMP.z_full, MMP.(modename)(:,:,wh), MMP.z );
            G = G(:, 1:FP.Nmode);            
        end
            
  
        %% if fit (unbt, vnbt) or not
        %% add I to G for u and v
        if FP.fit_bt == 1 & (strcmp(varname,'u')|strcmp(varname,'v'))
            I = ones(size(data));
            G = [G I];
        end

        %% check bad data per profile
        idx_bd = find( isnan(data) | isnan(G(:,1)) );
        data(idx_bd) = [];   % get rid of nan data
        G(idx_bd, :) = [];
            
        if length(data) > FP.good_percent * Num_Of_Layer

            %% call regress to do mode fitting
            [B, BINT, R, RINT, STATS] = regress( data, G);

            %% store answers and errors
            MMP.([varname 'n'])(1:FP.Nmode, wh) = B(1:FP.Nmode);
            MMP.([varname 'n_resi'])(wh) = var(data-G*B);            
            
            %% for u and v, save bt (from I)
            if FP.fit_bt == 1 & (strcmp(varname,'u')|strcmp(varname,'v'))
                MMP.([varname 'nbt'])(wh) = B(end);
            end
        end
        
    end
end

warning on
return
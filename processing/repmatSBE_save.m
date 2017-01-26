function SBE = repmatSBE( SBE, FP)
%function SBE = repmatSBE( SBE, FP)
%   expands SBE's single-layer SBE to multi-layer
%
%   SBE:
%       SBE.(FP.Varnames)
%       SBE.z:         depth of SBE
%   
%   FP:
%       FP.dz            default(=2m) vertical z grid size
%       FP.num_layer     default(=10) number of layers
%       FP.VarNames      default({'t';'s'}) variable list
%
% see also repmat
%
% ZZ @ APL-UW, April 9th, 2010


%%
disp(['Calling function ' mfilename])


%% check FP and its parameters 
%% FP
if ~exist( 'FP', 'var')
    FP = struct;
end

%% FP.VarNames
if ~isfield( FP, 'VarNames' )
   FP.VarNames = {'t'; 's'}; 
end

%% FP.VarNames
idx_gd = [];
for idx = 1 : length(FP.VarNames)
    if isfield( SBE, FP.VarNames(idx) ), 
        idx_gd = [idx_gd idx]; 
    end
end
FP.VarNames = {FP.VarNames{idx_gd}};

%% FP.dz
if ~isfield( FP, 'dz')
    FP.dz = 2;  % default
end

%% FP.num_layer
if ~isfield( FP, 'num_layer' )
   FP.num_layer = 10;  % default 
end

%% create new zz
SBE.z0 = SBE.z;
z = round( SBE.z/FP.dz ) * FP.dz;

%%
zz = FP.dz * (1:FP.num_layer);
zz_middle = mean(zz);
zz_middle = round( zz_middle/FP.dz ) * FP.dz;
SBE.z = zz(:)+z-zz_middle;

%%
for idx_var = 1 : length( FP.VarNames )
   varname = FP.VarNames{idx_var};
   data = SBE.(varname);
   [m, n] = size( data );
   if n == 1, data = data'; end
   
   if m ~= 1 & n ~= 1, 
       error(['  !!! SBE.' varname 'is not one-layer data']) 
   end
   
   SBE.(varname) = repmat( data, size(SBE.z) );
end

return
function [ygrid, lclose] = GriddingOrAssigning(dim, maxdist, x, y, xgrid, lclose)
% ygrid = GRIDDINGORASSIGNING(dim, maxdist, x, y, xgrid)
%
%   inputs:
%       - dim: dimension to work on
%       - maxdist: maximum distance to grid
%       - x: independent variable (may be a matrix)
%       - y: variable to grid
%       - xgrid: grid to interpolate onto. MUST BE
%                A VECTOR (or a even a scalar).
%       - lclose (optional): this is a logical variable which is true for
%                            the locations where data is interpolated.
%
%   outputs:
%       - ygrid: gridded y.
%
%
% Input lclose is useful for instruments that measure multiple variables
% to be gridded. For example, a CTD measures multiple variables (S and T).
% When this function is first called for interpolating S, this function
% does not take lclose as input, but it creates one indicating the
% locations on the grid where S is interpolated. When calling this function
% again for gridding T, the lclose previously created is taken as an input,
% such that T is interpolated on the same locations as S.
%
% Olavo Badaro Marques, 10/Jan/2017.


%% Pre-allocate space for ygrid:

if dim==1
    
    sizeoutput = [length(xgrid), size(y, 2)];
    
elseif dim==2
    
    sizeoutput = [size(y, 1), length(xgrid)];
    
else
    error('error!')
end

ygrid = NaN(sizeoutput);


%% Take the .....

[ry, cy] = size(y);

% Choose ny to loop over the other dimension:
if dim==1
    ny = cy;
else  % dim==2
    ny = ry;
end


% Make indices to choose appropriate rows/columns
% no matter whether x is a vector or matrix:

[rx, cx] = size(x);

if dim==1
    
    if cx>1
        indx = 1:cx;
    else
        indx = ones(1, ny);
    end
    
else
    
    if rx>1
        indx = 1:rx;
    else
        indx = ones(1, ny);
    end
    
end


%% Create/Pre-allocate space for lclose if it is not given as input:

if nargin<6
    lclose = false(sizeoutput);
end


%% Loop over nx and grid or assign:

for i = 1:ny
    
    %
    if dim==1
        xaux = x(:, indx(i));
        yaux = y(:, i);
    else
        xaux = x(indx(i), :);
        yaux = y(i, :);
    end

    %
    if length(yaux)==1
        xaux = xaux(i);
    end
    
    % Subset for non-NaN xaux/yaux points:
    lgood  = ~isnan(xaux) & ~isnan(yaux);
    xaux = xaux(lgood);
    yaux = yaux(lgood);

    
    % Grid or Assign:
    if isempty(xaux)
%         warning(' ! yday is empty... no interpolation')
% keyboard
    elseif length(xaux) == 1

        % Copy to the nearest one if it is close enough:
        [indclosest, distFromData] = dsearchn(xgrid(:), xaux);
        
        % Assign value to output if it is close enough:
        if distFromData <= maxdist
            if dim==1
                ygrid(indclosest, i) = yaux;
            else
                ygrid(i, indclosest) = yaux;
            end
        end
        
    else

        % If lclose is not given as input, compute lclose
        % for this iteration (i.e. auxlclose) and assign
        % it to the proper location in lclose:
        if nargin<6
            % First check what are the grid points that
            % are close to enough to the data:
            [~, distFromData] = dsearchn(xaux(:), xgrid(:));

            auxlclose = (distFromData <= maxdist);
            
            if dim==1
                lclose(:, i) = auxlclose;
            else
                lclose(i, :) = auxlclose;
            end
         
        % Otherwise, just pick auxlclose from the
        % appropriate location in the input lclose:
        else
            
            if dim==1
                auxlclose = lclose(:, i);  % column if interpolating in depth
            else
                auxlclose = lclose(i, :);  % row if interpolating in time
            end
            
            
        end
        
        % Finally, interpolate data in time:
        yaux_gridded = interp1(xaux, yaux, xgrid(auxlclose));

        % Assign interpolated variable to
        % the previously created array:
        if dim==1
            ygrid(auxlclose, i) = yaux_gridded;
        else
            ygrid(i, auxlclose) = yaux_gridded;
        end
   
    end 
    
end

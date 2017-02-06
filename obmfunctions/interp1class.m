classdef interp1class
    % Class INTERP1CLASS defined to make it easy to do 1D interpolation
    % based on arrays that are NOT specified at the same location, with
    % respect to the independent variable. In other words, for cell arrays
    % x and y, where each field is a vector, first do:
    %
    %   obj = INTERP1CLASS(x, y)
    %
    % which creates a variable obj of class INTERP1CLASS. Then do:
    %
    %	obj.interpxy(xi, yi)
    %
    % to interpolate each vector of y on xi and then, for every xi,
    % interpolate y onto yi values.  
    %
    % Olavo Badaro Marques, 30/Jan/2017.
    
    %% Define properties of the object:
    
    properties
        xarrays    % cell array with sets of independent variables
    end
    
    properties
        yarrays    % cell array with sets of the dependent variable
    end
    
    properties
        ybase      % double array with "base levels"
    end            % (like the mean) of each set of y
    
    
    %% Define the methods of the object:
    methods
        
        function obj = interp1class(x, y, baseperiod)
            %% obj = INTERP1CLASS(x, y, baseperiod)
            %
            %   inputs:
            %       - x: cell array of vectors.
            %       - y: cell array of vectors (each entry must have the
            %            same length as the correspondent in x).
            %       - baseperiod (optional): vector with two elements
            %                                specifying the interval (in
            %                                units of x) for which the base
            %                                values of y will be computed
            %                                from. Default is the entire
            %                                interval where y is given.
            %
            %   output:
            %       - obj: object of class INTERP1CLASS with the
            %              properties xarrays, yarrays and ybase.
            
            %Something to check inputs
            if nargin>=2
                obj.xarrays = x;
                obj.yarrays = y;
            else
%                 error(['When calling  ')
            end 
            
            % Now compute ybase (this should probably be a
            % different method though):
            Nx = length(x);
            indsubset = NaN(Nx, 2);
            if nargin==3
                
                for i = 1:Nx
                    indsubset(i, :) = dsearchn(x{i}(:), baseperiod(:))';
                end
                
            else
                
                indsubset = [ones(Nx, 1), cellfun(@length, x)'];
                
                % I should probably exclude the for loop below and assign
                % values obj.ybase in each if/else case:
                % obj.ybase = cellfun(@nanmedian, obj.yarrays());
            end
            
            obj.ybase = NaN(1, Nx);
            for i = 1:Nx
                indaux = indsubset(i, 1) : 1 : indsubset(i, 2);
                
                obj.ybase(i) = nanmedian(obj.yarrays{i}(indaux));
            end
            
        end
        
        
        function yinterp = interpxy(obj, xi, yi)
            %% yinterp = INTERPXY(obj, xi, yi)
            %
            %   inputs:
            %       - obj:
            %       - xi: 
            %       - yi: 
            %
            %   output:
            %       - obj: 
            
            N = length(obj.xarrays);
            
            % Sort obj.ybase in increasing order:
            [obj.ybase, indsort] = sort(obj.ybase);

            % Now sort the time and pressure records:
            obj.xarrays = obj.xarrays(indsort);
            obj.yarrays = obj.yarrays(indsort);

            % First interpolate each vector of yarrays
            % onto xi locations in the column space:
            yonxi = NaN(N, length(xi));
            
            for i = 1:N
                yonxi(i, :) = interp1(obj.xarrays{i}, ...
                                        obj.yarrays{i}, xi);
            end
            
            % Now, for every xi, interpolate yonxi
            % across the row space (at the yi locations):
            yinterp = NaN(length(yi), length(xi));

            for i = 1:length(xi)
                yinterp(:, i) = interp1(obj.ybase, yonxi(:, i), yi);
            end
                        
        end
        
    end   % end the definition of methods
    
end
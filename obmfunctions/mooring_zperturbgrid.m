function interpObj = mooring_zperturbgrid(FP, moorsensors, moordata)
% interpObj = mooring_zperturbgrid(FP, moorsensors, moordata)
%
%  inputs:
%    - FP: forward parameters containing mooring information. The
%          relevations fields are FP.SN (th id of the mooring) and
%          FP.depth (the water depth at the mooring location).
%    - moorsensors: struct variable with the serial number
%                   of all sensors on the mooring.
%    - moordata: struct variable with all the raw mooring data. In order
%                to avoid potential problems, moordata must be the output
%                of the extraDataEditing function.
%
%  outputs:
%    - interpObj: an object of class interp1general, which is defined and
%                 created by the m-file interp1general.m.
%
% Function MOORING_ZPERTURBGRID calls interp1general.m to create
% an object to interpolate for the depth perturbed by knockdown.
% The knockdown correction itself is done by the function
% correctKnockDownZ.m, which takes as input the interpObj output
% of MOORING_ZPERTURBGRID.
%
% Olavo Badaro Marques, 07/14/2016.


%% Type of pressure-recording instruments we want to look
%  for to get their actual depth as a function of time:

instr_presrecords = {'RBRConcerto', 'SBE37', 'SBE39', 'RDIadcp'};


%% Check which of the instruments in instr_presrecords are
%  present in the mooring moorid:

instrP = intersect(instr_presrecords, fieldnames(moorsensors));

if isempty(instrP)
    
    warning(['Mooring ' FP.SN ' has no instruments of the types '   ...
             '' strjoin(instr_presrecords, ', ') ', those we can ' ...
             'get pressure from. Knockdown correction can  NOT ' ...
             'be applied.'])
         
	% Return NaN as output:
    interpObj = NaN;
         
else
    %% Now we loop through the instrument types in instrP, then
    % loop through the serial numbers in moorsensors, loading the
    % data associated with each of them into 2 cell arrays: one
    % for time and the other for pressure.
    % Loading is done by the "nested function" defined below.

    % First we check how many instruments we will load
    % and assign it to the variable ninstr:
    ninstr = NaN(length(instrP), 1);

    for i = 1:length(instrP)
        ninstr(i) = size(moorsensors.(instrP{i}), 1);
    end
   
    % Get the pressure time series. If an instrument of type
    % instr_presrecords did not measure pressure (for whatever
    % reason) it should have a pressure array only with NaNs.
    % In this case, this (useless) timeseries is excluded:
    timepresStruct = emptyStructArray(instrP, 1);
    lmoorsensUsed = emptyStructArray(instrP, 1);

    for i1 = 1:length(instrP)

        timepresStruct.(instrP{i1}) = emptyStructArray({'timepres'}, ninstr(i1));

        lmoorsensUsed.(instrP{i1}) = false(ninstr(i1), 1);
        
        indadd = 0;

        % Loop through serial numbers of one instrument type:
        for i2 = 1:ninstr(i1)

            auxtimepres = extractTimePres(instrP{i1}, moordata.(instrP{i1})(i2), FP.lat);                    

            if ~all(isnan(auxtimepres(:, 2)))

                indadd = indadd + 1;
                timepresStruct.(instrP{i1})(indadd).timepres = auxtimepres;

                % Assign true to the instrument indices where we do have a
                % pressure time series to use for knockdown correction
                lmoorsensUsed.(instrP{i1})(i2) = true;
            end

        end

        if indadd > 0
            timepresStruct.(instrP{i1}) = timepresStruct.(instrP{i1})(1:indadd);
        else
            timepresStruct = rmfield(timepresStruct, instrP{i1});
        end

    end

    % Update the list of instruments that measured
    % pressure and how many of them exist:
    instrP = fieldnames(timepresStruct);
    ninstr = structfun(@length, timepresStruct);
        
    
    % ----------------------------------------------------
    % TO DO:
    % Print to the screen (let the user know) the instrument list
    % instrP (which instruments are being used for estimating knockdowns):
    % ----------------------------------------------------
    
    % Only do knockdown correction if there is at
    % least 1 pressure-recording instruments:
    if sum(ninstr)>0
        
        % Pre-allocate space for the two cell arrays:
        nrecords = sum(ninstr);
        alltime = cell(1, nrecords);
        allpres = cell(1, nrecords);
        allnomdpth = NaN(1, nrecords);

        % Now we loop through instrument types:
        for i1 = 1:length(instrP)

            % Indices of the pressure-measuring
            % instruments in moorsensUsed
            inds_used_aux = find(lmoorsensUsed.(instrP{i1}));
            
            % Loop through serial numbers of one instrument type:
            for i2 = 1:ninstr(i1)

%                 timepres = extractTimePres(instrP{i1}, moordata.(instrP{i1})(i2));
               
                timepres = timepresStruct.(instrP{i1})(i2).timepres;

                % Get current indice to add the time/pressure records
                % in the appropriate location in the variables
                % alltime/allpres . It looks tricky, but it works because
                % the length of the all* variables is equal to
                % sum(ninstr) (== nrecords):
                indfill = sum([0 ones(1, i1-1)] .* ...
                                    [1 (ninstr((1:length(instrP) < i1)))'] ) + i2;
                
                % Fill in variables:
                alltime{indfill} = timepres(:, 1);
                allpres{indfill} = timepres(:, 2);

                allnomdpth(indfill) = moorsensors.(instrP{i1}){inds_used_aux(i2), 2};

            end

        end


        %% Convert nominal depth pressure
        
        allnompres = sw_pres(allnomdpth, FP.lat);
        

        %% Add surface/bottom pressure "boundary conditions":
        
        % Nominal depths of the sensors/boundaries we know the pressure:
        allnompres = [0, allnompres, sw_pres(FP.depth, FP.lat)];
        
        % Concatenate initial/end timestamps to the alltime cell array:
        minmaxtimes4boundary = [min(cellfun(@min, alltime)); ...
                                max(cellfun(@max, alltime))];
               
        alltime = [minmaxtimes4boundary, alltime, minmaxtimes4boundary];
               
        % Concatenate top and bottom pressures to the allpres cell array
        % (these top and bottom are given/the boundary conditions, rather
        % than from particular instruments):
        allpres = [[allnompres(1); allnompres(1)], ...
                    allpres, ...
                   [allnompres(end); allnompres(end)]];
        
        % -----------------------------------------------------------------
        % TO DO:
        % Actually, the bottom BC is good, but the surface BC is horrible.
        % On the other hand, there is usually a pressure-recording
        % instrument near the top, so th surface BC is not  going to give
        % very wrong results.
        % I probably want to use depth rather than pressure. 
        % -----------------------------------------------------------------
               
        
        %% Convert all pressures (nominal and measured) to depths
        
        %
        allnomdepths = sw_dpth(allnompres, FP.lat);
        
        %
        alldepths = cell(size(allpres));
        for i = 1:length(allpres)
            alldepths{i} = sw_dpth(allpres{i}, FP.lat);
        end
        

        %% Plot the the pressure time series and take the MEDIAN for each
        % instrument, which is overlayed on the plot. Since these MEDIANS
        % are reference values used below it is nice to look at the plot
        % and make sure these meadians are about the same as where we the
        % instruments to be at. Median in computed instead of the mean
        % because it is not as sensitive to values taken before/after
        % the instrument was deployed/recovered:

        % Pre-allocate space for median pressure:
        medianpres = NaN(1, length(allnomdepths));

        % Plot pressure records:
        figure
            hold on, axis ij
            for i = 1:length(allnomdepths)

                hp = plot(alltime{i}, alldepths{i});

                medianpres(i) = nanmedian(alldepths{i});   % compute median

                thistimevec = alltime{i};
                plot(thistimevec([1 end]), [medianpres(i) medianpres(i)], ...
                                                                 'Color', hp.Color)

            end
            axis tight, grid on, box on
            xlimits = xlim;
            set(gca, 'XTick', linspace(xlimits(1), xlimits(2), 7))
            dateformatstr = 'mmm/dd';      % datestr formats
            set(gca, 'XTickLabel', datestr(get(gca, 'XTick'), dateformatstr))
            set(gca, 'FontSize', 14)
            xlabel(['UTC time label datestr format is ' dateformatstr])
            ylabel('Depth as taken from the instruments')
            title(['Depth records on mooring ' FP.SN], 'FontSize', 14)


        %% Figure comparing median with planned nominal pressure/depth:

        % First define an axes limit to make the plot look nice:
        limmaxaxes = max([max(allnomdepths) max(medianpres)]);
        limmaxaxes = 1.10 * limmaxaxes;

        % Then plot the figure:
        figure
            plot(allnomdepths, medianpres, '.k', 'MarkerSize', 22)
            hold on
            plot([0 limmaxaxes], [0 limmaxaxes], 'Color', [0.4 0.4 0.4])
            axis equal
            axis([0 limmaxaxes 0 limmaxaxes])
            grid on
            xlabel('Nominal depth from mooring diagram')
            ylabel('Median computed from the data')
            set(gca, 'FontSize', 14)
          
        
        %% Plot difference between measured and nominal depths
            
        [~, indsort] = sort(allnomdepths);
        
        figure
            plot(medianpres(indsort) - allnomdepths(indsort), ...
                                                    '.k', 'MarkerSize', 28)
            grid on
            set(gca, 'FontSize', 14)
            ylabel('Depth difference [m]')
            title('Measured - Nominal', 'FontSize', 18)
            

        %% Create the general interpolation object:
        
        interpObj = interp1class(alltime, alldepths);
                
        
    end
    
    

    
    
end    % end of if/else statement


end    % end of the main function


%% Nested function defined below:
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

function timepres = extractTimePres(instrtype, datastruct, latitude)
    % timepres = EXTRACTTIMEPRES(instrtype, datastruct, latitude)
    %
    %   inputs:
    %       - instrtype:
    %       - datastruct:
    %
    %   outputs:
    %       - timepres: Nx2 matrix, where time is the first
    %                   column and pressure is the second.
    % 
    % A (supposedly) pressure-measuring instrument that did not
    % measure pressure has a pressure variable with NaNs-only.

    switch instrtype

        case 'RBRConcerto'
            
            timevar = datastruct.time;
            presvar = datastruct.P;
                              
            
        case 'SBE37'
            
            timevar = datastruct.time;
            presvar = datastruct.P;
            
        case 'SBE39'
            
            timevar = datastruct.dtnum;
            presvar = datastruct.P;
            
        case 'RDIadcp'
        
            timevar = datastruct.dtnum;
            dtphvar = datastruct.xducer_depth;
            
            presvar = sw_pres(dtphvar, latitude);
            
    end
    
    % Assign values to the output variable:
    timepres = [timevar(:) presvar(:)];
    

end

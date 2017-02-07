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

instr_presrecords = {'RBRConcerto', 'SBE37', 'RDIadcp'};


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
    
    % ----------------------------------------------------
    % Check whether instruments that are expected to
    % measure pressure really did it. Otherwise, it is
    % not going to work. If they do NOT measure pressure,
    % it should return NaN
    % ----------------------------------------------------
    
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
        allnompd = NaN(1, nrecords);

        % Now we loop through instrument types:
        for i1 = 1:length(instrP)

            % Loop through serial numbers of one instrument type:
            for i2 = 1:ninstr(i1)

                timepres = extractTimePres(instrP{i1}, moordata.(instrP{i1})(i2));

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

                allnompd(indfill) = moorsensors.(instrP{i1})(i2, 2);

            end

        end

        
        %% Add surface/bottom pressure "boundary conditions":
        
        % Nominal depths of the sensors/boundaries we know the pressure:
        allnompd = [0, allnompd, FP.depth];
        
        % Concatenate initial/end timestamps to the alltime cell array:
        alltime = [[max(cellfun(@min, alltime)); min(cellfun(@max, alltime))], ...
                   alltime, ...
                   [max(cellfun(@min, alltime)); min(cellfun(@max, alltime))]];
               
        % Concatenate nominal depths to the allpres cell array:
        allpres = [[allnompd(1); allnompd(1)], ...
                    allpres, ...
                   [allnompd(end); allnompd(end)]];
        
        % -----------------------------------------------------------------
        % TO DO:
        % Actually, the bottom BC is good, but the surface BC is horrible.
        % On the other hand, there is usually a pressure-recording
        % instrument near the top, so th surface BC is not  going to give
        % very wrong results.
        % I probably want to use depth rather than pressure. 
        % -----------------------------------------------------------------
               
        
        %% Plot the the pressure time series and take the MEDIAN for each
        % instrument, which is overlayed on the plot. Since these MEDIANS
        % are reference values used below it is nice to look at the plot
        % and make sure these meadians are about the same as where we the
        % instruments to be at. Median in computed instead of the mean
        % because it is not as sensitive to values taken before/after
        % the instrument was deployed/recovered:

        % Pre-allocate space for median pressure:
        medianpres = NaN(1, length(allnompd));

        % Plot pressure records:
        figure
            hold on, axis ij
            for i = 1:length(allnompd)

                hp = plot(alltime{i}, allpres{i});

                medianpres(i) = nanmedian(allpres{i});   % compute mean

                thistimevec = alltime{i};
                plot(thistimevec([1 end]), [medianpres(i) medianpres(i)], ...
                                                                 'Color', hp.Color)

            end
            axis tight, grid on, box on
            xlimits = xlim;
            set(gca, 'XTick', linspace(xlimits(1), xlimits(2), 7))
            dateformatstr = 'mmm/dd';      % datestr formats
            set(gca, 'XTickLabel', datestr(get(gca, 'XTick'), dateformatstr))
            xlabel(['UTC time label datestr format is ' dateformatstr])
            ylabel('Pressure/depth as taken from the instruments')
            title(['Pressure/depth records on mooring ' FP.SN], 'FontSize', 14)


        %% Figure comparing median with planned nominal pressure/depth:

        % First define an axes limit to make the plot look nice:
        limmaxaxes = max([max(allnompd) max(medianpres)]);
        limmaxaxes = 1.10 * limmaxaxes;

        % Then plot the figure:
        figure
            plot(allnompd, medianpres, '.k', 'MarkerSize', 22)
            hold on
            plot([0 limmaxaxes], [0 limmaxaxes], 'Color', [0.4 0.4 0.4])
            axis equal
            axis([0 limmaxaxes 0 limmaxaxes])
            grid on
            xlabel('Nominal pressure/depth from mooring diagram')
            ylabel('Median computed from the data')

            
        %% Create the general interpolation object:
        
        interpObj = interp1class(alltime, allpres);
                
        
    end
    
    

    
    
end    % end of if/else statement


end    % end of the main function


%% Nested function defined below:
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

function timepres = extractTimePres(instrtype, datastruct)
    % timepres = EXTRACTTIMEPRES(instrtype, datastruct)
    %
    %   inputs:
    %       - instrtype:
    %       - datastruct:
    %
    %   outputs:
    %       - timepres: Nx2 matrix, where time is the first
    %                   column and pressure is the second.
    % SHOULD BE DEPTH!!!!! (all of them have the z field!!!)

    switch instrtype

        case 'RBRConcerto'
            
            timevar = datastruct.dnum;
            presvar = datastruct.p;
                              
            
        case 'SBE37'
            
            timevar = datastruct.time;
            presvar = datastruct.P;
            
            
        case 'RDIadcp'
        
            timevar = datastruct.dtnum;
            presvar = datastruct.xducer_depth;
            
    end
    
    % Assign values to the output variable:
    timepres = [timevar(:) presvar(:)];
    

end

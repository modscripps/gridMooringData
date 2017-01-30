function interpObj = mooring_zperturbgrid(FP, moorsensors, moordata)
% function [zgrid_perturb, time_2min] = mooring_zperturbgrid(FP, moorsensors, moordata)
% [z_1m_perturb, time_2min] = MOORING_ZPERTURBGRID(FP, moorsensors, moordata)
%
%  inputs:
%    - moordir: directory where the mooring data is located.
%    - moorid: mooring name.
%    - moorsensors: struct variable with the serial number
%                   of all sensors on the mooring.
%
%    - FP:
%    - moorsensors:
%    - moordata:
%
%  outputs:
%    -
%    -
%
% Function MOORING_ZPERTURBGRID
%
% Inside this function we use the script containing info about
% all instruments in the mooring moorid. It is assumed this
% scripts is in the folder moordir.
%
% Olavo Badaro Marques, 07/14/2016.


% WHAT IS THE PERTURBATION CALCULATION??? SHOULD I INCLUDE DIFFERENT
% OPTIONS????

% I DISAGREE WITH BOTH OUTPUTS! IN MY MIN, IDEALLY (PYTHON) THE OUTPUT
% WOULD BE A FUNCTION TO APPLY FOR THE TLOGGERS IN THE MOORING. I CAN DO
% SOOMETHING SIMILAR IN MATLAB.

% TO CREATE z_1m_perturb I NEED THE DEPTH OF DEEPEST INSTRUMENT OR BOTTOM
% DEPTH TO BE SURE. HOW SHOULD I INCORPORATE THAT. THAT WOULD NOT BE
% NECESSARY IF I MAKE MY THING ABOVE.


%% Type of pressure-recording instruments we want to look
%  for to get their actual depth as a function of time:

instr_presrecords = {'RBRConcerto', 'SBE37', 'RDIadcp'};


%% Check which of the instruments in instr_presrecords are
%  present in the mooring moorid:

instrP = intersect(instr_presrecords, fieldnames(moorsensors));

if isempty(instrP)
    warning(['Mooring ' FP.SN ' has no instruments of the types in ' ...
             'the variable instr_presrecords, those we want ' ...
             'to get pressure from. No knockdown correction applied.'])
         
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
    % if sum(ninstr)==1, I can't make knockdown correction
    % as it is done, I could however do something if, for 
    % example, the mooring consists of an ADCP hundred meter
    % from the bottom with thermistors below, though it is
    % likely the displacements are not big.
    % ----------------------------------------------------
    
    % ----------------------------------------------------
    % Print to the screen (let the user know) the instrument list
    % instrP (which instruments are being used for estimating knockdowns):
    % ----------------------------------------------------
    
    % Only do knockdown correction if there is at
    % least 2 pressure-recording instruments:
    if sum(ninstr)>1
        
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

        
        %% Plot the the pressure time series and take the MEDIAN for each
        %  instrument, which is overlayed on the plot. Since these MEDIANS
        %  are reference values used below it is nice to look at the plot
        %  and make sure these meadians are about the same as where we the
        %  instruments to be at. Median in computed instead of the mean
        %  because it is not as sensitive to values taken before/after
        %  the instrument was deployed/recovered:

        % Pre-allocate space for median pressure:
        medianpres = NaN(1, nrecords);

        % Plot pressure records:
        figure
            hold on, axis ij
            for i = 1:nrecords

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
        
        interpObj = interp1general(alltime, allpres);
        
          
%         %% Create a 2-minute (2*1 day / (24hr*60min)) interval date vector
%         %  from the latest early time to the earliest late time (picking the
%         %  overlapping period between all pressure-recording instruments):
% 
%         % WHY 2 MINUTES???
% 
%         mintimeoverlap = max(cellfun(@min, alltime));
%         maxtimeoverlap = min(cellfun(@max, alltime));
%         timestep = 2/(24*60);
% 
%         time_2min = mintimeoverlap : timestep : maxtimeoverlap ;
% 
% 
%         %% Interpolate pressure records to the uniform time grid created
%         % above. We sort the time and pressure records so we have matrices
%         % that have rows representing monotonically increasing depths
%         % (being monotonic used to be required for interp1 in old Matlab
%         % versions, but does not seem to be the case anymore):
% 
%         % Pre-allocate space for time-gridded pressures:
%         pres_interp = NaN(nrecords, length(time_2min));
% 
%         % Sort medianpres in increasing order (increasing instrument depth):
%         [medianpres_sorted, indsort] = sort(medianpres);
% 
%         % Now sort the time and pressure records:
%         alltime_sorted = alltime(indsort);
%         allpres_sorted = allpres(indsort);
% 
%         % NO PROBLEMS WITH NaNs?????
% 
%         for i = 1:nrecords
% 
%             pres_interp(i, :) = interp1(alltime_sorted{i}, ...
%                                         allpres_sorted{i}, time_2min);
% 
%         end
% 
% 
%         %% Create Perturbation Depth Series for point instruments:
% 
%         % Compute the z perturbations for the instruments we have pressure:
%         zperturb_measured = NaN(nrecords, length(time_2min));
% 
%         % For each record, compute the pressure/depth perturbation:
%         for i = 1:nrecords
% 
%             zperturb_measured(i, :) = pres_interp(i, :) - medianpres_sorted(i);
% 
%         end
% 
% 
%         %% Finally, we estimate pressure/depth perturbation for
%         %  all depths defined in the vector below:
% 
%         % HOW DO WE INTERPOLATE/EXTRAPOLATE  ???????????????????????
% 
%         % The depth levels for which we want to
%         % interpolate the depth perturbations on:
%         vec_interp_levels = 1:1:FP.depth;
% 
%         % Pre-allocate space for a mtrix containing the perturbations
%         % (THAT IS MUCH MORE THAN WE NEED!!!):
%         zgrid_perturb = NaN(length(vec_interp_levels), length(time_2min));
% 
%         % For each time, fill in the estimated depth/pressure perturbation profile:
%         for i = 1:length(time_2min)
% 
%             zgrid_perturb(:, i) = interp1(medianpres_sorted, ...
%                                           zperturb_measured(:, i), ...
%                                           vec_interp_levels, ...
%                                                               'linear','extrap');
% 
%         %     if i == round(length(time_2min)/2)
%         %         keyboard
%         %     end
%         end
% 
% 
%         %% Make a plot of zgrid_perturb:
% 
%         % THERE ARE TOO MANY DATA POINTS IN THIS PLOT (HEAVY PLOT)
%         % THERE ARE "PERTURBATIONS" ASSOCIATED WITH DEPLOYMENT/RECOVERY
%         % THE COLORBAR MUST BE SET SOMEHOW THOUGH....
%         % IT IS A GOOD PLOT TO TAKE A LOOK AT THOUGH.
% 
%         % % figure
%         % %     pcolor(time_2min, vec_interp_levels, zgrid_perturb)
%         % %     shading flat
%         % %     axis ij
%         % %     colorbar
        
        
        
        
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

function [output, num_bad] = deSpiking( input, threshold, showit)
%function out = deSpiking( input, threshold )
%   removes spikes in data input and return the cleaned
%   data output.
%   
%   It calculates the one-order dirative of input, dffone
%   detecting where dffone larger than theshold*std, where
%   std is nanstd( dffone )
%
%   INPUT:
%       input:     (m, n)/(m, 1) matrix
%       threhold:   default(=3)
%       showit:    show the process, default(=1)
%   
%   OUTPUT:
%       output:    (m, n)/(m, 1) matrix
%       num_bad:   n / 1 data, showing how many bad data are removed
%   
% ZZ@ APL-UW, 2010

num_bad = 0;


%% check size of input
[M, N] = size( input );
INPUT = input;
OUTPUT = INPUT;

for iN = 1 : N
    input = INPUT(:, iN);
    diffone = diff( input, 1);
    stdone  = nanstd( diffone );
    cutoff = threshold*stdone;
    id_bad  = find( abs(diffone) > cutoff );
    output = input;
    output( id_bad ) = nan;
    OUTPUT(:, iN) = output;
    num_bad = length( id_bad );

    %%
    if showit == 1
        figure(1), clf,
        subplot(2,1,1), hold on, box on, grid on
        plot( input, 'r', 'linewidth', 1.5 )
        plot( output, 'b', 'linewidth', 1.5 )

        subplot(2,1,2), hold on, grid on, box on
        set(gca, 'ticklength', [0 0])
        hist( diffone, round(length(diffone)/2), 'facecolor', 'b', 'edgecolor', 'b' )

        ylm = get(gca, 'ylim' );
        plot( [cutoff cutoff], ylm, 'r', 'linewidth', 1.5)
        plot( -[cutoff cutoff], ylm, 'r')
    end
end

output = OUTPUT;

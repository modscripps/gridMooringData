function out = filtfiltZZ(b, a, x)
%function out = filtfiltZZ(b, a, x)
% routine to do two-pass recursive filter using filtfilt.m.
%  
% Compared to it predecrssor myfiltfilt, this version 
% better deals with end effects using 'reflection method',
% rather than using 'constant-data padding'.
%
% see also filtfilt, myfiltfilt, filtfilthd
%
% Z. Zhao @ APL/UW September 23, 2011

%% check bandpass width
nb = length(b);
na = length(a);
nfilt = max(nb, na);
nfact = 3*(nfilt-1);

%% check length of x series
if length(x)<nfact
    x = nan(size(x));
end

%% put all x in a column
x = x(:);

%% case one: all x is NaN
if all(isnan(x))
    out = x;
end

%% case two: all x is NOT NaN
if all(~isnan(x))    
    out = filtfilthd(b, a, x);
end

%% case three: part of x is NaN 
good = ~isnan( x );
tmp = diff(good);
da = find( tmp == -1 ); %where data -> NaN
db = find( tmp == 1  ); db = db+1; %where NaN  -> data, so plus one
ID = [1; da(:); db(:); length(x)]; %put together and two ends
ID = sort(ID, 'ascend');           %sort in ascending order
% if the first is NaN, cut off 1
if isnan( x(1) )
    ID(1) = [];
end
% if the last is NaN, cut off (end)
if isnan( x(end) )
    ID(end) = [];
end

out = nan(size(x));
%% reshape into pairs: loop to run 'filtfilthd'
ID = reshape(ID, 2, length(ID)/2);
for k = 1 : size(ID, 2)
    x_sec = x( ID(1,k) : ID(2,k) ); %read out a piece of dataset
    y = filtfilthd(b, a, x_sec); 
    out(ID(1,k) : ID(2,k)) = y;  
end

%% plot a figure to compare x and out
if 6 == 5
    figure(4), clf, hold on, grid on, box on
    plot(x, 'r', 'linewidth', 1.5)
    plot(out, 'b', 'linewidth', 1.5)  
end
return
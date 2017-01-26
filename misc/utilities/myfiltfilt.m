function [x] = myfiltfilt(b,a,x)
%function myfiltfilt[b,a,x]
% routine to do two-pass recursive filter using filtfilt.m 
%  but with the data padded to have an extended head and tail of
%  constant data to try and minimize wobbles of the output at the ends
%
%   Jun. 03, 2006, modified by Zhongxiang Zhao
%   To check NaN's in input x
%   when NaNs in input dataset x, search for the index of good data 
%   and run 'filtfilt' by piece. 

%all x is NaN
if all(isnan(x)) 
    return
end

Num = 100;

%all x is in a column
x = x(:);
    
%all x is NOT NaN
if all( ~isnan(x) ) 
    L=length(x);
    z1=x(1)*ones(Num,1);
    z2=x(L)*ones(Num,1);
    y=[z1',x',z2'];
    z=filtfilt(b,a,y);
    x=z(Num+1:Num+L);
    return;
end

%part of x is NaN
good = ~isnan( x );
tmp = diff(good);
da = find( tmp == -1 ); %where data -> NaN
db = find( tmp == 1  ); db = db+1; %where NaN  -> data, so plus one
ID = [1; da(:); db(:); length(x)]; %put together and two ends
ID = sort(ID, 'ascend');           %sort in ascending order

%if the first is NaN, cut off 1
if isnan( x(1) )
    ID(1) = []; 
end

%if the last is NaN, cut off (end)
if isnan( x(end) )
    ID(end) = [];
end

%reshape into pairs
ID = reshape(ID, 2, length(ID)/2); 

%loop to run 'filtfilt'
for k = 1 : size(ID, 2)
    x_sec = x(ID(1,k):ID(2,k)); %read out a piece of dataset
    L=length(x_sec);            
    z1=x_sec(1)*ones(Num,1);
    z2=x_sec(L)*ones(Num,1);
    y=[z1',x_sec',z2'];
    z=filtfilt(b,a,y);          %as the old version 
    x(ID(1,k):ID(2,k)) = z(Num+1:Num+L);  %read back the filtered data piece
end

return
function s = fixstr( s )
%function s = fixstr( s )
%   check special characters in s and return back
%   now just check '_' 
% 
% ZZ @ APL-UW, April 1st, 2010

%% find '_' in string s
idx_ub = findstr(s, '_' );

%% find '\_', where '_' is already with '\'  
idx_gd = findstr(s, '\_' );
idx_gd = idx_gd + 1;

%% find index with lone '_'
idx_bd = setdiff(idx_ub, idx_gd);

%% sort from end to begin
idx_bd = sort( idx_bd, 'descend');

%% replace '_' using '\_'
for i = 1 : length(idx_bd)
    idx = idx_bd(i);
    s = [s(1:idx-1) '\_' s(idx+1:end)];
end

return
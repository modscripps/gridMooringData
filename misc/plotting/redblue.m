function [c] = redblue(m)
%
% redblue2  	Shades of red to white to blue colormap.
%		REDBLUE2(M) returns an M-by-3 matrix containing a
%		"redblue" colormap.
%	Actually, goes from dk.blue-blue-lt.blue-white-yellow-red-dk.red
%
%		See also HSV, COLORMAP, RGBPLOT.

if nargin<1
  [m,n] = size(colormap);
end;

m = floor(m);

if m<9
   disp('redblue2: must request 9 or more elements for colormap');
   c=NaN*ones(m,3);
   return
end

ix_ = [1 2 3 4];
if m>10
   ix_ = [1 max([floor(m*0.18) 2]) floor(m*0.36) floor(m/2+0.51)-1];
end
% colormap will be symmetric
odd_ = rem(m,2);

if odd_ > 0 % odd number of elements
   % middle is white, with lt.lt.blue/yellow before/after
   coldef_ = ...
      [0.0  0.0  0.5;
      0.0  0.0  1.0;
      0.0  1.0  1.0;
      0.75  1.0  1.0;
      1.0  1.0  1.0;
      1.0  1.0  0.75;
      1.0  1.0  0.0;
      1.0  0.0  0.0;
      0.5  0.0  0.0];
   indef_ = [ix_  ix_(4)+1  m+1-fliplr(ix_)];
else  % even number of elements
   % white on either side of middle
   coldef_ = ...
      [0.0  0.0  0.6;
      0.0  0.0  1.0;
      0.0  1.0  1.0;
      0.75  1.0  1.0;
      1.0  1.0  1.0;
      1.0  1.0  1.0;
      1.0  1.0  0.75;
      1.0  1.0  0.0;
      1.0  0.0  0.0;
      0.6  0.0  0.0];
   indef_ = [ix_  ix_(4)+1  ix_(4)+2  m+1-fliplr(ix_)];
end

c = interp1(indef_, coldef_, [1:m]);

function mdate = jday2matlab(jday,year)
%convert julian day to Matlab date format
%
% syntax: mdate = jday2matlab(jday,year);
%
% jday is one-based: midnight, Jan. 1 is 1.0, not 0 as might logically
% be expected
% year is optional, assumed to be the current year (watch out for leap
% years though!)
%
%
 
if nargin<2
  c = clock;
  year = c(1);
end
 
%Since jday is 1-based, zero is midnight, Dec 31st of the year before
mdate = datenum(year-1, 12, 31, 0, 0, 0) + jday;
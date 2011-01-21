function udate = datenum2unix(d)
    udate = (d - datenum(1970,1,1)) * 86400;
end
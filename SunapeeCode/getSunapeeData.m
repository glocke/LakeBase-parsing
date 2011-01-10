function [ sunapee ] = getSunapeeData( inputdirectory )
%GETSUNAPEEDATA Parses data from Cayelan (Lake Sunapee)
%   From data to Lake object

sunapee = Lake;
sunapee.name = 'Lake Sunapee';
sunapee.lat = 43.3767;
sunapee.lon = -72.0534;

[~,~,cardata] = xlsread([inputdirectory '\SunapeeCarbonForPaul.xlsx']);
yrIdx = 1;
siteIdx = 2;
dicIdx = 3;
docIdx = 4;
npocIdx = 5;
jdayIdx = 6;

for i=2:size(cardata,1)
    row = cardata(i,:);
    unixTime = datenum2unix(jday2matlab(row{jdayIdx},row{yrIdx}));
    sunapee.addValueWithSS(row{siteIdx},unixTime,row{dicIdx},0,'Dissolved Inorganic Carbon');
    sunapee.addValueWithSS(row{siteIdx},unixTime,row{docIdx},0,'Dissolved Organic Carbon');
    sunapee.addValueWithSS(row{siteIdx},unixTime,row{npocIdx},0,'Nonpurgable Organic Carbon');
end

[~,~,prodata] = xlsread([inputdirectory '\HastingsDeep.xlsx']);
for c=2:size(prodata,2)
    unixTime = datenum2unix(prodata{1,c});
    if (strcmp(prodata{2,c},'temp'))
        variableName = 'Water Temperature';
    else
        variableName = 'Dissolved Oxygen';
    end
    for r=3:size(prodata,1)
        if ~isnan(prodata{r,c})  
            sunapee.addValueWithSS('Hastings Deep',unixTime,prodata{r,c},prodata{r,1},variableName);
        end
    end
end

[~,~,prodata] = xlsread([inputdirectory '\HerrickOpening.xlsx']);
for c=2:size(prodata,2)
    unixTime = datenum2unix(prodata{1,c});
    if (strcmp(prodata{2,c},'temp'))
        variableName = 'Water Temperature';
    else
        variableName = 'Dissolved Oxygen';
    end
    for r=3:size(prodata,1)
        if ~isnan(prodata{r,c})  
            sunapee.addValueWithSS('Herrick Opening',unixTime,prodata{r,c},prodata{r,1},variableName);
        end
    end
end

[~,~,prodata] = xlsread([inputdirectory '\NSunapeeHarbor']);
for c=2:size(prodata,2)
    unixTime = datenum2unix(prodata{1,c});
    if (strcmp(prodata{2,c},'temp'))
        variableName = 'Water Temperature';
    else
        variableName = 'Dissolved Oxygen';
    end
    for r=3:size(prodata,1)
        if ~isnan(prodata{r,c})  
            sunapee.addValueWithSS('North Sunapee Harbor',unixTime,prodata{r,c},prodata{r,1},variableName);
        end
    end
end

[~,~,secdata] = xlsread([inputdirectory '\SunapeeSecchi.xlsx']);
siteIdx = 1;
dateIdx = 2;
secIdx = 3;

for i=2:size(secdata,1)
    secrow = secdata(i,:);
    unixTime = datenum2unix(secrow{dateIdx}); 
    sunapee.addValueWithSS(secrow{siteIdx},unixTime,secrow{secIdx},0,'Secchi Depth');
end

% [~,~,data] = xlsread([inputdirectory '\DeepSitesWoody2005']);
% stationIdx = 1;
% dateIdx = 2;
% layerIdx = 3; % right now used as depth...
% phIdx = 4;
% alkIdx = 5;
% tpIdx = 7;
% condIdx = 8;
% turbIdx = 9;
% chlIdx = 10;
% sdIdx = 11;
% 
% for i=2:size(data,1)
%     row = data(i,:);
%     switch row{layerIdx}
%         case 'E'
%             depth = 'Something...';
%         case 'H'
%             depth = 'Something else...';
%         case 'M'
%             depth = 'And something else...'; % TODO: Then replace below references to row{layerIdx} with depth
%     end
%     unixTime = datenum2unix(row{dateIdx}); 
%     sunapee.addValueWithSS(row{stationIdx},unixTime,row{phIdx},row{layerIdx},'pH');
%     sunapee.addValueWithSS(row{stationIdx},unixTime,row{tpIdx},row{layerIdx},'Total Phosphorus');
%     sunapee.addValueWithSS(row{stationIdx},unixTime,row{condIdx},row{layerIdx},'Conductivity');
%     sunapee.addValueWithSS(row{stationIdx},unixTime,row{turbIdx},row{layerIdx},'Turbidity');
%     if ~isnan(row{alkIdx})
%         sunapee.addValueWithSS(row{stationIdx},unixTime,row{alkIdx},row{layerIdx},'Alkalinity');
%     end
%     if ~isnan(row{chlIdx})
%         sunapee.addValueWithSS(row{stationIdx},unixTime,row{chlIdx},row{layerIdx},'Chlorophyll'); 
%     end
%     if ~isnan(row{sdIdx})
%         sunapee.addValueWithSS(row{stationIdx},unixTime,row{sdIdx},row{layerIdx},'Secchi Depth'); 
%     end
% end

[~,~,tndata] = xlsread([inputdirectory '\Sunapee_TN_ForPaul_31Oct10.xlsx']);
siteIdx = 1;
yrIdx = 2;
jdayIdx = 3;
tnIdx = 4; % assuming this is total nitrogen (in ug/L)

for i=2:size(tndata,1)
   tnrow = tndata(i,:);
   unixTime = datenum2unix(jday2matlab(tnrow{jdayIdx},tnrow{yrIdx}));
   sunapee.addValueWithSS(tnrow{siteIdx},unixTime,tnrow{tnIdx} / 1000,0,'Total Nitrogen');
end

end


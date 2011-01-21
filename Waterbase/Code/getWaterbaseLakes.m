function [ finalLakes ] = getWaterbaseLakes( inputLocation )
% inputLocation should be parent dir, so in this case:
% D:\Users\glocke-ou\Documents\Waterbase\Data
tic

finalLakes = Lake;

qlakes = Lake;
[~, ~, data] = xlsread([inputLocation '\lakes_v10_quality.xls']);
qlidx = 1;
for i=2:size(data,1)
    qlakes(qlidx) = Lake; %create a new object
	parseqRow(data(i,:),qlakes(qlidx)); %object is modified in place
	qlidx = qlidx + 1;
end
qlakes = cleanUnits(qlakes);
qlakes = aggregateData(qlakes);
finalLakes = joinAttributes(finalLakes,qlakes);

stlakes = Lake;
[~, ~, data] = xlsread([inputLocation '\lakes_v10_stations.xls']);
stlidx = 1;
for i=2:size(data,1)
    stlakes(stlidx) = Lake; %create a new object
	parsestRow(data(i,:),stlakes(stlidx)); %object is modified in place
	stlidx = stlidx + 1;
end
finalLakes = joinAttributes(finalLakes,stlakes);

function newLakes = aggregateData(lakes) 
    % Initialize lakes arr to includes all lakes, and double the variables
    % (to include update counts) Also includes headers on top and side
    lakesArr = zeros(26,length(lakes)+1);
    % Put variable header column on side
    varHeader = {'Chlorophyll a';'0';'Conductivity';'0';'Dissolved Oxygen';'0';'Nitrate';'0';'Nitrite';'0';'Secchi Depth';'0';'Silicate';'0'; ... 
        'Temperature';'0';'Total Ammonium';'0';'Total Inorganic Nitrogen';'0';'Total Nitrogen';'0';'Total Organic Carbon';'0';'Total Phosphorus';'0'};
    % Put lake header row on top
    lakeHeader = {};
    currLakeIndex = 1;
    flag = 0;
    % Scan the length of the original array one by one to aggregate
    for currOrigLake=1:length(lakes)
       names = lakes(currOrigLake).getAttributeNames();
       % Fill in the new aggregated lakesArr
       for currNewLake=currLakeIndex:size(lakeHeader)
          % If lake already exists in lakesArr, begin aggregating
          if strcmp(lakeHeader{currNewLake}, lakes(currOrigLake).getAttribute('WaterbaseID'))
              % For the lake that exists in lakesArr, check if each variable
              % also already exists
              for currLakesVar=1:size(names)
                  for currLakesArrVar=1:2:size(varHeader,1)
                      % When variable is found, update the value of it, and also
                      % the count of number of updates for later mean
                      % computation  
                      if strcmp(names{currLakesVar},varHeader{currLakesArrVar,1})
                            lakesArr(currLakesArrVar,currNewLake) = lakesArr(currLakesArrVar,currNewLake) + lakes(currOrigLake).getAttribute(names{currLakesVar});
                            lakesArr(currLakesArrVar+1,currNewLake) = lakesArr(currLakesArrVar+1,currNewLake) + 1;
                      end
                  end
              end
              flag = 1;
              break;
          end          
       end
       % If lake didn't already exist in lakesArr, add it
       if ~flag
            lakeHeader{currLakeIndex} = lakes(currOrigLake).getAttribute('WaterbaseID');
            currLakeIndex = currLakeIndex + 1;
       end
       flag = 0;
    end
    % Calculate averages using update counts
    for iter=1:2:size(lakesArr,1)
       lakesArr(iter,:) = lakesArr(iter,:) ./ lakesArr(iter+1,:);
    end
    % Clean up lakesArr by throwing out values with an update count
    % of 0
    newLakes = Lake;
    % Traverse lakesArr by column (so by lake), then by row (by attribute)
    % filling in a new lakes arry, newLakes
    for lakeIdx=1:size(lakesArr,2)
        newLakes(lakeIdx) = Lake; % Initialize
        newLakes(lakeIdx).putAttribute('WaterbaseID',lakeHeader{lakeIdx});
        % Remember to skip update count
        for attIdx=1:2:size(lakesArr,1)
            % Skip variables that have a count of zero...
            if lakesArr(attIdx+1,lakeIdx) > 0
                newLakes(lakeIdx).putAttribute(varHeader{attIdx},lakesArr(attIdx,lakeIdx));
            end
        end
    end
end
    
function lakes = cleanUnits(lakes)
    for i2=1:length(lakes)
        if ~strcmp(lakes(i2).getAttribute('Unit_Chlorophyll a'),'ug/l')
           lakes(i2) = []; 
        else
            val = lakes(i2).getAttribute('Chlorophyll a');
            % TODO not sure if val is a string or not
            val = str2double(val);
            val = val/1000; % Convert to mg/l
            lakes(i2).putAttribute('Chlorophyll a',val);
        end
        if ~strcmp(lakes(i2).getAttribute('Unit_Conductivity'),'uS/cm')
           lakes(i2) = []; 
        end
        if ~strcmp(lakes(i2).getAttribute('Unit_Dissolved Oxygen'),'mg/l O2')
           lakes(i2) = []; 
        end
        if ~strcmp(lakes(i2).getAttribute('Unit_Nitrate'),'mg/l N')
           lakes(i2) = []; 
        end
        if ~strcmp(lakes(i2).getAttribute('Unit_Nitrite'),'mg/l N')
           lakes(i2) = []; 
        end
        if ~strcmp(lakes(i2).getAttribute('Unit_Secchi Depth'),'m')
           lakes(i2) = []; 
        end
        if ~strcmp(lakes(i2).getAttribute('Unit_Silicate'),'mg/l Si')
           lakes(i2) = []; 
        end
        if ~strcmp(lakes(i2).getAttribute('Unit_Temperature'),'°C')
           lakes(i2) = []; 
        end
        if ~strcmp(lakes(i2).getAttribute('Unit_Total Ammonium'),'mg/l N')
           lakes(i2) = []; 
        end
        if ~strcmp(lakes(i2).getAttribute('Unit_Total Inorganic Nitrogen'),'mg/l N')
           lakes(i2) = []; 
        end
        if ~strcmp(lakes(i2).getAttribute('Unit_Total Nitrogen'),'mg/l N')
           lakes(i2) = []; 
        end
        if ~strcmp(lakes(i2).getAttribute('Unit_Total Organic Carbon'),'mg/l C')
           lakes(i2) = []; 
        end
        if ~strcmp(lakes(i2).getAttribute('Unit_Total Phosphorus'),'mg/l P')
           lakes(i2) = []; 
        end
    end
end

function s = parseqRow(row,s)
   wbidIdx = 2;
   determinandIdx = 8;
   unitIdx = 9; % TODO: Units are different within determinands...
   meanValIdx = 15;
   
   s.putAttribute('WaterbaseID',row{wbidIdx});
   if ~strcmp(row{determinandIdx},'') && ~strcmp(row{meanValIdx},'')
       s.putAttribute(row{determinandIdx},row{meanValIdx});
       s.putAttribute(['Unit_' row{determinandIdx}],row{unitIdx});
   end
end
    
function s = parsestRow(row,s)
   wbidIdx = 2;
   nameIdx = 7;
   lonIdx = 16;
   latIdx = 17;
   % alkalinityAvgIdx = 27; % meq/l TODO:
   areaIdx = 33; % km^2
   meanDepthIdx = 34; % m
   maxDepthIdx = 35; % m
   
   s.name = row{nameIdx};
   s.lon = row{lonIdx};
   s.lat = row{latIdx};
   
   s.putAttribute('WaterbaseID',row{wbidIdx});
   if ~isnan(row{areaIdx})
       s.putAttribute('area',row{areaIdx});
   end
   if ~isnan(row{meanDepthIdx})
       s.putAttribute('mean depth',row{meanDepthIdx});
   end
   if ~isnan(row{maxDepthIdx})
       s.putAttribute('max depth',row{maxDepthIdx});
   end
end
end


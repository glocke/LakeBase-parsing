function finalLakes = getCentralPlainsLakes(inputLocation)
% inputLocation should be parent dir, so in this case:
% D:\Users\glocke-ou\Documents\CentralPlains\Data
tic

finalLakes = Lake;

cplakes = Lake;
[~, ~, data] = xlsread([inputLocation '\lakesRTAG.xls']);
cplidx = 1;
for i=2:size(data,1)
    cplakes(cplidx) = Lake; %create a new object
	parsecpRow(data(i,:),cplakes(cplidx)); %object is modified in place
	cplidx = cplidx + 1;
end
finalLakes = joinAttributes(finalLakes,cplakes);
finalLakes = joinValues(finalLakes,cplakes);

tmdlakes = Lake;
[~, ~, data] = xlsread([inputLocation '\TMDLlakes.xls']);
tmdlidx = 1;
for i=2:size(data,1)
    tmdlakes(tmdlidx) = Lake; %create a new object
	parsetmdRow(data(i,:),tmdlakes(tmdlidx)); %object is modified in place
	tmdlidx = tmdlidx + 1;
end
finalLakes = joinAttributes(finalLakes,tmdlakes);
finalLakes = joinValues(finalLakes,tmdlakes);

function s = parsetmdRow(row,s)
   stateIdx = 2;
   nameIdx = 4;
   dateIdx = 5;
   timeIdx = 9;
   sampleDepthIdx = 13; %m
   waterTempIdx = 14; % C
   pHIdx = 15; % pH
   condIdx = 16; % mS/cm
   doIdx = 17; % mg/l
   turbIdx = 18; % NTU
   nitrateNitriteIdx = 27; % ppm (mg/l)
   nitriteIdx = 28; % ppm (mg/l)
   chloraIdx = 30; % ppb
   totNIdx = 32; % ppb
   totPIdx = 34; % ppb
   orgPIdx = 36; % ppb
   clIdx = 38; % ppm
   so4Idx = 39; % ppm
   
   s.state = row{stateIdx};
   s.name = row{nameIdx};
   if isnan(timeIdx)
       sampleTime = [row{dateIdx} ' 00:00:00'];
   else
       sampleTime = [row{dateIdx} row{timeIdx} ':00']; 
   end
   uTime = datenum2unix(datenum(sampleTime));
        
   if ~isnan(row{waterTempIdx})
       s.addValue(uTime,row{waterTempIdx},row{sampleDepthIdx},'Water Temperature');
   end
   if ~isnan(row{pHIdx})
       s.addValue(uTime,row{pHIdx},row{sampleDepthIdx},'pH');
   end
   if ~isnan(row{condIdx})
       s.addValue(uTime,row{condIdx}*1000,row{sampleDepthIdx},'Conductivity'); % Convert from mS/cm to uS/cm
   end
   if ~isnan(row{doIdx})
       s.addValue(uTime,row{doIdx},row{sampleDepthIdx},'Dissolved Oxygen Concentration');
   end
   if ~isnan(row{turbIdx})
       s.addValue(uTime,row{turbIdx},row{sampleDepthIdx},'Turbidity');
   end
   if ~isnan(row{nitrateNitriteIdx})
       s.addValue(uTime,row{nitrateNitriteIdx},row{sampleDepthIdx},'Nitrate nitrite NO3 NO2');
   end
   if ~isnan(row{nitriteIdx})
       s.addValue(uTime,row{nitriteIdx},row{sampleDepthIdx},'Nitrite NO2');
   end
   if ~isnan(row{chloraIdx})
       s.addValue(uTime,row{chloraIdx}/1000,row{sampleDepthIdx},'Chlorophyll-a'); % Convert from ppb to ppm (ug/l to mg/l)
   end
   if ~isnan(row{totNIdx})
       s.addValue(uTime,row{totNIdx}/1000,row{sampleDepthIdx},'Total Nitrogen N'); % Convert from ppb to ppm (ug/l to mg/l)
   end
   if ~isnan(row{totPIdx})
       s.addValue(uTime,row{totPIdx}/1000,row{sampleDepthIdx},'Total Phosphorus P'); % Convert from ppb to ppm (ug/l to mg/l)
   end
   if ~isnan(row{orgPIdx})
       s.addValue(uTime,row{orgPIdx}/1000,row{sampleDepthIdx},'Total Organic Phosphorus'); % Convert from ppb to ppm (ug/l to mg/l)
   end
   if ~isnan(row{clIdx})
       s.addValue(uTime,row{clIdx},row{sampleDepthIdx},'Chloride Cl');
   end
   if ~isnan(row{so4Idx})
       s.addValue(uTime,row{so4Idx},row{sampleDepthIdx},'Sulfate SO4');
   end
end

function s = parsecpRow(row,s)
   stateIdx = 1;
   nameIdx = 2;
   latIdx = 7;
   lonIdx = 8;
   areaIdx = 15; % acres
   meanDepthIdx = 17; % m
   secchiIdx = 21; % m
   
   if ~strcmp(row{latIdx},'') || ~strcmp(row{lonIdx},'')
        s.state = row{stateIdx};
        s.name = row{nameIdx};
        s.lat = row{latIdx};
        s.lon = row{lonIdx};
    
        if ~isnan(row{areaIdx})
            lakearea = str2double(row{areaIdx});
            lakearea = lakearea*4046.85642; % Convert acres to m^2
            s.putAttribute('Surface Area',lakearea); 
        end
        if ~isnan(row{meanDepthIdx})
            s.putAttribute('Depth',row{meanDepthIdx});
        end
        if ~isnan(row{secchiIdx})
            s.putAttribute('Secchi Depth',row{secchiIdx});
        end
   end
end
end

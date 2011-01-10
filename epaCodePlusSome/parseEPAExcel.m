function plakes = parseEPAExcel(inputLocation,index)
% inputLocation should be particular data dir, eg: "D:\Users\glocke-ou\Documents\EPAData\Lake Phytoplankton Count Data"
tic
%% Some important constants
s = Lake;
offset = 3; % the offset of the file directory
plidx = 1;
plakes = Lake;
%plakes(10000) = Lake; %pre-allocate for speed, *don't* include "1:"
path(path, inputLocation);

switch index
	case 1 + offset
		[~, ~, data] = xlsread('LakeInformation_sampled_20091113.xlsx');
		for i=2:size(data,1)
% 			plakes(plidx) = Lake; %create a new object
% 			parseILSRow(data(i,:),plakes(plidx)); %object is modified in place
% 			plidx = plidx + 1;
%             
            tempLake = Lake; %create a new object
			s=parseILSRow(data(i,:),tempLake); %object is modified in place
            plakes(plidx) = s;
            plidx = plidx + 1;
		end
	case 2 + offset
		[~, ~, data] = xlsread('Lake_Basin_Landuse_Metrics_20061022.xlsx');
		for i=2:size(data,1)
			plakes(plidx) = Lake; %create a new object
			parsebasinRow(data(i,:),plakes(plidx)); %object is modified in place
			plidx = plidx + 1;
		end
	case 3 + offset
		[~, ~, data] = xlsread('Lake_Buffer_Landuse_Metrics_20091022.xlsx');
		for i=2:size(data,1)
			plakes(plidx) = Lake; %create a new object
			parsebufferRow(data(i,:),plakes(plidx)); %object is modified in place
			plidx = plidx + 1;
		end
% 	case 4 + offset
% 		[~, ~, data] = xlsread('Lakes_Chemical_Condition_Estimates_20091123.xlsx');
% 		for i=2:size(data,1)
% 			plakes(plidx) = Lake; %create a new object
% 			parsechemRow(data(i,:),plakes(plidx)); %object is modified in place
% 			plidx = plidx + 1;
% 		end	
%     case 11 + offset
% 		[~, ~, data] = xlsread('nla_epi_do2_valid_20091007.xlsx');
% 		for i=2:size(data,1)
% 			plakes(plidx) = Lake; %create a new object
% 			parsedo2Row(data(i,:),plakes(plidx)); %object is modified in place
% 			plidx = plidx + 1;
% 		end	
	case 20 + offset
		[~, ~, data] = xlsread('LakeProfile_valid_20091008.xlsx');
		for i=2:size(data,1)
			plakes(plidx) = Lake; %create a new object
			parseprofileRow(data(i,:),plakes(plidx)); %object is modified in place
			plidx = plidx + 1;
		end	
	case 22 + offset
		[~, ~, data] = xlsread('nla_secchi_valid_20091008.xlsx');
        for i=2:size(data,1)
			plakes(plidx) = Lake; %create a new object
			parsemeansecchiRow(data(i,:),plakes(plidx)); %object is modified in place
			plidx = plidx + 1;
        end
	case 27 + offset
		[~, ~, data] = xlsread('Lake_watqual_20091123.xlsx');
        for i=2:size(data,1)
			plakes(plidx) = Lake; %create a new object
			parsewatqualRow(data(i,:),plakes(plidx)); %object is modified in place
			plidx = plidx + 1;
        end
    otherwise
        disp(['Nothing at ' inputLocation]);
end
end
%% Row Parse Functions (many, with the way EPA data was set up, no other way)
% Also, below isn't complete yet...
function s = parsewatqualRow(row,s)
	EPAIdx = 1;
    dateIdx = 7;
	depthIdx = 14;
    condIdx = 19; % (uS/cm @ 25 C)
    ancIdx = 22; % (ueq/L)
    turbIdx = 24; % (NTU)
    tocIdx = 27; % (mg/L)
    docIdx = 30; % (mg/L)
    ammIdx = 33;
    ntlIdx = 40; % (mg/L)
    ptlIdx = 44; % (ug/L)
    clIdx = 47; % (mg/L)
    no3Idx = 51; % (mg/L)
    sulIdx = 55;
    calIdx = 59;
    magIdx = 63;
    sodIdx = 67;
    potIdx = 71;
    silIdx = 78;
	
	s.putAttribute('EPA id',row{EPAIdx});
    if ~isnan(row{depthIdx})
        if ~isnan(row{condIdx})
            s.addValue(datenum2unix(datenum(row(dateIdx))), row{condIdx} / 1000, row{depthIdx}, 'Conductivity');
        end
        if ~isnan(row{ancIdx})
            s.addValue(datenum2unix(datenum(row(dateIdx))), row{ancIdx} / 1000, row{depthIdx}, 'Alkalinity');
        end
        if ~isnan(row{turbIdx})
            s.addValue(datenum2unix(datenum(row(dateIdx))), row{turbIdx}, row{depthIdx}, 'Turbidity');
        end
        if ~isnan(row{tocIdx})
            s.addValue(datenum2unix(datenum(row(dateIdx))), row{tocIdx}, row{depthIdx}, 'Total Organic Carbon');
        end
        if ~isnan(row{docIdx})
            s.addValue(datenum2unix(datenum(row(dateIdx))), row{docIdx}, row{depthIdx}, 'Dissolved Organic Carbon');
        end
        if ~isnan(row{ntlIdx})
            s.addValue(datenum2unix(datenum(row(dateIdx))), row{ntlIdx}, row{depthIdx}, 'Total Nitrogen');
        end   
        if ~isnan(row{ptlIdx})
            s.addValue(datenum2unix(datenum(row(dateIdx))), row{ptlIdx} / 1000, row{depthIdx}, 'Total Phosphorus');
        end  
        if ~isnan(row{clIdx})
            s.addValue(datenum2unix(datenum(row(dateIdx))), row{clIdx}, row{depthIdx}, 'Chloride');
        end  
        if ~isnan(row{no3Idx})
            s.addValue(datenum2unix(datenum(row(dateIdx))), row{no3Idx}, row{depthIdx}, 'Nitrate');
        end 
        if ~isnan(row{ammIdx})
            s.addValue(datenum2unix(datenum(row(dateIdx))), row{ammIdx}, row{depthIdx}, 'Ammonium');
        end
        if ~isnan(row{sulIdx})
            s.addValue(datenum2unix(datenum(row(dateIdx))), row{sulIdx}, row{depthIdx}, 'Sulfate');
        end 
        if ~isnan(row{calIdx})
            s.addValue(datenum2unix(datenum(row(dateIdx))), row{calIdx}, row{depthIdx}, 'Calcium');
        end 
        if ~isnan(row{magIdx})
            s.addValue(datenum2unix(datenum(row(dateIdx))), row{magIdx}, row{depthIdx}, 'Magnesium');
        end 
        if ~isnan(row{sodIdx})
            s.addValue(datenum2unix(datenum(row(dateIdx))), row{sodIdx}, row{depthIdx}, 'Sodium');
        end 
        if ~isnan(row{potIdx})
            s.addValue(datenum2unix(datenum(row(dateIdx))), row{potIdx}, row{depthIdx}, 'Potassium');
        end 
        if ~isnan(row{silIdx})
            s.addValue(datenum2unix(datenum(row(dateIdx))), row{silIdx}, row{depthIdx}, 'Silica');
        end 
    end
end

function s = parsemeansecchiRow(row,s)
	EPAIdx = 1;
	secmeanIdx = 6;
	
	s.putAttribute('EPA id',row{EPAIdx});
	s.putAttribute('mean secchi',row{secmeanIdx});
end

function s = parseprofileRow(row,s)
	EPAIdx = 1;
    dateIdx = 4;
    depthIdx = 6;
	tempIdx = 8; % temp in oC
    do2Idx = 3; % Field Dissolved Oxygen (mg/L)
	phIdx = 10;
    
    s.putAttribute('EPA id',row{EPAIdx});
    if ~isnan(row{depthIdx})
        if ~isnan(row{tempIdx})
            s.addValue(datenum2unix(datenum(row(dateIdx))), row{tempIdx}, row{depthIdx}, 'Water Temperature');
        end
        if ~isnan(row{phIdx})
            s.addValue(datenum2unix(datenum(row(dateIdx))), row{phIdx}, row{depthIdx}, 'pH');
        end
        if ~isnan(row{do2Idx})
            s.addValue(datenum2unix(datenum(row(dateIdx))), row{do2Idx}, row{depthIdx}, 'Dissolved Oxygen Concentration');
        end
    end
end

% function s = parsedo2Row(row,s)
% 	EPAIdx = 1;
% 	do2Idx = 3; % MEAN DO2 CONC (mg/L) IN UPPER 2m (or UPPER 50% IF DEPTH < 4m)
% 	
% 	s.putAttribute('EPA id',row{EPAIdx});
% 	s.putAttribute('mean dissolved oxygen',row{do2Idx});
% end
% 
% function s = parsechemRow(row,s)
% 	EPAIdx = 1;
% 	phosIdx = 37; % Total Phosphorus (ug/L)
% 	nitIdx = 38; % Total Nitrogen (ug/L)
% 	turbIdx = 39; % Turbidity (NTU)
% 	ancIdx = 40; % Gran ANC (ueq/L)
% 	docIdx = 41; % Dissolved Organic Carbon (mg/L)
% 	condIdx = 42; % Conductivity (uS/cm @ 25C)
% 	chlaIdx = 45; % Chlorophyll a concentration (µg/L)
% 	
% 	s.putAttribute('EPA id',row{EPAIdx});
% 	s.putAttribute('sampled total phosphorus',row{phosIdx} / 1000); % all below data is in mg/something
% 	s.putAttribute('sampled total nitrogen',row{nitIdx} / 1000);
% 	s.putAttribute('sampled turbidity',row{turbIdx});
% 	s.putAttribute('sampled ANC',row{ancIdx} / 1000);
% 	s.putAttribute('sampled dissolved organic carbon',row{docIdx}); % IMPORTANT check with Luke to see if this is mean...
% 	s.putAttribute('sampled conductivity',row{condIdx} / 1000);
% 	s.putAttribute('sampled chlorophyll',row{chlaIdx} / 1000); % IMPORTANT check with Luke to see if this is mean...
% end

function s = parsebufferRow(row,s)
	EPAIdx = 1;
	bufferareakm2Idx = 6;
	
	s.putAttribute('EPA id',row{EPAIdx});
	s.putAttribute('buffer area',row{bufferareakm2Idx} * (1000^2)); % Convert to m^2
end

function s = parsebasinRow(row,s)
	EPAIdx = 1;
	basinareakm2Idx = 5;
	
	s.putAttribute('EPA id',row{EPAIdx});
	s.putAttribute('basin area',row{basinareakm2Idx} * (1000^2)); % Convert to m^2
end

function s = parseILSRow(row,s)

    EPAIdx = 1;
    dateIdx = 4;
    nameIdx = 22;
    latIdx = 10;
    lonIdx = 9;
	stateIdx = 18;
	countyIdx = 19;
	originIdx = 41; % natural, man-made, etc
	areakm2Idx = 49; % area in km^2
	perimIdx = 50; % lake perimeter
	maxdepIdx = 53; % max lake depth in m
	elevIdx = 54; % in m, from national elevation
    permIdx = 63; % YES if lake is a permanent waterbody
	disposalIdx = 69; % YES if used for disposal (tailings, mine-tailings, etc)
	sewageIdx = 70; % YES if sewage treatment pond
	accessIdx = 72; % YES if accessible for crew and boats
    
    s.name = row{nameIdx};
    s.lat = row{latIdx};
    s.lon = row{lonIdx};
    s.putAttribute('sample date',datenum(row(dateIdx)));
    s.putAttribute('EPA id',row{EPAIdx});
    s.putAttribute('state',row{stateIdx});
    s.putAttribute('county',row{countyIdx});
	s.putAttribute('origin',row{originIdx});
	s.putAttribute('area',row{areakm2Idx} * (1000^2)); % Convert to m^2
	s.putAttribute('perimeter',row{perimIdx});
	s.putAttribute('max observed depth',row{maxdepIdx});
	s.putAttribute('elevation',row{elevIdx});
	s.putAttribute('sewage lake',row{sewageIdx}); % if not, it will be 'NO' or NULL
	s.putAttribute('public accessable',row{accessIdx}); % if not, it will be 'NO' or NULL
end
function finalLakes = getEPALakes(inputLocation)
% inputLocation should be parent dir, so in this case: D:\Users\glocke-ou\Documents\EPAData
tic

finalLakes = Lake;

EPAdatatypes = dir(inputLocation);
for i=3:size(EPAdatatypes,1)
	newPath = [inputLocation '\' EPAdatatypes(i).name];
	lakes = parseEPAExcel(newPath,i);
	finalLakes = joinAttributes(finalLakes,lakes);
    finalLakes = joinValues(finalLakes,lakes);
end
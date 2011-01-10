function finals = joinAttributes(finals,lakes)
flag = 0;
for i=1:size(lakes,2)	
    for j=1:size(finals,2)
        if strcmp(lakes(i).getAttribute('EPA id'), finals(j).getAttribute('EPA id'))
			finals(j).mergeAttributes(lakes(i));
			flag = 1;
            break;
        end
    end
    if flag == 0
        finals = [finals lakes(i)];
    end
    flag = 0;
end
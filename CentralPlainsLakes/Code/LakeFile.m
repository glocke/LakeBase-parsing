classdef LakeFile
    %LAKEFILE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fid;
        name;
        path;
        type;
        source;
    end
    
    methods(Static)
        function tid = getType(typeName)
            if(strcmpi(typeName,'outline shapefile')==0)
                tid = 1;
            else
                error(['unknown file type!:' typeName]);
            end
        end
    end
    
end


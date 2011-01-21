classdef Lake < handle
    %LAKE An object representing a lake and its metadata
    %   Detailed explanation goes here
    
    properties
        %these will always exist
        id;
        name;
        lat;
        lon;
        attributes;
        files = LakeFile;
        data; %id,substreamid,unixtime,value,depth,varname
        state = LakeState.unknown;
    end
    
    methods
        function obj = Lake()
            obj.attributes = java.util.Hashtable;
            obj.state = LakeState.unknown;
            obj.files = [];
        end
        
        function names = getAttributeNames(obj)
            names = cell(obj.attributes.size(),1);
            enum = obj.attributes.keys();
            indx = 1;
            while(enum.hasMoreElements())
                names{indx} = enum.nextElement();
                indx = indx + 1;
            end
        end
        
        function prop = getAttribute(obj,propName)
            if(isempty(propName))
                prop = [];
            else
                prop = obj.attributes.get(lower(propName));
            end
        end        
        
        function putAttribute(obj,key,val)
            if(isempty(key))
                error('key cannot be empty!');
            else
                obj.attributes.put(lower(key),val);
            end
        end
		
        
		function mergeAttributes(obj, toMerge)
            %MERGEATTRIBUTES This method overwrites any attributes on this 
            %object with the attributes of the passed Lake object.
            %Non-conflicting attributes will be kept
            %
            % Lake1
            %   attr1:"USA"
            %   attr2:2000
            %   attr3:"Wisconsin"
            %
            % Lake2
            %   attr1:"Germany"
            %   attr2:1000
            %Using this syntax
            % Lake1.mergeAttributes(Lake2)
            % 
            % Results in these attributes
            %   attr1:"Germany"
            %   attr2:1000
            %   attr3:"Wisconsin"
            
			obj.attributes.putAll(toMerge.attributes);
        end
        
        function mergeValues(obj, toMerge)
            %MERGEVALUES is similar to above, but has no overwrite
            j = length(obj.data)+1;
            for i=1:length(toMerge.data)
                obj.data{j} = toMerge.data(i);
                j = j + 1;
            end
        end
        
        function addFile(obj,fileObj)
            for i=1:length(obj.files)
                if(obj.files(i).type == fileObj.type)
                    obj.files(i) = fileObj;
                    return;%if we got here, we're done! leave function.
                end
            end
            %if we get here, filetype doesn't already exist.
            obj.files(length(obj.files)+1) = fileObj;
        end
        
        function addValue(obj,uTime,value,depth,variableName)
            %ADDVALUE Adds a value observation to this site. 
            % Uses default subsite. Mostly used for large data import
            % uTime must be unix timestamp (see datenum2unix)
            % value must be double floating point
            % depth must be double float or NaN
            % variableName must match GLEON controlled vocab (see variables
            % table in lakebase db)
            
            %id,substreamid,unixtime,value,depth,varname
            obj.data{length(obj.data)+1} = {NaN,NaN,uTime,value,depth,variableName};
        end
    end
    
end


classdef LakeNew < handle
    %LAKE An object representing a lake and its metadata
    %   Detailed explanation goes here
    
    properties
        %these will always exist
        id;
        name;
        lat;
        lon;
        files;
        state;
    end
    properties(Access=protected)
        %lake attribute data
        attributes = [];%type,contributor,numvalue,strvalue
        data; %id,substreamid,unixtime,value,depth,varname
        
        
    end
    properties(Access=private)
        dataRetrieved = false;
        attsRetrieved = false;
        %actual observation value data
        
    end
    
    methods
        function obj = LakeNew(lakeid,lattitude,longitude)
            %LAKENEW Construct lake object
            obj.id = [];
            obj.lat = [];
            obj.lon = [];
            obj.state = LakeState.unknown;
            obj.files = [];
            
            %If supplied, fill in lake id and lat/lon, otherwise assume we
            %don't know the id, lat, or lon
            if(nargin == 1)
                obj.id = lakeid;
            end
            
            if(nargin == 3)
                obj.id = lakeid;
                obj.lat = lattitude;
                obj.lon = longitude;
            end
        end
        
        function names = getAttributeNames(obj)
            %GETATTRIBUTENAMES Return attribute names this lake has
            
            if(~obj.attsRetrieved)
                obj.retrieveAttributes();
            end
            
            names = unique(obj.attributes(:,1));
        end
        
        function prop = getAttribute(obj,propName)
            
            if(~obj.attsRetrieved)
                obj.retrieveAttributes();
            end
            
            check = obj.attributes(strcmpi(obj.attributes(:,1),propName),:);
            
            %Does the requested property even exist for this lake?
            if(isempty(check))
                prop = [];
                return;
            end
            
            %Either it is in the strval column, or the numval column. 
            % Check to see if the numval column is NaN (NULL in DB). If it
            % is NaN, must be a stringval type
            if(isnan(check{3}))
                prop = check{4};
            else
                prop = check{3};
            end
        end
        
        function data = getTSData(obj,variable)
            %GETTSDATA Get Time-series data for this lake
            
            if(~obj.dataRetrieved)
                obj.retrieveData();
            end
            
            %These are the columns of obj.data
            %id,substreamid,unixtime,value,depth,varname
            if(nargin == 2)
                data = obj.data(strcmpi(obj.data(:,6),variable),[3 4 5 6]);
            else
                data = obj.data(:,[3 4 5 6]);
            end
        end
        
        function putAttribute(obj,attType,val)
            %PUTATTRIBUTES Add or replace attribute value
            
            %Lazily initiailize attributes
            if(~obj.attsRetrieved)
                obj.retrieveAttributes();
            end
            
            if(isempty(attType))
                error('Attribute Type cannot be empty!');
            end
            
            %type,contributor,numvalue,strvalue
            indx = find(strcmpi(obj.attributes(:,1),attType),1);
            
            if(isnumeric(val))
                colindx = 3;
            elseif(ischar(val))
                colindx = 4;
            else
                error('attribute value must be string or numeric!');
            end
            
            if(~isempty(indx))
                obj.attributes{indx,colindx} = val;
            else
                global contributor;
                newRow = {attType,contributor,NaN,'null'};
                newRow{colindx} = val;
                obj.attributes(size(obj.attributes,1)+1,:) = newRow;
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
            
            if(~obj.attsRetrieved)
                obj.retrieveAttributes();
            end
            
            error('lake.mergeAttributes not implemented yet');
			%obj.attributes.putAll(toMerge.attributes);
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
            obj.data(length(obj.data)+1,:) = {NaN,NaN,datenum2unix(uTime),value,depth,variableName};
        end
        
        function populateAllData(obj)
            if(isempty(obj.id))
                error('Sorry, can not populate lake object without lake ID');
            end
            
            obj.retrieveAttributes();
            obj.retrieveData();
            obj.retrieveLatLonName();
        end
    end
    methods(Access=private)
        function retrieveAttributes(obj)
            sql = sprintf('Select name,contributor,numvalue,strvalue from `siteattributes` s join `attributetypes` a on a.id = s.type where site=%i',obj.id);
            obj.attributes =  fetch(LakeNew.getConn(),sql);
            obj.attsRetrieved = true;
        end
        
        function retrieveData(obj)
            dataRS = fetch(LakeNew.getConn(),['SELECT datavalues.id,datavalues.substream, UNIX_TIMESTAMP(datavalues.timestamp), datavalues.value, substreams.depth, variables.name' ...
                ' FROM datavalues' ...
                ' JOIN substreams ON datavalues.substream = substreams.id' ...
                ' JOIN streams ON substreams.stream = streams.id '...
                ' JOIN subsites ON subsites.id = streams.subsite '...
                ' JOIN variables ON variables.id = streams.variable '...
                ' WHERE subsites.site = ' num2str(obj.id) ]);
            if(isempty(dataRS))
                obj.data = [];
            else
                obj.data = dataRS;
                for i=1:size(obj.data,1)
                    obj.data{i,3} = unix2datenum(obj.data{i,3});
                end
            end
            
            obj.dataRetrieved = true;
            
        end
        
        function retrieveFiles(obj)
            
        end
        
        function retrieveLatLonName(obj)
            d = fetch(LakeNew.getConn(),sprintf('select lat,lon,name from sites where id=%i',obj.id));
            if(isempty(d))
                error('No Lake with that ID.');
            end
            
            obj.lat = d{1};
            obj.lon = d{2};
            obj.name = d{3};
        end
    end
    methods(Static,Access=private)
        function dbconn = getConn()
            %GETCONN Connect to the lakebase database.
            %
            %   This function creates and returns the appropriate database connection 
            %   object for the lakebase server. It automatically caches the connection 
            %   and will not re-build the connection if it isn't required.

            %First add the jconnection library to the javaclasspath if needed
            % CHECK FIRST! javaaddpath calls 'clear java' which wipes out all
            % global variables and means the whole global caching below won't work.
            warning('off','MATLAB:Java:DuplicateClass');
            classpath = javaclasspath('-dynamic');
            if(isempty(strfind(classpath,'./mysql-connector-java-bin.jar')))
                javaaddpath('./mysql-connector-java-bin.jar');
            end

            persistent conn;
            if(isempty(conn) || ~isconnection(conn))
                %conn = database('lakebase','root','p@ss4r00t',...
                %     'com.mysql.jdbc.Driver','jdbc:mysql://mysql.uwcfl.org/lakebase');
                conn = database('lakebase','matlabUser','xStA7LbHjpvDRd6T',...
                    'com.mysql.jdbc.Driver','jdbc:mysql://lakebase.gleon.org/lakebase');
            end

            dbconn = conn;
        end
    end
end


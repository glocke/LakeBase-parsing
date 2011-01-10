classdef LakeState
    properties  (Constant)
        unknown = 0;
        db = 1;
        modified = 2;
        new = 3;
    end
    methods (Access = private)
    %private so that you can't instatiate.
        function out = LakeState()
        end
    end
end
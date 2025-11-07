MODULE UtilityModule
    !***********************************************************************************
    ! Utility functions module
    !***********************************************************************************
    
    CONST num PI := 3.14159265359;
    
    FUNC num DegToRad(num degrees)
        RETURN degrees * PI / 180;
    ENDFUNC
    
    FUNC num RadToDeg(num radians)
        RETURN radians * 180 / PI;
    ENDFUNC
    
ENDMODULE

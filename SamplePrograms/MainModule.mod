MODULE MainModule
    !***********************************************************************************
    !
    ! ABB Robot Sample Program
    ! Description: Sample program demonstrating RAPID syntax
    !
    !***********************************************************************************
    
    ! Variable declarations
    VAR num counter := 0;
    VAR bool isRunning := TRUE;
    PERS robtarget pHome := [[500,0,600],[1,0,0,0],[0,0,0,0],[9E9,9E9,9E9,9E9,9E9,9E9]];
    PERS robtarget pTarget1 := [[600,100,400],[1,0,0,0],[0,0,0,0],[9E9,9E9,9E9,9E9,9E9,9E9]];
    CONST num MAX_COUNT := 10;
    
    ! Tool and work object data
    PERS tooldata tGripper := [TRUE,[[0,0,100],[1,0,0,0]],[0.5,[0,0,50],[1,0,0,0],0,0,0]];
    PERS wobjdata wobj1 := [FALSE,TRUE,"",[[0,0,0],[1,0,0,0]],[[0,0,0],[1,0,0,0]]];
    
    ! Speed and zone data
    VAR speeddata vSpeed := [500,50,5000,1000];
    VAR zonedata zFine := [FALSE,0.3,0.3,0.03,0.3,0.03,0.3];
    
    !***********************************************************************************
    ! Main routine
    !***********************************************************************************
    PROC main()
        ! Initialize
        TPWrite "Starting ABB Robot Program";
        SetDO DO_Lamp, 1;
        
        ! Main loop
        WHILE isRunning = TRUE DO
            ! Move to home position
            MoveJ pHome, vSpeed, zFine, tGripper \WObj:=wobj1;
            WaitTime 0.5;
            
            ! Pick operation
            PickPart;
            
            ! Move to target
            MoveL pTarget1, vSpeed, zFine, tGripper \WObj:=wobj1;
            
            ! Place operation
            PlacePart;
            
            ! Increment counter
            counter := counter + 1;
            
            ! Check if finished
            IF counter >= MAX_COUNT THEN
                isRunning := FALSE;
            ENDIF
        ENDWHILE
        
        ! Cleanup
        SetDO DO_Lamp, 0;
        TPWrite "Program completed. Parts processed: " + NumToStr(counter, 0);
    ENDPROC
    
    !***********************************************************************************
    ! Pick part routine
    !***********************************************************************************
    PROC PickPart()
        ! Open gripper
        SetDO DO_Gripper, 0;
        WaitTime 0.2;
        
        ! Close gripper
        SetDO DO_Gripper, 1;
        WaitDI DI_PartGrasped, 1, \MaxTime:=2;
        
        ! Confirm pick
        IF DI(DI_PartGrasped) = 1 THEN
            TPWrite "Part picked successfully";
        ELSE
            TPWrite "Warning: Part not detected";
        ENDIF
    ENDPROC
    
    !***********************************************************************************
    ! Place part routine
    !***********************************************************************************
    PROC PlacePart()
        ! Open gripper
        SetDO DO_Gripper, 0;
        WaitTime 0.3;
        
        TPWrite "Part placed";
    ENDPROC
    
    !***********************************************************************************
    ! Calculate distance function
    !***********************************************************************************
    FUNC num CalcDistance(robtarget p1, robtarget p2)
        VAR num dx;
        VAR num dy;
        VAR num dz;
        VAR num distance;
        
        dx := p2.trans.x - p1.trans.x;
        dy := p2.trans.y - p1.trans.y;
        dz := p2.trans.z - p1.trans.z;
        
        distance := Sqrt(dx*dx + dy*dy + dz*dz);
        
        RETURN distance;
    ENDFUNC
    
    !***********************************************************************************
    ! Emergency stop trap
    !***********************************************************************************
    TRAP EmergencyStop
        TPWrite "EMERGENCY STOP ACTIVATED!";
        StopMove \Quick;
        SetDO DO_Lamp, 0;
        SetDO DO_Gripper, 0;
    ENDTRAP
    
ENDMODULE

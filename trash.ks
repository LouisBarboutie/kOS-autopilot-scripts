If stage:number > 0 {
    Until ship:deltav:current <= 0.5 {
        if stage:deltav:current <= 0.5 {
            STAGE.
            WAIT 5.
        }
        ELSE {
            print "not stage ready" at (0,0).
        }
    }
}

//
@PART[]:NEEDS[]:AFTER[ImprovedTreeEnginePlacement]
{
    @TechRequired = 
}
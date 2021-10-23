


// trash
    declare local varThrottle is 1.
    

    Until varThrottle = 0
    {
        
        {
            set varThrottle to varThrottle*0.9.
            set TWR to ( ( ship:availableThrust * varThrottle ) / ( ship:mass * constant:g0 ) ) .
        }
    }
    print varThrottle at (0,1).
    print TWR at (0,2).
    return varThrottle.
}



// ===== ascent script =====



// Attitude control
sas off.
rcs on.



// Main Loop
Until false
{
    Until ship:apoapsis >= 100000
    {
        lock throttle to getThrottle().
        lock steering to HEADING(90,getMyHeading(ship:altitude)).
    }
}

trash








function TWR
{
    set TWR to ship:availableThrust * throttle / ( ship:mass * constant:g0 ).
    return TWR.
}











function getMyThrust
{
    set totalThrust to 0.
    for eng in eList
    {
        set totalThrust to (totalThrust + eng:thrust).
        return totalThrust.
    }
}

// thrust to weight ratio calculation
//function TWR
{
    IF ship:availableThrust = 0
    {
        // print "staging" at (0,5).
        doMyStaging().
    }
    ELSE IF ship:availableThrust > 0
    {
       set x to ( ( getMyThrust() ) / ( ship:mass * constant:g0 ) ) .
       print x at (0,2).
       return x.
    }
}



// throttle regulation
function getMyThrottle
{
    set y to 1.
    
    IF TWR() >= 1.8
    {
        set y to y*(0.9).
        return y.
    }
}

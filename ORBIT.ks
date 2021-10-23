// Orbit v2.0.2
// 02 April 2021
// Louis-Hendrik Barboutie
// untested

// function list:
// Heading
// Staging
// TWR calculation
// Throttling
// Maneuver Node Creation
// Maneuver Node Execution

// TODO
// account throttle for lost mass maybe, like make a lock throttle to function(mass flow, maxthrust) instead of trying to do the other shit
// test script without throttle control schtewpid

clearScreen.




// ===== function definition =====
 


// angle of attack
function getMyHeading
{
    // TODO: use timespan/timespan to limit function calls per physics tick
    parameter shipAlt.
    local theta is ceiling( -28.2 + 6300000 / ( shipAlt + 53100 ) , 2 ). // Y0 + A / ( x - x0 )

    IF ship:velocity:surface:mag <= 50 
    {
        print 90 at (0,0).
        return 90.
    }

    ELSE IF ship:velocity:surface:mag > 50
    {
        print theta at (0,0).
        return theta.
    }
}



// staging control
function doMyStaging
{
    IF stage:number > 0 
    {
        If ship:maxthrust = 0
        {
            STAGE.  
            WAIT 5.
        }
        
    }
}


function getThrottle
{
    Until ship:apoapsis >= 100000
    {
        set x to 1.
        local TWR is ( ship:availableThrust ) / ( ship:mass * constant:g0 ) .
    
        When TWR >= 1.8 Then
        {
            set x to x*0.9.
            return x.
        }
    }    
}



// ===== ascent script =====



// Attitude control
sas off.
rcs on.



// Main Loop{
Until ship:apoapsis >= 100000
{
    lock throttle to getThrottle().
    lock steering to HEADING(90,getMyHeading(ship:altitude)).
}

function doOrbitalInsertionManeuver
{
    // get apoapsis speed
    local etaApoapsis is time:seconds + eta:apoapsis.
    local velocityApoapsis is velocityAt(ship, etaApoapsis):orbit:mag.

    // calculate orbital speed
    set orbitalVelocity to sqrt( body:mu / (ship:altitude + body:radius)).

    // calculate maneuver magnitude
    local progradeVelocity is ( orbitalVelocity - velocityApoapsis ).

    // set node to prograde of difference
    set nextNode to NODE(time:seconds + eta:apoapsis,0,0,progradeVelocity).
    add nextNode.
}

function executeManeuver
{
    // burn control

    // isp calculation
    set totalISP to 0.
    set totalFuelFlow to 0.

    LIST engines in eList.

    set initialMass to ship:mass.


    FOR eng in eList
    {
        set totalISP to totalISP + eng:ispat(0).
        set totalFuelFlow to totalFuelFlow + eng:maxfuelflow.
    }

    set halfBurnTime to ( 0.5 * ( initialMass / totalFuelFlow ) * ( 1 - constant:e ^ (- nextNode:deltav:mag / ( totalISP * constant:g0 ) ) ) ).

    //Node Select
    set myNode to nextNode. // getting the next set node

    // initialisation 
    lock steering to myNode:deltav.
    lock throttle to 0.
    set runmode to 1.

    // Main Program
    UNTIL runmode = 0 {

    // Loop Break
        IF ship:maxThrust = 0 and stage:number = 0 and myNode:deltav:mag > 0 {
            set runmode to 0.
        }

    // Staging Control
        IF stage:number > 0 
        {
            IF ship:maxThrust = 0 
            {
                STAGE.
                WAIT 5.
            }
        }.

    // Time Control, check for time until node
        IF runmode = 1 
        {
            IF myNode:eta <= halfBurnTime 
            {
                set runmode to 2.
            }
        }.

    // Burn Control, check for remaining node deltav
        IF  runmode = 2 {
            IF myNode:deltav:mag > 1 {
                lock throttle to 1.
            }
            ELSE IF myNode:deltav:mag <=1 {
                lock throttle to 0.
                set runmode to 0.
            }
        }
    }.

    // End of Program
    IF runmode = 0 {
        sas on.
        lock throttle to 0.
    }.
}




    // create maneuver node
    If ship:apoapsis >= 100000
    {
        set nextNode to doOrbitalInsertionManeuver().
    }



    // execute maneuver node
    If hasNode
    {
        executeManeuver().
    }

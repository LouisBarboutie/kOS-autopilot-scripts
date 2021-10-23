//Orbit V1.0.0

clearScreen.

lights on.

PRINT "Counting down:".
FROM {local countdown is 10.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "..." + countdown.
    WAIT 1.
}   

print "Main Engine Ignition.".

stage.

wait 1.

print "Liftoff.".

 

SET MYSTEER TO HEADING(90,90).
LOCK STEERING TO MYSTEER.


when ship:altitude > 70000 then {
    print "Initiating Solar Panel Deployment.".
    toggle ag1.
}

WHEN STAGE:LIQUIDFUEL < 0.5 THEN {
    print "Main Engine Cutoff.".
    print "Stage Sep.".
    print "Main Engine Ignition.".
    STAGE.
    PRESERVE.
}

when ship:altitude > 3000 then {
    print "Initiating Gravity Turn." .
}

set throttle to  (ship:mass * 1.3 *  / ship:availablethrust) .

UNTIL SHIP:apoapsis > 75000 {
    IF SHIP:altitude > 3000 AND SHIP:altitude < 6000 {
    SET MYSTEER TO HEADING(90,75).
    PRINT "Apoapsis= " + ROUND(SHIP:APOAPSIS,0) at (0,20).

    } ELSE IF SHIP:altitude > 6000 AND ship:altitude < 9000 {
    SET MYSTEER TO HEADING(90,60).
    PRINT "Apoapsis= " + ROUND(SHIP:APOAPSIS,0) at (0,20).

    } ELSE IF SHIP:altitude > 9000 AND ship:altitude < 12000 {
    SET MYSTEER TO HEADING(90,45).
    PRINT "Apoapsis= " + ROUND(SHIP:APOAPSIS,0) at (0,20).

    } ELSE IF SHIP:altitude > 12000  AND ship:altitude < 18000 {
    SET MYSTEER TO HEADING(90,40).
    PRINT "Apoapsis= " + ROUND(SHIP:APOAPSIS,0) at (0,20).

    } ELSE IF SHIP:altitude >= 18000 {
    SET MYSTEER TO HEADING(90,35).
    PRINT "Apoapsis= " + ROUND(SHIP:APOAPSIS,0) at (0,20).
    }
}
. 

PRINT "Desired Apoapsis reached, cutting Throttle.".
LOCK THROTTLE TO 0.

WAIT UNTIL ETA:apoapsis < 20.
SET MYSTEER TO HEADING(90,0).
WAIT 5.
PRINT "Initiating Orbital Insertion Burn.".
LOCK THROTTLE TO 1.

WAIT UNTIL SHIP:periapsis > 70000.
LOCK THROTTLE TO 0.

PRINT "70km orbit reached, cutting Throttle.".

LOCK throttle TO 0.

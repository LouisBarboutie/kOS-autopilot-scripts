// Maneuver Node Executer v0.4
// A program that carries out a maneuver.
// Precision of ~ 0.5 m/s

clearScreen.

// Optional parameter BurnTime, input by typing "run mnvr(parameter)."
parameter BurnTime.

//Node Select
set myNode to nextNode. // getting the next set node

// Controls initialisation 
sas off.
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
    IF stage:number > 0 {
        IF ship:maxThrust = 0 {
            STAGE.
            WAIT 5.
        }
    }.

// Time Control, check for time until node
    IF runmode = 1 {
        IF myNode:eta <= BurnTime / 2 {
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
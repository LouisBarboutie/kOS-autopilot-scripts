// Fault Detection, Isolation and Recovery (FDIR) 
// For engine failure thrust balancing

clearScreen.

set nStages to ship:stagenum.
print "Total number of stages: " + nStages.

function getCenterOfMass {

    set centerOfMass to V(0, 0, 0).
    for part in ship:parts {
        set centerOfMass to centerOfMass + part:mass * part:position.
    }
    set centerOfMass to centerOfMass / ship:mass.

    return centerOfMass.
}

function getCenterOfThrust {
    parameter engines.

    set centerOfThrust to V(0, 0, 0).
    for engine in engines {
        set centerOfThrust to centerOfThrust + engine:availableThrust * engine:position.
    }
    set centerOfThrust to centerOfThrust / ship:availableThrust.

    return centerOfThrust.
}

function getThrustVector {
    parameter engines.

    set thrustVector to V(0, 0, 0).
    for engine in engines {
        set thrustVector to thrustVector - engine:availableThrust * engine:facing:forevector.
    }

    return thrustVector:normalized.
}

function getEnginesInCurrentStage {
    set engines to list().
    for engine in ship:engines {
        if engine:stage = stage:number {
            engines:add(engine).
        }
    }
    
    return engines.
}

lock currentStage to stage:number.
lock watchedEngines to getEnginesInCurrentStage().
lock centerOfMass to getCenterOfMass().
lock centerOfThrust to getCenterOfThrust(watchedEngines).
lock thrustVector to getThrustVector(watchedEngines).
lock angle to vectorAngle(centerOfThrust - centerOfMass, thrustVector).

until false {
    clearScreen.
 
    print "Current stage number: " + currentStage.    
    print "COM: " + centerOfMass.
    print "COT: " + centerOfThrust.
    print "Angle: " + angle.

    if angle > 0 {
        print "Thrust vector not going through the center of mass!".
    }

    set arrow to vecDraw(centerOfMass, centerOfThrust - centerOfMass).
    set arrow:start to centerOfMass.
    set arrow:vec to centerOfThrust.
    set arrow:show to true.

    set thrustArrow to vecDraw().
    set thrustArrow:start to centerOfThrust.
    set thrustArrow:vec to thrustVector.
    set thrustArrow:show to true.
    set thrustArrow:color to RGB(1, 0, 1).

    print "Available thrust:".
    for engine in watchedEngines {
        print engine:title + ": " + engine:availableThrust.
    }

    // throttle in such a way that thrust is maximized
    
    // Handle engines that are active
    // Handle engines that can be shut off
    // Handle engines that cannot be shut off
    

    wait 0.1.
}
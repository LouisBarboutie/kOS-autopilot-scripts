// Local navigation for final approach docking

// Runmode description
// 0 : exit
// 1 : approach 
// 2 : berth
// 3 : safe mode 

declare runmode to 3.
declare alignment_tolerance to 2.
declare safety_distance to 25.

local target_bounds is target:bounds.

lock distance to ship:controlpart:position - target:position. 
//set relative_velocity to V(0,0,0).
lock relative_velocity to target:ship:orbit:velocity:orbit - ship:orbit:velocity:orbit.

// distance trigger to switch control modes    
when (distance:mag < 500 and distance:mag < safety_distance) then {
    set runmode to 1.
}

when ((distance:y^2 + distance:z^2) <= alignment_tolerance^2) then { 
    set runmode to 2.
}

// wrong side (or collision detection)
when (distance:x < 0) then {
    set runmode to 3.
}

// main loop
until runmode = 0 {
    
    wait 1.
    clearscreen.
    print "Runmode  =" + runmode.
    print "Distance =" + distance:mag.
    print "Distance vector:" + distance.
    print "Target position:" + target:position.
    print "Rel. Speed =" + relative_velocity:mag.
    print "Rel. Velocity:" + relative_velocity.
    print "v dot d:" + vDot(relative_velocity, distance). // negative means getting closer
    
    // Navigate to 
    if runmode = 1 {
        lock target_orientation to (-1) * target:portfacing:vector. 
        lock steering to target:position. //+ safety_distance * target:portfacing:vector:normalized.
    }

    if runmode = 2 {
        unlock steering.
        lock steering to target_orientation.
    }
}

{
    // safe mode: navigate to correct side of the target
    if runmode = 3 {
        
        unlock steering.
        lock steering to target:portfacing:vector.
        
        // navigate to safe distance
        until distance:x > safety_distance {
            until relative_velocity:x > 1 {
                set ship:control:fore to 1.
            }            
            set ship:control:fore to 0.
        }

        // brake 
        until relative_velocity:x < 0.1 {
            set ship:control:fore to -1.
        }
        set ship:control:fore to 0.

        set runmode to 1.
    }
}
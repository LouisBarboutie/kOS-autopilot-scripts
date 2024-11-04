// Local navigation for final approach docking

// Runmode description
// 0 : exit
// 1 : docking 
// 2 : aligning 
// 3 : navigation from safety waypoint to 
// 4 : navigation from close distance to safety waypoint 

SAS off.

declare runmode to 3.
declare alignment_tolerance to 2.
declare safety_distance to  25. // target:ship:bounds:size:mag.// 25.
declare max_approach_speed to 0.1.

lock distance to target:position. 
//set relative_velocity to V(0,0,0).
lock relative_velocity to target:ship:orbit:velocity:orbit - ship:orbit:velocity:orbit.

// distances relative to the controlling docking port's orientation
lock F to vDot(distance, ship:controlpart:portfacing:forevector).
lock T to vDot(distance, ship:controlpart:portfacing:topvector).
lock S to vDot(distance, ship:controlpart:portfacing:starvector).
lock F_dot to vDot(relative_velocity, ship:controlpart:portfacing:forevector).
lock T_dot to vDot(relative_velocity, ship:controlpart:portfacing:topvector).
lock S_dot to vDot(relative_velocity, ship:controlpart:portfacing:starvector).

lock target_waypoint to target:position.
lock waypoint_safety_1 to target:position + target:portfacing:starvector * safety_distance * 2.
lock waypoint_safety_2 to target:position - target:portfacing:starvector * safety_distance * 2.
lock waypoint_safety_3 to target:position + target:portfacing:topvector * safety_distance * 2.
lock waypoint_safety_4 to target:position - target:portfacing:topvector * safety_distance * 2.
lock waypoint_alignment to target:position + target:portfacing:forevector * safety_distance.

// distance trigger to switch control modes    
when (distance:mag < 500 and distance:mag < safety_distance) then {
    set runmode to 1.
}

// alignment trigger
// when ((distance:y^2 + distance:z^2) <= alignment_tolerance^2) then { 
//     set runmode to 2.
// }

// wrong side (or collision detection)
when (vDot(distance, target:portfacing:vector) > 0) then {
    set runmode to 3.
}

// main loop
until runmode = 0 {
    
    clearscreen.
    print "Runmode = " + runmode.
    // print "Control part =" + ship:controlpart.
    // print "Target:" + target.
    // print "Distance =" + distance:mag.
    // print "Distance vector:" + distance.
    // print "Target position:" + target:position:direction.
    // print "Rel. Speed =" + relative_velocity:mag.
    // print "Rel. Velocity:" + relative_velocity.
    // print "v dot d:" + vDot(relative_velocity, distance). // negative means getting closer
    print "F: " + F.
    print "T: " + T.
    print "S: " + S.
    print "F_dot:" + F_dot.
    print "T_dot:" + T_dot.
    print "S_dot:" + S_dot.

    // berthing mode
    if runmode = 1 {
        lock target_orientation to (-1) * target:portfacing:vector. 
        lock steering to target_orientation.

        // If S and S_dot have the same sign, moving away
        // Same goes for T and T_dot
        lock top_motion  to T * T_dot.
        lock star_motion to S * S_dot. 
        lock fore_motion to F * F_dot. 

        // debug        
        if (star_motion > 0) print "Moving away in starboard direction".
        else print "Moving closer in starboard direction".
        if (top_motion > 0) print "Moving away in top direction".
        else print "Moving closer in top direction".
        if (fore_motion > 0) print "Moving away in fore direction".
        else print "Moving closer in fore direction".
        
        // alignment control
        until (sqrt(T^2 + S^2) < 0.1) {
            print "Need to correct alignment".
            
            until star_motion < 0 and top_motion < 0 {
                set translation to V(S, T, 0).

                // need to stop if one of the conditions is already reached to avoid circular motion
                if top_motion < 0 {
                    set translation:y to 0.
                }
                if star_motion < 0 {
                    set translation:x to 0.
                }
                
                set ship:control:translation to translation:normalized.
            }
            set ship:control:translation to V(0, 0, 0).
        }
        
        // approach control
        until F_dot < -0.15 {
            set ship:control:fore to 1.
        }
        set ship:control:fore to 0.
    }

    
    if runmode = 2 {
        unlock steering.    
        lock steering to target_orientation.
    }

    // safe mode: navigate to correct side of the target
    if runmode = 3 {
        
        
        // find closest waypoint
        declare target_waypoint to min(min(waypoint_safety_1:mag, waypoint_safety_2:mag), min(waypoint_safety_3:mag, waypoint_safety_4:mag)).
        unlock steering.
        lock steering to target_waypoint.
        // adjust rcs to thrust in ship:control:translation = (STARBOARD, TOP, FORE) direction 

        // navigate to safe distance
        // until distance:x > safety_distance {
        //     until relative_velocity:x > 1 {
        //         set ship:control:fore to 1.
        //     }            
        //     set ship:control:fore to 0.
        // }

        // brake 
        // until relative_velocity:x < 0.1 {
        //     set ship:control:fore to -1.
        // }
        // set ship:control:fore to 0.
    }

    if runmode = 4 {
        unlock steering.
        lock steering to target:position:direction.
    }

    //wait 0.1.
}
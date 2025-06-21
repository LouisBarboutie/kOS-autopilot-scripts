clearScreen.
clearVecDraws().





// ======================================= //
// === Standardize Script Input Target === //
// ======================================= //

if target:istype("Vessel") {
    set vessel_target to target.
}
else if target:istype("Part") {
    set vessel_target to target:ship.
    set target to target:ship.
}





// ============================================== //
// === Select Target and Control Docking Port === //
// ============================================== //

function selectDockingPortOnVessel {
    parameter _vessel.

    local docking_ports to _vessel:dockingports:iterator.

    clearScreen.
    print "Available docking ports on the vessel: " + _vessel:name.
    until not docking_ports:next {
        print docking_ports:index + " " + docking_ports:value:tag.
    }
    print " ".

    print "Input the selected docking port number:".
    set input to terminal:input:getchar():tonumber.
    print input.
    print " ".

    return _vessel:dockingports[input].
}

set highlighted_parts to list().
set port_target to selectDockingPortOnVessel(vessel_target).
highlighted_parts:add(highlight(port_target, RGB(1,0,0))).

set port_chaser to selectDockingPortOnVessel(ship).
highlighted_parts:add(highlight(port_chaser, RGB(0,1,0))).
port_chaser:controlfrom().





// ===================================== //
// === Generate Navigation Waypoints === //
// ===================================== //

function generateWaypoints {

    set bounds_target to vessel_target:bounds.
    set bounds_chaser to ship:bounds.
    set safety_distance to (bounds_target:extents:mag + bounds_chaser:extents:mag) * 1.1.
    set safety_angle to 45.
    
    set vector_target to port_target:position - bounds_target:abscenter.
    set vector_chaser to port_chaser:position - port_target:position.
    set angle_target to vAng(vector_target, vector_chaser).

    set waypoints to list().

    if angle_target >= safety_angle {
        print "Ship is on the wrong side of the target, aborting docking procedure!".
        print "Angle: " + angle_target.

        set axis to port_target:portfacing:topvector.

        set angle_list to list(135, 90, 45, 0).
        set color_list to list(RGB(1,0,0), RGB(0,1,0), RGB(0,0,1), RGB(1,1,1)).

        set angle_iterator to angle_list:iterator.
        until not angle_iterator:next {
            set angle to angle_iterator:value.
            print angle.
            if angle_target > angle {
                set color to color_list[angle_iterator:index].
                set vector to angleAxis(angle, axis) * port_target:portfacing:forevector * safety_distance.
                waypoints:add(vector).
            }
        }
    }
    else {
        print "Ship is on the right side of the target, proceeding with docking procedure!".
        set vector to port_target:portfacing:forevector * safety_distance.
        waypoints:add(vector).
    }

    waypoints:add(port_target:position - bounds_target:abscenter).
    set waypoints_iterator to waypoints:iterator.

    return waypoints_iterator.
}

function updateWaypointArrows {
    parameter arrow_list.
    set iterator to arrow_list:iterator.
    until not iterator:next {
        set arrow_list[iterator:index]:start to bounds_target:abscenter.
    }
}

function updateActiveWaypoint {
    if not target_waypoint_iterator:next {
        return port_target:position - bounds_target:abscenter.
    }    
    else {
        set arrows_waypoints[target_waypoint_iterator:index]:color to RGB(1, 1, 0).
        if target_waypoint_iterator:index > 0 {
            set arrows_waypoints[target_waypoint_iterator:index - 1]:color to RGB(1, 1, 1).
        }
        return target_waypoint_iterator:value.
    }
}


set target_waypoint_iterator to generateWaypoints().

set arrows_waypoints to list().
for waypoint in waypoints {
    arrows_waypoints:add(vecDraw(bounds_target:abscenter, waypoint, RGB(1, 1, 1), "", 1.0, true)).
}
wait 5.





// ======================== //
// === Controller Setup === //
// ======================== //

set target_waypoint_target to updateActiveWaypoint().
lock target_waypoint to target_waypoint_target + port_target:position. 

lock steering to lookDirUp(-port_target:portfacing:forevector, port_target:portfacing:topvector).
lock relative_velocity to port_target:ship:velocity:orbit - ship:velocity:orbit.

RCS on.
SAS off.

set MAX_VELOCITY to 0.5.

set pids_position to lexicon (
    "fore", pidLoop(0.8, 0, 0.5, -MAX_VELOCITY, MAX_VELOCITY),
    "star", pidLoop(0.8, 0, 0.5, -MAX_VELOCITY, MAX_VELOCITY),
    "top", pidLoop(0.8, 0, 0.5, -MAX_VELOCITY, MAX_VELOCITY)
).

set pids_velocity to lexicon (
    "fore", pidLoop(0.5, 0, 0.5, -1, 1),
    "star", pidLoop(0.5, 0, 0.5, -1, 1),
    "top", pidLoop(0.5, 0, 0.5, -1, 1)
).

for key in pids_position:keys {
    set pids_position[key]:setpoint to 0.
}

for key in pids_velocity:keys {
    set pids_velocity[key]:setpoint to 0.
}

set commands_velocity to lexicon(
    "fore", 0,
    "star", 0,
    "top", 0
).

set commands_thrust to lexicon(
    "fore", 0,
    "star", 0,
    "top", 0
).

lock errors_velocity to lexicon(
    "fore", -vdot(relative_velocity, port_chaser:portfacing:forevector),
    "star", -vdot(relative_velocity, port_chaser:portfacing:starvector),
    "top", -vdot(relative_velocity, port_chaser:portfacing:topvector)
).

lock errors_position to lexicon(
    "fore", -vdot(target_waypoint, port_chaser:portfacing:forevector),
    "star", -vdot(target_waypoint, port_chaser:portfacing:starvector),
    "top", -vdot(target_waypoint, port_chaser:portfacing:topvector)    
).

set arrows_port_target to lexicon(
    "fore", vecDraw(port_target:position, port_target:portfacing:forevector, RGB(1, 0, 0), "", 1.0, true),
    "star", vecDraw(port_target:position, port_target:portfacing:starvector, RGB(0, 1, 0), "", 1.0, true),
    "top", vecDraw(port_target:position, port_target:portfacing:topvector, RGB(0, 0, 1), "", 1.0, true)
).

set arrows_port_chaser to lexicon (
    "fore", vecDraw(port_chaser:position, port_chaser:portfacing:forevector, RGB(1, 0, 0), "", 1.0, true),
    "star", vecDraw(port_chaser:position, port_chaser:portfacing:starvector, RGB(0, 1, 0), "", 1.0, true),
    "top", vecDraw(port_chaser:position, port_chaser:portfacing:topvector, RGB(0, 0, 1), "", 1.0, true)
).

set arrows_target to lexicon (
    "target", vecDraw(port_target:position, V(0, 0, 0), RGB(0,1,1), "", 1.0, true),
    "chaser", vecDraw(port_chaser:position, V(0, 0, 0), RGB(0,1,1), "", 1.0, true)
).

function updateDockingPortArrows {
    parameter docking_port.
    parameter arrow_lexicon.

    for key in arrow_lexicon:keys {set arrow_lexicon[key]:start to docking_port:position.}.
    set arrows_port_target:fore:vec to docking_port:portfacing:forevector.
    set arrows_port_target:star:vec to docking_port:portfacing:starvector.
    set arrows_port_target:top:vec to docking_port:portfacing:topvector.  
}

function updateTargettingArrows {
    parameter arrow_lexicon.
     
    set arrow_lexicon:chaser:start to port_chaser:position.
    set arrow_lexicon:chaser:vec to target_waypoint - port_chaser:position. 

    set arrow_lexicon:target:start to port_target:position. 
    set arrow_lexicon:target:vec to target_waypoint - port_target:position.
}

function printErrorLexicon {
    parameter error_lexicon.
    parameter precision.
    parameter title.

    print title.
    for key in error_lexicon:keys {
        print key + ": " + round(error_lexicon[key], precision).
    }
    print " ".
}

function updatePidRanges {

    for direction in pids_position:keys {
        if abs(errors_position[direction]) > 25 {
            set pids_position[direction]:maxoutput to 1.
            set pids_position[direction]:minoutput to -1.
        }
        else {
            set pids_position[direction]:maxoutput to MAX_VELOCITY.
            set pids_position[direction]:minoutput to -MAX_VELOCITY.
        }
    }
}

function updatePidCommands {

    for direction in pids_position:keys {
        set commands_velocity[direction] to pids_position[direction]:update(time:seconds, errors_position[direction]). 
    }
    
    local vector to V(commands_velocity:fore, commands_velocity:star, commands_velocity:top). 
    if vector:mag > MAX_VELOCITY {
        set commands_velocity:fore to MAX_VELOCITY * vector:normalized:x.
        set commands_velocity:star to MAX_VELOCITY * vector:normalized:y.
        set commands_velocity:top to MAX_VELOCITY * vector:normalized:z.
    }

    for direction in pids_velocity:keys {
        set commands_thrust[direction] to pids_velocity[direction]:update(time:seconds, errors_velocity[direction] - commands_velocity[direction]).
    }
}

function printPidCommands {
    parameter commands_lexicon.
    parameter precision.
    parameter title.

    print title.
    for key in commands_lexicon:keys {
        print key + ": " + round(commands_lexicon[key], precision).
    }
    print " ".
}





// ================= //
// === Main Loop === //
// ================= //

until  port_target:state:substring(0, 4) = "Dock" {

    clearScreen.
    printErrorLexicon(errors_position, 3, "Errors Position:").
    printErrorLexicon(errors_velocity, 3, "Errors Velocity:").

    updateTargettingArrows(arrows_target).
    updateDockingPortArrows(port_target, arrows_port_target).
    updateDockingPortArrows(port_chaser, arrows_port_chaser).
    updateWaypointArrows(arrows_waypoints).

    updatePidRanges().
    updatePidCommands().

    printPidCommands(commands_velocity, 3, "Commands Velocity:").
    printPidCommands(commands_thrust, 3, "Commands Thrust:").

    set ship:control:translation to V(commands_thrust:star, commands_thrust:top, commands_thrust:fore).

    if (target_waypoint - ship:position):mag < 1 {
        set target_waypoint_target to updateActiveWaypoint().    
    }
}





// =============== //
// === Cleanup === //
// =============== //

RCS off.
SAS on.

clearVecDraws().

for highlighted_part in highlighted_parts {
    set highlighted_part:enabled to false.
}
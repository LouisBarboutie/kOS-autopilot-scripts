RCS on.
SAS off.

set pid_fore to pidLoop(0.05, 0, 0.5, -1, 1).
set pid_star to pidLoop(0.05, 0, 0.5, -1, 1).
set pid_top to pidLoop(0.05, 0, 0.5, -1, 1).

set pid_fore:setpoint to 0.
set pid_star:setpoint to 0.
set pid_top:setpoint to 0.

set measurement_fore to 0.
set measurement_star to 0.
set measurement_top to 0.

set command_fore to 0.
set command_star to 0.
set command_top to 0.

lock target_vec to  target:portfacing:forevector * 25.
lock steering to -target_vec.
lock relative_velocity to target:ship:velocity:orbit - ship:velocity:orbit.
lock distance to target:position + target_vec.

set weight to 0.3.
lock control_variable to  (1 - weight) * distance + weight * relative_velocity.

set arrow to vecDraw(target:position, target_vec, RGB(1,1,1), "", 1.0, true).
set target_arrow to vecDraw(ship:position, control_variable, RGB(1,1,1), "", 1.0, true).
set fore_arrow to vecDraw(ship:position, ship:controlpart:portfacing:forevector, RGB(1,0,0), "", 1.0, true).
set star_arrow to vecDraw(ship:position, ship:controlpart:portfacing:starvector, RGB(0,1,0), "", 1.0, true).
set top_arrow to vecDraw(ship:position, ship:controlpart:portfacing:topvector, RGB(0,0,1), "", 1.0, true).

set history to list().

until false {

    clearScreen.

    print "Relative Distance Fore: " + round(vdot(distance, ship:controlpart:portfacing:forevector), 3). 
    print "Relative Distance Star: " + round(vdot(distance, ship:controlpart:portfacing:starvector), 3). 
    print "Relative Distance Top:  " + round(vdot(distance, ship:controlpart:portfacing:topvector), 3). 

    print "Relative Speed Fore: " + round(vdot(relative_velocity, ship:controlpart:portfacing:forevector), 3). 
    print "Relative Speed Star: " + round(vdot(relative_velocity, ship:controlpart:portfacing:starvector), 3). 
    print "Relative Speed Top:  " + round(vdot(relative_velocity, ship:controlpart:portfacing:topvector), 3). 

    // ===================== //
    // === UPDATE ARROWS === //
    // ===================== //

    set arrow:start to target:position.
    set arrow:vec to target_vec.
    set target_arrow:vec to control_variable.

    set fore_arrow:vec to ship:controlpart:portfacing:forevector.
    set star_arrow:vec to ship:controlpart:portfacing:starvector.
    set top_arrow:vec to ship:controlpart:portfacing:topvector.    

    // ========================= //
    // === UPDATE CONTROLLER === //
    // ========================= //

    set measurement_fore to -vdot(control_variable, ship:controlpart:portfacing:forevector).
    set measurement_star to -vdot(control_variable, ship:controlpart:portfacing:starvector).
    set measurement_top to -vdot(control_variable, ship:controlpart:portfacing:topvector).

    set command_fore to pid_fore:update(time:seconds, measurement_fore).
    set command_star to pid_star:update(time:seconds, measurement_star).
    set command_top to pid_top:update(time:seconds, measurement_top).

    print "Control Variable Fore: " + round(measurement_fore, 3).
    print "Control Variable Star: " + round(measurement_star, 3).
    print "Control Variable Top:  " + round(measurement_top, 3).
    print "Control Variable: " + control_variable:mag.

    print "Throttle Fore: " + round(command_fore, 3).
    print "Throttle Star: " + round(command_star, 3).
    print "Throttle Top:  " + round(command_top, 3).

    set command to V(command_star, command_top, command_fore).

    set abs_val to command:mag.

    print "Throttle magnitude: " + abs_val.

    // ========================== //
    // === ACTUATE RCS THRUST === //
    // ========================== //

    if abs_val > 0.05 * sqrt(3) {
        set ship:control:translation to command.
    }
    
    else {
        set pulse_duration to abs_val / 0.05 * 0.1.
        set ship:control:translation to  command:normalized * 0.1.
        wait pulse_duration.
        set ship:control:translation to V(0, 0, 0).
    }
    
    // =========================== //
    // === STABILITY CRITERION === //
    // =========================== //

    history:add(round(abs_val, 1)).
    if history:length > 100 {
        history:remove(0).
        set sum to 0.
        for item in history {
            set sum to sum + item.
        }

        // aim for the docking port
        if sum = 0 {
            lock target_vec to target:portfacing:forevector.
        }
    }

    wait 0.
}



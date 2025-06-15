RCS on.
SAS off.

set MAX_VELOCITY to 0.2.

set pid_position to pidLoop(1, 0, 0.5, -MAX_VELOCITY, MAX_VELOCITY).
set pid_velocity to pidLoop(1, 0, 0.5, -1, 1).

set pid_top to pidLoop(0.5, 0, 0.5, -1, 1).
set pid_star to pidLoop(0.5, 0, 0.5, -1, 1).

set pid_position:setpoint to 0.
set pid_velocity:setpoint to 0.
set pid_top:setpoint to 0. 
set pid_star:setpoint to 0. 

lock steering to  lookDirUp(-target:portfacing:forevector, target:portfacing:topvector).

lock distance to target:position - ship:controlpart:position.
lock relative_velocity to target:ship:velocity:orbit - ship:velocity:orbit.
lock error_position to -vdot(distance, ship:controlpart:portfacing:forevector).
lock error_velocity to -vdot(relative_velocity, ship:controlpart:portfacing:forevector).
lock error_star to -vdot(distance, ship:controlpart:portfacing:starvector).
lock error_top to -vdot(distance, ship:controlpart:portfacing:topvector).

set arrow to vecDraw(target:position, target_vec, RGB(1,1,1), "", 1.0, true).
// set target_arrow to vecDraw(ship:position, control_variable, RGB(1,1,1), "", 1.0, true).
set fore_arrow to vecDraw(ship:controlpart:position, ship:controlpart:portfacing:forevector, RGB(1,0,0), "", 1.0, true).
set star_arrow to vecDraw(ship:controlpart:position, ship:controlpart:portfacing:starvector, RGB(0,1,0), "", 1.0, true).
set top_arrow to vecDraw(ship:controlpart:position, ship:controlpart:portfacing:topvector, RGB(0,0,1), "", 1.0, true).
set target_fore_arrow to vecDraw(target:position, target:portfacing:forevector, RGB(1,0,0), "", 1.0, true).
set target_star_arrow to vecDraw(target:position, target:portfacing:starvector, RGB(0,1,0), "", 1.0, true).
set target_top_arrow to vecDraw(target:position, target:portfacing:topvector, RGB(0,0,1), "", 1.0, true).


until false {
    clearScreen.

    print "Distance: " + distance.
    print "Velocity: " + relative_velocity.
    print "Error Position: " + error_position.
    print "Error Velocity: " + error_velocity.

    set arrow:start to ship:controlpart:position.
    set arrow:vec to distance.
    // set target_arrow:vec to control_variable.

    set fore_arrow:vec to ship:controlpart:portfacing:forevector.
    set star_arrow:vec to ship:controlpart:portfacing:starvector.
    set top_arrow:vec to ship:controlpart:portfacing:topvector.    
    
    set target_fore_arrow:start to target:position.
    set target_star_arrow:start to target:position.
    set target_top_arrow:start to target:position.
    
    set target_fore_arrow:vec to target:portfacing:forevector.
    set target_star_arrow:vec to target:portfacing:starvector.
    set target_top_arrow:vec to target:portfacing:topvector.    

    set command_velocity to pid_position:update(time:seconds, error_position).
    if abs(command_velocity) > MAX_VELOCITY and abs(error_velocity) < MAX_VELOCITY {
        set command_velocity to MAX_VELOCITY * command_velocity / abs(command_velocity).
    }

    set command_thrust to pid_velocity:update(time:seconds, error_velocity - command_velocity).
    
    print "Command Velocity: " + command_velocity.
    print "Command Thrust: " + command_thrust.

    set command_star to pid_star:update(time:seconds, error_star).
    set command_top to pid_top:update(time:seconds, error_top).

    set ship:control:translation to v(command_star, command_top, command_thrust).
}
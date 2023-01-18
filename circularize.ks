// vis-viva equation

// v = sqrt( mu ( 2 / r - 1 / a) ) for elliptical orbit
// v = sqrt( mu ( 2 / r) ) for circular orbit

clearScreen.

// script input
//parameter altitudeCircularOrbit is 100000. // alt in meter

// variables
declare velocityCircularOrbit to 0.
declare velocityApoapsis to 0.
declare mu to ship:body:mu.

function computeCircularOrbitVelocity{
    declare local r to ship:obt:apoapsis.
    
    set r to r + ship:obt:body:radius.
    set velocityCircularOrbit to SQRT( mu * ( 1 / r )).
    
    print "Velocity of target circular orbit: " + velocityCircularOrbit.
    
    return velocityCircularOrbit.
}

function computeApoapsisVelocity{
    declare local a to 0.
    declare local r to 0.

    set a to ship:obt:semimajoraxis.
    set r to ship:obt:apoapsis + ship:obt:body:radius.

    set velocityApoapsis to SQRT( mu * ( 2 / r - 1 / a)).
    
    print "Velocity at apoapsis: " + velocityApoapsis.

    return velocityApoapsis.
}

function planManeuver{
    declare local dv to 0.
    declare local etaApoapsis to 0.

    set dv to velocityCircularOrbit - velocityApoapsis.
    set etaApoapsis to ship:obt:eta:apoapsis.
    set maneuverNode to NODE(TimeSpan(0, 0, 0, 0, etaApoapsis), 0, 0, dv).
    add maneuverNode.
    computeManeuverBurnTime(dv).
}

function computeTotalISP{
    declare global totalISP to 0.
    declare local numerator to 0.
    declare local denumerator to 0.
    
    //isp is given by : Sum(Thrust_i)/Sum(Thrust_i/ISP_i)
    // use loop for eng in myeng or something
    
    list engines in engineList.

    for engine in engineList{
        if engine:ignition{
            set numerator to numerator + engine:maxthrust.
            set denumerator to  denumerator + ((engine:maxthrust) / (engine:isp)).
        }
    }

    set totalISP to numerator / denumerator.
    
    print "Total ISP is: " + totalISP.

    return totalISP.
}

function computeTotalMassFlow{
    // dm/dt
    declare global totalMassFlow to 0.

    list engines in engineList.

    for engine in engineList{
        if engine:ignition{
            set totalMassFlow to totalMassFlow + engine:maxmassflow.
        }
    }

    print "Total mass flow is: " + totalMassFlow.

    return totalMassFlow.
}

function computeManeuverBurnTime{
    // tsiolkovsky rocket equation:
    // dv = Isp * g0 * ln( m0 / mf )
    // and fuel flow:
    // dm/dt = cst
    parameter dv.

    declare local initialMass to ship:mass.
    declare global burnTime to 0. 

    set burnTime to (1 - constant:e^(-dv / (totalISP * constant:g0))) * initialMass / totalMassFlow.

    print "Burn time is: " + burnTime.
}

computeCircularOrbitVelocity().
computeApoapsisVelocity().
computeTotalISP().
computeTotalMassFlow().
planManeuver().
runOncePath("MNVR.ks", burnTime).
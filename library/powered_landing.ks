// NOTE: Staging during this process is fatal if the next stage has less 
//       max accelation than the initial one. 

parameter distance_buffer is 50.
parameter stage_mult is 1.

copy f_autostage.ks from 0. run once f_autostage.ks.
copy f_remap.ks from 0. run f_remap.ks.

// FUNCTIONS
function time_to_impact {
    // This function is copied from Kevin Gisi
    // Project: ksprogramming https://github.com/gisikw/ksprogramming
    // Copyright (c) 2015 Kevin Gisi
    // License (MIT) https://github.com/gisikw/ksprogramming/blob/master/license.txt
    parameter buffer.

    local d is alt:radar - buffer.
    if d <= 0 { set d to .001. }
    local v is -ship:verticalspeed.
    local g is ship:body:mu / ship:body:radius^2.

    return (sqrt(v^2 + 2 * g * d) - v) / g.
}

lock steering to ship:srfretrograde.

gear on.
clearscreen.
until 0 {
    set max_acc to ship:maxthrust/ship:mass.
    set burn_duration to abs(ship:airspeed/(max_acc*stage_mult)).
    set tti to time_to_impact(50).
    set diff to tti - burn_duration.
    
    print "       max_acc: " + round(max_acc,2) + "     " at (5, 5).
    print " burn_duration: " + round(burn_duration,2) + "     " at (5, 6).
    print "time to impact: " + round(tti,2) + "     " at (5, 7).
    print "          diff: " + round(diff,2) + "     " at (5, 8).
    print "     alt:radar: " + round(alt:radar,2) + "     " at (5, 9).
    
    if alt:radar < 10 and ship:airspeed < .5 { break. }
    
    if ship:verticalspeed > -5 {
        set tval to 0.
    } else if time_to_impact(distance_buffer) <= burn_duration {
        set tval to remap(diff, 1, -1, .1, 1).
    } else {
        set tval to 0.
    }
    if autostage() {
        set stage_mult to 1.
    }
    lock throttle to tval.
    wait 0.01.
}
lock throttle to 0.
unlock steering.
clearscreen.
print "you have landed!".


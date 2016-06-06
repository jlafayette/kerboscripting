// MISSION LKO Rescue

set ship:control:pilotmainthrottle to 0. wait 1.

set tgt_direction to 90.

// WAIT FOR TARGET
copy f_tgt.ks from 0. run f_tgt. // lng_to_deg, tgt_angle, close_enough
set tgt_ves to vessel("Natagy's Heap").

clearscreen.
until 0 {
    print "      ship:longitude: " + round(ship:longitude,2) +    "      " at (0, 2).
    print "   tgt_ves:longitude: " + round(tgt_ves:longitude,2) + "      " at (0, 3).
    if close_enough(ship:longitude, tgt_ves:longitude, 35) {
        break.
    } else if close_enough(ship:longitude, tgt_ves:longitude, 45) {
        if warp > 2 { set warp to 2. }
    }
}
set warp to 0. wait 7.
//wait until close_enough(ship:longitude, tgt_ves:longitude, 2).
delete f_tgt from 1.

// LAUNCH
clearscreen.
copy f_pid.ks from 0. run f_pid.
copy f_autostage from 0. run once f_autostage.
copy launch.ks from 0.
// TODO: get tgt vessel altitude 30 in the future at the approx meeting point.
run launch((tgt_ves:altitude), 200, tgt_direction).
delete launch.ks from 1.

// DEPLOY SOLAR PANELS
panels on.

// DEPLOY ANTENNA FOR COMMUNICATION
set antenna_list to ship:partsdubbed("Communotron 16").
if antenna_list:length > 0 {
    set antenna to antenna_list[0].
    antenna:getmodule("ModuleAnimateGeneric"):doevent("extend").
    wait 1.
}

// CIRCULARIZE
copy circularize.ks from 0.
run circularize(tgt_direction).
wait 1.
clearscreen.
delete f_pid.ks from 1.
delete circularize.ks from 1.


// RENDEZVOUS FUNCTIONS

function change_obt_period {
    parameter new_period.
    
    clearscreen.
    print "Changing orbital period...".
    print "new period: " + new_period.
    if ship:obt:period < new_period { 
        lock steering to ship:prograde. 
        lock condition to ship:obt:period > new_period.
    } else {
        lock steering to ship:retrograde. 
        lock condition to ship:obt:period < new_period.
    }
    wait 8.
    until condition {
        set diff to abs(ship:obt:period - new_period).
        set tval to remap(diff, 0, 100, .01, 1).
        lock throttle to tval.
        print "diff: " + round(diff, 2) + "      " at (5, 4).
        print "tval: " + round(tval, 2) + "      " at (5, 5).
        wait .01.
    }
    lock throttle to 0.
}

function burn_towards_target {
    clearscreen.
    print "Burning towards target..." at (0, 1).
    // til goal m/s determined by target distance.
    lock steering to tgt_ves:position. wait 8.
    lock rv to (ship:velocity:orbit - tgt_ves:velocity:orbit):mag. // relative velocity.
    lock tgt_rv to remap(tgt_ves:distance, 200, 8000, 8, 150).
    lock tmax to remap(tgt_rv, 2, 50, .05, 1).
    lock tval to remap(rv, tgt_rv, 0, .05, tmax).
    lock throttle to tval.
    
    until 0 { // burn til moving towards the target.
        print "In Loop 1..." at (0, 2).
        set last_d to tgt_ves:distance.
        print "    rv: " + round(rv, 2) + "      " at (5, 3).
        print "tgt_rv: " + round(tgt_rv, 2) + "      " at (5, 4).
        print "  tmax: " + round(tmax, 2) + "      " at (5, 5).
        print "  tval: " + round(tval, 2) + "      " at (5, 6).
        wait .1.
        if tgt_ves:distance < last_d { break. }
    }
    until rv > tgt_rv { // burn til reaching target rv.
        print "In Loop 2..." at (0, 2).
        // as rv approaches tgt_rv, throttle approaches 0
        print "    rv: " + round(rv, 2) + "      " at (5, 3).
        print "tgt_rv: " + round(tgt_rv, 2) + "      " at (5, 4).
        print "  tmax: " + round(tmax, 2) + "      " at (5, 5).
        print "  tval: " + round(tval, 2) + "      " at (5, 6).
        wait .01.
    }
    lock throttle to 0.
}

function wait_for_closest_approach {
    clearscreen.
    print "Waiting for closest_approach..." at (0, 1).
    until 0 {
        set last_d to tgt_ves:distance.
        wait .1.
        print "diff per .1/s: " + round(last_d - tgt_ves:distance, 2) + "      " at (5, 3).
        if tgt_ves:distance > last_d { break. }
    }
}

function kill_relative_velocity {
    clearscreen.
    print "Killing relative velocity..." at (0, 1).
    // steering should already be set.
    lock rv to (ship:velocity:orbit - tgt_ves:velocity:orbit):mag.
    until rv < .3 {
        set tval to remap(rv, 0, 50, .05, 1).
        lock throttle to tval.
        print "relative velocity: " + round(rv, 2) + "      " at (5, 3).
        wait .01.
    }
    lock throttle to 0.
}

function remap {
    parameter x, a, b, c, d. // input inputLow inputHigh outputLow outputHigh
    
    // d must be greater than c for this function to work.
    set r to (x-a)/(b-a) * (d-c) + c.
    if r > d { return d. }
    else if r < c { return c. }
    else { return r. }
}


copy f_tgt.ks from 0. run f_tgt.ks.

// GET WITHIN APPROACH RANGE
set approach_range to 8000.
lock my_v to ship:velocity:orbit.
lock tgt_v to tgt_ves:velocity:orbit.
lock rv to (my_v - tgt_v):mag. // relative velocity.


if tgt_ves:distance > approach_range {
    set current_period to ship:obt:period.
    // get new orbital period
    // assume target is behind us
    if tgt_angle(tgt_ves) < 180 { // target is in front of us.
        print "Error: Unsupported target position...".
        wait until 0. // Stops the program.
    } else { // target is behind us (fire prograde)
        set diff to 360 - tgt_angle(tgt_ves).
        set new_period to tgt_ves:obt:period * (1 + (diff/360)).
    } 
    set start_time to time:seconds.
    change_obt_period(new_period).
    set end_time to time:seconds.
    set burn_time to start_time - end_time.
    
    wait new_period - (60 + burn_time/2).
    set warp to 0.
    
    wait 40.
    change_obt_period(tgt_ves:obt:period).
    
    lock steering to tgt_v - my_v. wait 5. // ready for killing rv.
    wait_for_closest_approach().
    kill_relative_velocity().
}

// APPROACH TARGET
until 0 {
    
    burn_towards_target().
    lock steering to tgt_v - my_v.
    wait_for_closest_approach().
    kill_relative_velocity().
    if tgt_ves:distance < 200 {
        break.
    }
    wait 1.
}
clearscreen.
print "Successfully rendezvous with " + tgt_ves:name.
wait 10.

// WAIT UNTIL CREW IS ABOARD
clearscreen.
until 0 {
    print "Waiting for crew to board." at (0, 1).
    if ship:crew():length > 0 { break. }
    wait 1.
}

// DEORBIT
clearscreen.
print "Deorbiting...".
wait 10.
copy deorbit from 0.
run deorbit.
delete deorbit from 1.

// REENTRY
clearscreen.
print "Preparing for re-entry.".
lock steering to ship:prograde. wait 8.
stage. wait 5.

print "Added parachute trigger.".
when ((ship:airspeed < 250) and (alt:radar < 1500)) then {
    print "Deploying parachutes.".
    stage.
}

until alt:radar < 500 {
    print "ALT:RADAR: " + round(alt:radar, 2) + "    " at (5, 5).
    lock steering to ship:srfretrograde.
    wait 0.1.
}
unlock steering.
clearscreen.
print "Finished mission script.".

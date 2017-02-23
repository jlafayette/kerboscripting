// MISSION LKO Rescue

set ship:control:pilotmainthrottle to 0. wait 1.

set tgt_direction to 90.

// WAIT FOR TARGET
copypath("0:/f_tgt.ks", "1:/"). runpath("f_tgt.ks"). // lng_to_deg, tgt_angle, close_enough
set tgt_name to "Natagy's Heap".
set tgt_ves to vessel(tgt_name).

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
deletepath("1:/f_tgt.ks").

// LAUNCH
clearscreen.
copypath("0:/f_pid.ks", "1:/"). runpath("1:/f_pid.ks").
copypath("0:/f_autostage.ks", "1:/"). runoncepath("f_autostage.ks").
copypath("0:/launch.ks", "1:/").
// TODO: get tgt vessel altitude 30 in the future at the approx meeting point.
runpath("launch.ks", tgt_ves:altitude, 200, tgt_direction).
deletepath("1:/launch.ks").

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
copypath("0:/circularize.ks", "1:/").
runpath("circularize.ks", tgt_direction).
wait 1.
clearscreen.
deletepath("1:/f_pid.ks").
deletepath("1:/circularize.ks").


// DOWNLOAD RENDEZVOUS LIB
copypath("0:/f_remap.ks", "1:/"). runpath("1:/f_remap.ks").
copypath("0:/f_tgt.ks", "1:/"). runpath("1:/f_tgt.ks").


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

// GET WITHIN APPROACH RANGE
set approach_range to 8000.

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
}

// APPROACH
copypath("0:/approach.ks", "1:/").
runpath("approach.ks", tgt_name).
deletepath("1:/approach.ks").


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
copypath("0:/deorbit.ks", "1:/").
runpath("deorbit.ks").
deletepath("1:/deorbit.ks").


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

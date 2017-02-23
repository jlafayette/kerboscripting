parameter vessel_name.

copypath("0:/f_remap.ks", "1:/"). runpath("1:/f_remap.ks").

set tgt_ves to vessel(vessel_name).


// APPROACH FUNCTIONS
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

// SETUP FOR APPROACH
lock my_v to ship:velocity:orbit.
lock tgt_v to tgt_ves:velocity:orbit.
lock rv to (my_v - tgt_v):mag. // relative velocity.

lock steering to tgt_v - my_v. wait 5. // ready for killing rv.
wait_for_closest_approach().
kill_relative_velocity().

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

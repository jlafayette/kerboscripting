parameter tgt_name.
parameter approach_range is 8000.

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
    clearscreen.
    print "New orbital period: " + ship:obt:period.
}

// GET WITHIN APPROACH RANGE
set tgt_ves to vessel(tgt_name).

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

    clearscreen.
    print "Waiting for rendezvous".
    set time_to_wait to new_period - (60 + burn_time/2).
    set wait_start_time to time:seconds.
    until 0 {
        print "Time remaining: " + round((wait_start_time + time_to_wait) - time:seconds, 2) + "      " at (5, 3).
        if (wait_start_time + time_to_wait) < time:seconds { break. }
        wait 1.
    }
    //wait new_period - (60 + burn_time/2).
    set warp to 0.

    clearscreen. wait 40.
    change_obt_period(tgt_ves:obt:period).
}

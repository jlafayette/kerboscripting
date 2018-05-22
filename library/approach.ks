parameter vessel_name.
parameter tgt_distance is 200.
parameter offset_v is V(0,0,0).
parameter agility is 1.

copypath("0:/f_remap.ks", "1:/"). runoncepath("1:/f_remap.ks").
//copypath("0:/f_raw_steering.ks", "1:/"). runoncepath("1:/f_raw_steering.ks").

set tgt_ves to vessel(vessel_name).


//Get the distance to the offset point
function get_target_distance {
    parameter tgt_vessel.
    return (ship:position - (tgt_vessel:position + offset_v)):mag.
}

// APPROACH FUNCTIONS
function burn_towards_target {
    clearscreen.
    print "Burning towards target..." at (0, 1).
    // til goal m/s determined by target distance.

//    steer_to_vector(tgt_ves:position + offset_v).
    lock steering to tgt_ves:position + offset_v.

    lock rv to (ship:velocity:orbit - tgt_ves:velocity:orbit):mag. // relative velocity.
    lock tgt_rv to remap(get_target_distance(tgt_ves), tgt_distance, 8000, 8*agility, 150*agility).
    lock tmax to remap(tgt_rv, 2, 50, .05, 1).
    lock tval to remap(rv, tgt_rv, 0, .05, tmax).
    lock throttle to tval.
    
    until 0 { // burn til moving towards the target.
        print "In Loop 1..." at (0, 2).
        set last_d to get_target_distance(tgt_ves).
        print "    rv: " + round(rv, 2) + "      " at (5, 3).
        print "tgt_rv: " + round(tgt_rv, 2) + "      " at (5, 4).
        print "  tval: " + round(tval, 2) + "      " at (5, 5).
        wait .1.
        if get_target_distance(tgt_ves) < last_d { break. }
    }
    until rv > tgt_rv { // burn til reaching target rv.
        print "In Loop 2..." at (0, 2).
        // as rv approaches tgt_rv, throttle approaches 0
        print "    rv: " + round(rv, 2) + "      " at (5, 3).
        print "tgt_rv: " + round(tgt_rv, 2) + "      " at (5, 4).
        print "  tval: " + round(tval, 2) + "      " at (5, 5).
        wait .01.
    }
    lock throttle to 0.
}

function wait_for_closest_approach {
    clearscreen.
    print "Waiting for closest_approach..." at (0, 1).
    until 0 {
        set last_d to get_target_distance(tgt_ves).
        wait .1.
        print "   diff per .1/s: " + round(last_d - get_target_distance(tgt_ves), 2) + "      " at (5, 3).
        print "tgt_ves:distance: " + round(tgt_ves:distance, 2) + "      " at (5, 4).
        print " offset distance: " + round(get_target_distance(tgt_ves), 2) + "      " at (5, 5).
        if get_target_distance(tgt_ves) > last_d { break. }
    }
}

function kill_relative_velocity {
    clearscreen.
    print "Killing relative velocity..." at (0, 1).
    // steering should already be set.
    lock rv to (ship:velocity:orbit - tgt_ves:velocity:orbit):mag.
    local prev_rv is rv.
    local lowest is rv.
    until rv < .3 {
//        if ((rv > (prev_rv + .02)) and (lowest < 1.5)) { break. }
        set tval to remap(rv, 0, 50, .05, 1).
        lock throttle to tval.
        print "relative velocity: " + round(rv, 2) + "      " at (5, 3).
        set prev_rv to rv.
        wait .01.
    }
    lock throttle to 0.
}

// SETUP FOR APPROACH
lock my_v to ship:velocity:orbit.
lock tgt_v to tgt_ves:velocity:orbit.
lock rv to (my_v - tgt_v):mag. // relative velocity.

local rv_vector is tgt_v - my_v.
//steer_to_vector(rv_vector).
lock steering to tgt_v - my_v.

wait_for_closest_approach().
kill_relative_velocity().

// APPROACH TARGET
until 0 {
    burn_towards_target().
    local rv_vector is tgt_v - my_v.
    //steer_to_vector(rv_vector).
    lock steering to tgt_v - my_v.
    wait_for_closest_approach().
    kill_relative_velocity().
    if get_target_distance(tgt_ves) < tgt_distance {
        break.
    }
    wait 1.
}
clearscreen.
unlock steering.
print "Successfully rendezvous with " + tgt_ves:name.
wait 3.

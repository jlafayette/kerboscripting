// Launch from a body with no atmosphere.

parameter target_altitude.
parameter target_direction is 90.

copy f_remap.ks from 0. run f_remap.
copy f_autostage.ks from 0. run once f_autostage.

// Set basic config
sas off.
rcs off.
lock throttle to 0.

// Run Modes Breakdown
// 1 --> on the launch pad
// 2 --> go straight up
// 3 --> main ascent mode
// 4 --> calculate circularize maneuver
// 0 --> terminates main loop
local runmode is 1.
local target_pitch is 90.
local init_up_distance is 25.
local nd_init is 0.
local tval is 0.
local lowest_eccentricity is 2.

until runmode = 0 {
    if runmode = 1 { // launch
        lock steering to up.
        from {local i is 3.} until i = 0 step {set i to i - 1.} do {
            print "..." + i.
            wait 1.
        }
        print "Blast off!!".
        wait 1.
        clearscreen.
        lock steering to heading (target_direction, 90).
        set runmode to 2.
    } else if runmode = 2 { //go straight up
        set tval to 1.
        if alt:radar > init_up_distance {
            set runmode to 3.
        }
    } else if runmode = 3 { // main ascent mode
        set target_pitch to remap(ship:obt:apoapsis, target_altitude, init_up_distance, 5, 90).
        lock steering to heading (target_direction, target_pitch).
        set tval to 1.
        if ship:obt:apoapsis < 0.99 * target_altitude {
            set tval to 1.
        } else {
            // Reduce engine thrust to near zero as apoapsis nears target,
            // this prevents overshooting the target.
            set tval to remap(ship:obt:apoapsis, 
                              target_altitude, .95*target_altitude, 
                              .01, 1).
           }
        if ship:obt:apoapsis > target_altitude {
            set runmode to 4.
        }
    } else if runmode = 4 { // calculate circularize maneuver
        set tval to 0.
        if nd_init = 0 {
            set nd to node(time:seconds + eta:apoapsis, 0, 0, 0).
            add nd.
            set nd_init to 1.
        }
        set nd:prograde to nd:prograde + 1.
        if nd:obt:eccentricity < lowest_eccentricity {
            set lowest_eccentricity to nd:obt:eccentricity.  
        } else {
            clearscreen.
            set runmode to 0.
        }
    }
    autostage(). // ascent staging logic
    lock throttle to tval.
    
    print "RUNMODE:      " + runmode + "      " at (5,5).
    print "ALTITUDE:     " + round(ship:altitude) + "      " at (5,6).
    print "APOAPSIS:     " + round(ship:obt:apoapsis) + "      " at (5,7).
    print "PERIAPSIS:    " + round(ship:obt:periapsis) + "      " at (5,8).
    print "ETA to AP:    " + round(eta:apoapsis) + "      " at (5,9).
    print "TARGET_PITCH: " + round(target_pitch,2) + "      " at (5,10).
    
    wait 0.01.
}

// EXECUTE MANEUVER NODE
copy exe_nextnode.ks from 0.
run exe_nextnode(1).
delete exe_nextnode.ks from 1.

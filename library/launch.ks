//handles launching and ends after clearing the atmosphere 70km

parameter target_altitude.
parameter init_up_distance is 200.
parameter target_direction is 90.

copypath("0:/f_autostage.ks", "1:/"). runoncepath("f_autostage.ks").

function get_tgt_speed {
    local y to ship:altitude.
    local a to 1330. local b to 1.00002. local c to -1120.   // 2551 | X2758
    return a*b^y + c.
}

function get_tgt_pitch {
    local y to target_altitude - ship:obt:apoapsis.
    local b to 3000. local m to 820.
    return min(90, (y + b)/m).
}

// Set basic config
sas off.
rcs off.
lock throttle to 0.
gear off.

// Run Modes Breakdown
// 1 --> on the launch pad
// 2 --> go straight up
// 3 --> main ascent mode
// 4 --> coast til almost out of atmosphere (height of 65000)
// 5 --> tweak apoapsis because air resistance will have lowered it during stage 4
// 6 --> handles cleanup before switching to 0 and ending launch script
// 0 --> terminates main loop
set runmode to 1.

set tgt_pitch to 90.
set pid_initialized to false.

until runmode = 0 {
    if runmode = 1 { // launch
        lock steering to up.
        set tval to 1.
        from {local i is 3.} until i = 0 step {set i to i - 1.} do {
            print "..." + i.
            wait 1.
        }
        print "Blast off!!".
        wait 1.
        clearscreen.
        stage.
        lock steering to heading (target_direction, tgt_pitch).
        set runmode to 2.
    }
    
    else if runmode = 2 { //go straight up
        if ship:altitude > init_up_distance {
            set runmode to 3.
        }
    }
    
    else if runmode = 3 { // main ascent mode
        set tgt_pitch to get_tgt_pitch().
        
        // PID loop for throttle until above main atmosphere
        if ship:obt:apoapsis < 0.99 * target_altitude {
            if pid_initialized = false {
                set pid to pidloop(.25, 0, 0, 0, 1).
                set pid_initialized to true.
            }
            set tgt_speed to get_tgt_speed().
            
            print "   tgt_speed: " + round(tgt_speed,2) +               "      " at (0, 17).
            print "    airspeed: " + round(ship:airspeed,2) +           "      " at (0, 18).
            print "     max acc: " + round(ship:maxthrust/ship:mass,2) +"      " at (0, 20).

            set pid:setpoint to tgt_speed.
            set tval to pid:update(time:seconds, ship:airspeed).
            print "tval (raw): " + round(tval,2) + "      " at (0, 7).
            set tval to max(0, min(1, tval)).
            print "      tval: " + round(tval,2) + "      " at (0, 8).
        }

        // Reduce engine thrust to near zero as apoapsis nears target,
        // this prevents overshooting the target.
        else {
            set tval to max(.05,
                (1.0 - (ship:obt:apoapsis-.99*target_altitude)/(.01*target_altitude))).
        } 
        if ship:obt:apoapsis > target_altitude {
            set runmode to 4.
        }
    }

    else if runmode = 4 { // coast til almost out of atmosphere
        lock steering to ship:prograde.
        set tval to 0.
        if ship:altitude > 65000 {
            set runmode to 5.
        }
    }
        
    else if runmode = 5 { // tweak apoapsis
        lock steering to ship:prograde.
        if ship:obt:apoapsis < target_altitude {
            set tval to .05.
            if eta:apoapsis < 45 { set tval to 1. }
        }
        else {
            set tval to 0.
            if ship:altitude > 70000 {
                set runmode to 6.
            }
        }
    }
    else if runmode = 6 { // end launch script
        set warp to 0.
        set tval to 0.
        unlock steering.
        set ship:control:pilotmainthrottle to 0.
        clearscreen.
        set runmode to 0.
    }
    autostage(). // ascent staging logic
    lock throttle to tval.
    
    print "   RUNMODE: " + runmode +                   "      " at (5,10).
    print "  ALTITUDE: " + round(ship:altitude) +      "      " at (5,11).
    print "  APOAPSIS: " + round(ship:obt:apoapsis) +  "      " at (5,12).
    print " PERIAPSIS: " + round(ship:obt:periapsis) + "      " at (5,13).
    print " ETA to AP: " + round(eta:apoapsis) +       "      " at (5,14).
    print "pitch_calc: " + round(get_tgt_pitch(),2) +  "      " at (5,15).
    print " tgt_pitch: " + round(tgt_pitch,2) +        "      " at (5,16).
    
    wait 0.01.
}

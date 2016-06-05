// cicularizes orbit based on specified burn point.
// requires f_pid
parameter tgt_direction.

set burn_point to "apoapsis". //apoapsis or periapsis (periapsis seems broken currently)

function eta_to_burn_point {
    if burn_point = "apoapsis" { return eta:apoapsis. }
    else { return eta:periapsis. }
}

function eta_to_opposite {
    if burn_point = "apoapsis" { return eta:periapsis. }
    else { return eta:apoapsis. }
}

function get_steering {
    parameter pitch_offset.
    if burn_point = "apoapsis" { return ship:prograde + R(0, pitch_offset, 0). }
    else { return ship:retrograde + R(0, -pitch_offset, 0). }
}


local runmode to 1.
local pid_initialized to false.
set prevThrust to 0.

// Initialized here because the staging logic needs to access
// the totalP and lastTime variables.
init_pid(0.85, 0.5, 0.1).
clearscreen.

until runmode = 0 { 
    
    if runmode = 1 { // time warp to burn point (apoapsis or periapsis)
        lock steering to heading(tgt_direction, 0).
        set tval to 0.
        
        if (eta:apoapsis > 20)  {
            if warp = 0 {
                wait 1.
                set warp to 3.
            }
        }
        else if eta:apoapsis < 20 {
            set warp to 0.
            lock steering to heading(tgt_direction, 0).
            if eta:apoapsis < 5 {
                set runmode to 2.
            }
        }
    }
    else if runmode = 2 { // burn to raise periapsis
        if pid_initialized = false {
            set pid_initialized to true.
            set startTime to time:seconds.
            set tgt_pitch to 0.
        }
        
        //first attempt at deadband.
        
        if (verticalspeed > 0.1) or (verticalspeed < -.1) {
            set tgt_pitch to pid_loop(0, verticalspeed).
            print " tgt_pitch (raw): " + round(tgt_pitch,2) + "      " at (5, 10).
            set tgt_pitch to max(0, min(tgt_pitch, 15)).
            print "       tgt_pitch: " + round(tgt_pitch,2) + "      " at (5, 11).
        }
        
        lock steering to heading(tgt_direction, tgt_pitch).
        
        set p to ship:obt:period.
        
        // keep thrusting at full if eccentricity is not close to zero.
        if ship:obt:eccentricity > 0.025 {
            set tval to 1.
        }
        
        // Thrust logic will shut off burn once the periapsis starts to
        // flip with the apoapsis.
        else if (eta:periapsis < (p/2 - p/4)) or (eta:periapsis > (p/2 + p/4)) {
            set tval to 0.
            unlock steering.
            set ship:control:pilotmainthrottle to 0.
            set runmode to 0.
        }
        
        // This gives a nice reduced thrust at the end to avoid
        // overshooting.
        else {
            set tval to max(.05, ship:obt:eccentricity*25).
        }
        
    }
    // staging logic
    if (maxthrust < (prevThrust - 10)) {
        lock throttle to 0.
        wait 1.
        stage.
        wait 1.
        until (maxthrust > 0) {
            stage.
            wait 1.
        }
        
        // to stop pid loop from freaking out
        //set lastP to 0.
        set lastTime to time:seconds. 
        set totalP to 0.
        
        set prevThrust to maxthrust.
    }
    set prevThrust to maxthrust.

    lock throttle to tval.
    
    print "         RUNMODE: " + runmode + "      " at (5,12).
    print "        ALTITUDE: " + round(ship:altitude,2) + "      " at (5,13).
    print "        APOAPSIS: " + round(ship:apoapsis,2) + "      " at (5,14).
    print "       PERIAPSIS: " + round(ship:periapsis,2) + "      " at (5,15).
    print " ETA to APOAPSIS: " + round(eta:apoapsis) + "      " at (5,16).
    print "ETA to PERIAPSIS: " + round(eta:periapsis) + "      " at (5,17).
    
    wait 0.05.
}
print "Done with circularizing orbit." at (0, 19).
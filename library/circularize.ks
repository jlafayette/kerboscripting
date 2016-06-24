// CIRCULARIZE ORBIT
// This is meant to be executed directly following the launch script. It is only
// designed to work for circularizing around kerbin after launching.
parameter tgt_direction.


copy f_remap.ks from 0. run f_remap.ks.
copy f_autostage.ks from 0. run once f_autostage.


local runmode is 1.
local tval is 0.

until runmode = 0 { 
    clearscreen.
    if runmode = 1 { // time warp to apoapsis
        lock steering to heading(tgt_direction, 0).
        set tval to 0.
        
        if (eta:apoapsis > 20)  {
            warpto(time:seconds + (eta:apoapsis - 20)).
        }
        lock steering to heading(tgt_direction, 0).
        
        if eta:apoapsis < 5 {
            set runmode to 2.
        }
    }
    else if runmode = 2 { // burn to raise periapsis
        
        set p to ship:obt:period.
        
        // drive pitch based on time to apoapsis
        if eta:apoapsis < p/2 {
            set ap_eta to eta:apoapsis.
        } else {
            set ap_eta to eta:apoapsis - p.
        }
        set tgt_pitch to remap(ap_eta, 5, -5, -5, 15).
        lock steering to heading(tgt_direction, tgt_pitch).
        
        print "eta:apoapsis: " + round(eta:apoapsis,2) at (5, 1).
        print "      ap_eta: " + round(ap_eta,2) at (5, 2).
        print "   tgt_pitch: " + round(tgt_pitch,2) at (5, 3).
        
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
    autostage().
    
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

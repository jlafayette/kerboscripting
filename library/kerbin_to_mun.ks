// Kerbin to the Mun
// Assumes ship is in a circular LKO as a starting point.

parameter mun_tgt_altitude is 50000.

// WAIT FOR TRANSFER
copy f_tgt.ks from 0. run f_tgt.ks.
copy f_remap.ks from 0. run f_remap.ks.
copy f_autostage.ks from 0. run once f_autostage.ks.


clearscreen.
print "Waiting for transfer...".
until close_enough(tgt_angle(Mun), 112, 2) {
    print "DIFF:  "+round(tgt_angle(Mun),2)+"    " at (5, 5).
    if close_enough(tgt_angle(Mun), 112, 5) {
        set warp to 2.
    }
    wait 1.
} set warp to 0.

// TRANSFER BURN - REFINE MUN PERIAPSIS
clearscreen.
print "Performing transfer burn to Mun...".
lock steering to ship:prograde.
wait 10.

set prev_thrust to 0.
until 0 {
    if not ship:orbit:hasnextpatch {
        set tval to remap(ship:obt:apoapsis, 12000000, 8000000, .2, 1).
    } else {
        set tval to .025.
        if close_enough(ship:orbit:nextpatch:periapsis, mun_tgt_altitude, 1000) { 
            break. 
        } else if ship:orbit:nextpatch:periapsis < mun_tgt_altitude {
            break.
        }
    }
    autostage().
    lock throttle to tval.
    wait 0.01.
} lock throttle to 0. unlock steering.

clearscreen.
print "Waiting to enter Mun SOI...".
wait until ship:body = Mun. set warp to 0. wait 10.

// WAIT FOR MUN PERIAPSIS
clearscreen.
print "Waiting for periapsis...".
lights off.
until 0 {
    if lights {
        warpto(time:seconds + (eta:periapsis - 60)).
    }
    if eta:periapsis < 60 { break. }
    wait 1.
} set warp to 0.

// CIRCULARIZE AROUND MUN
lock steering to ship:retrograde.
wait until eta:periapsis < 10.
print "Starting circularization burn...".
until 0 {
    if ship:obt:eccentricity > 0.1 {
        set tval to 1.
    } else {
        set tval to max(.05, ship:obt:eccentricity*10).
        set p to ship:obt:period.
        if (eta:apoapsis < (p/2 - p/4)) or (eta:apoapsis > (p/2 + p/4)) {
            break.   
        }
    }
    autostage().
    lock throttle to tval.
    wait 0.01.
} lock throttle to 0. unlock steering.

clearscreen.
print "Orbit achieved!". wait 5.
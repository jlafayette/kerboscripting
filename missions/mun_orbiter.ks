// MISSION: Orbit the Mun

set ship:control:pilotmainthrottle to 0. wait 1.

set tgt_direction to 90.

// LAUNCH
clearscreen.
copypath("0:/f_autostage.ks", "1:/"). runoncepath("f_autostage.ks").
copypath("0:/launch.ks", "1:/").
runpath("launch.ks", 75000, 200, tgt_direction).
deletepath("1:/launch.ks").

// DEPLOY SOLAR PANELS
panels on.

// DEPLOY ANTENNA FOR COMMUNICATION
copypath("0:/extend_antenna.ks", "1:/").
runpath("extend_antenna.ks", "Communotron 16").
deletepath("1:/extend_antenna.ks").

// CIRCULARIZE
copypath("0:/circularize.ks", "1:/").
runpath("circularize.ks", tgt_direction).
wait 1.
clearscreen.
deletepath("1:/circularize.ks").


// WAIT FOR TRANSFER
copypath("0:/f_tgt.ks", "1:/"). runpath("f_tgt.ks").
copypath("0:/f_remap.ks", "1:/"). runpath("f_remap.ks").

clearscreen.
print "Waiting for transfer...".
until close_enough(tgt_angle(Mun), 112, 2) {
    print "DIFF:  "+round(tgt_angle(Mun),2)+"    " at (5, 5).
    wait 1.
} set warp to 0.

// TRANSFER BURN - REFINE MUN PERIAPSIS
// requires prev_thrust to be defined previously.
set mun_tgt_altitude to 50000.

clearscreen.
print "Performing transfer burn to Mun...".
lock steering to ship:prograde.
wait 15.

set prev_thrust to 0.
until 0 {
    if not ship:orbit:hasnextpatch {
        set tval to remap(ship:obt:apoapsis, 12000000, 8000000, .2, 1).
    } else {
        set tval to .05.
        if close_enough(ship:orbit:nextpatch:periapsis, mun_tgt_altitude, 5000) { 
            break. 
        }
    }
    autostage().
    lock throttle to tval.
    wait 0.01.
} lock throttle to 0. unlock steering.

// WAIT
clearscreen.
print "Waiting to enter Mun SOI...".
wait until ship:body = Mun. wait 10.

// CIRCULARIZE AROUND MUN
clearscreen.
print "Waiting for periapsis...".
wait until eta:periapsis < 60.
set warp to 0.
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

// WAIT FOR TRANSFER
// counterclockwise, exit on leading edge of Mun (after going around far side)
// wait for farthest distance from Kerbin
// wait for 1/4 obt period.
clearscreen.
print "Waiting until moving away from Kerbin...".
until 0 {
    set previous_d to Kerbin:distance.
    wait 5.
    if Kerbin:distance > previous_d { break. }
}
clearscreen.
print "Waiting until farthest point of orbit...".
until 0 {
    set previous_d to Kerbin:distance.
    wait 5.
    if Kerbin:distance < previous_d { break. }
}
clearscreen.
print "Waiting for burn point...".
wait ship:obt:period/4.
set warp to 0.

// TRANSFER BURN - REFINE KERBIN PERIAPSIS (38 km)
// burn til next patch
// wait til SOI changes to Kerbin
// wait 1/16 orbit period
// burn retrograde to lower kerbin periapsis to 38 km
lock steering to ship:prograde. wait 10.
until ship:orbit:hasnextpatch {
    autostage().
    lock throttle to 1.
    wait 0.01.
} lock throttle to 0. unlock steering.
wait until ship:body = Kerbin.
wait ship:obt:period/16. set warp to 0. wait 10.

lock steering to retrograde. wait 10.
until ship:obt:periapsis < 38000 {
    set tval to remap(ship:obt:periapsis, 38000, 250000, .05, 1).
    autostage().
    lock throttle to tval.
    wait 0.01.
} lock throttle to 0. unlock steering.

// WAIT
wait until ship:altitude < 250000.
set warp to 2.
wait until ship:altitude < 100000.
set warp to 0. wait 5.

// BURN AT PERIAPSIS TIL PERIAPSIS < 30km or out of fuel
lock steering to ship:retrograde. wait 5.
until 0 {
    if ship:obt:periapsis < 30000 { break. }
    if ship:liquidfuel < 1 { break. }
    lock throttle to 1.
    wait .01.
} lock throttle to 0. unlock steering.


// STAGE TIL PARACHUTES - REENTRY
clearscreen.
print "Preparing for re-entry.".
lock steering to ship:prograde. wait 4.
stage. wait 2.

print "Added drag chute trigger...".
when ((ship:airspeed < 420) and (alt:radar < 2500)) then {
    print "Deploying drag chutes.".
    stage.
}

print "Added parachute trigger.".
when ((ship:airspeed < 250) and (alt:radar < 1200)) then {
    print "Deploying parachutes.".
    stage.
}

until ship:airspeed < .5 {
    print "ALT:RADAR: " + round(alt:radar, 2) + "    " at (5, 5).
    lock steering to ship:srfretrograde.
    wait 0.1.
}
unlock steering.
clearscreen.
print "Finished mission script.".

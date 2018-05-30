// MISSION: Mun Flyby
// This doesn't require patched conics, so it is suitable for an early science mission.

set ship:control:pilotmainthrottle to 0. wait 1.

set tgt_direction to 90.

// LAUNCH
clearscreen.
copypath("0:/f_autostage.ks", "1:/"). runoncepath("f_autostage.ks").
copypath("0:/launch.ks", "1:/").
runpath("launch.ks", 75000, tgt_direction).
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
} set warp to 0. wait until kuniverse:timewarp:issettled.

// TRANSFER BURN
clearscreen.
lock steering to ship:prograde.
from {local i is 15.} until i = 0 step {set i to i - 1.} do {
    print "Tranfer burn in " + i.
    wait 1.
}
set orig_mun_diff to body("Mun"):apoapsis - ship:obt:apoapsis.
until 0 {
    local diff to body("Mun"):apoapsis - ship:obt:apoapsis.

    // If 0, the ship might be on collision course with the Mun
    local cutoff is 0. // 100_000
    
    if diff < cutoff {
        break.
    }
    set tval to 1.
    if diff < 4_000_000 {
        set tval to remap(diff, cutoff, 4_000_000, .05, 1). // input inputLow inputHigh outputLow outputHigh
    }
    autostage().
    lock throttle to tval.
    wait 0.01.
}
set tval to 0.
unlock steering.

// WAIT UNTIL MUN SOI
clearscreen.
print "Waiting to enter Mun SOI...".
until 0 {
    if ship:body = Mun { break. }
    wait 10.
}
set warp to 0.
wait until kuniverse:timewarp:issettled.
clearscreen.
print "You are now flying by the Mun!". wait 3.

// FIX COLLISION COURSE
if ship:obt:periapsis < 10000 {
    print "Uh oh! You are on a collision course with the Mun.".
    print "Calculating alternate trajectory, please stand by...".
    lock normalV to vcrs(ship:velocity:orbit, -body:position).
    lock radialOutV to vcrs(ship:velocity:orbit, -normalV).
    lock steering to radialOutV. wait 5.
    set tval to 1.
    until 0 {
        if ship:obt:periapsis > 10000 {
            break.
        }
        wait 0.01.
    }
    set tval to 0.
    unlock steering.
    wait 1.
    clearscreen.
    print "Course correction completed.".
}

// WAIT UNTIL KERBIN SOI
until 0 {
    if ship:body = Kerbin { break. }
}
set warp to 0. wait until kuniverse:timewarp:issettled.

// WAIT FOR APOAPSIS
clearscreen. print "Waiting for apoapsis...".
warpto(time:seconds + eta:apoapsis).
set warp to 0. wait until kuniverse:timewarp:issettled.

// TRANSFER BURN - REFINE KERBIN PERIAPSIS (35 km)
// burn retrograde to lower kerbin periapsis to 35 km
clearscreen. print "Burning to lower Kerbin periapsis.".
lock steering to retrograde. wait 10.
until ship:obt:periapsis < 36000 {
    set tval to remap(ship:obt:periapsis, 36000, 250000, .05, 1).
    autostage().
    lock throttle to tval.
    wait 0.01.
} set tval to 0. lock throttle to 0. unlock steering.

// WAIT
clearscreen. print "Returning to Kerbin.".
wait until ship:altitude < 250000.
set warp to 2.
wait until ship:altitude < 100000.
set warp to 0. wait until kuniverse:timewarp:issettled.

// BURN TIL PERIAPSIS < 30km or out of fuel
clearscreen. print "Burning off extra fuel.".
lock steering to ship:retrograde. wait 5.
until 0 {
    if ship:obt:periapsis < 30000 { break. }
    if ship:liquidfuel < 1 { break. }
    lock throttle to 1.
    wait .01.
} lock throttle to 0. unlock steering.

// REENTRY
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

// Mission: Orbit around Minmus and return
// Requires manual maneuver node creation for rendezvous with Minmus.
// TODO: Move repeated code from Mun and Minmus missions into library.
// TODO: Create time warp library.

// PRE-LAUNCH => wait til launch is roughly at ascending node of Minmus orbit
print "Waiting for manual launch trigger.".
print "Set RCS to on when ready...".
rcs off.
wait until rcs.

// LAUNCH
clearscreen.
copypath("0:/f_remap.ks", "1:/"). runpath("f_remap.ks").
copypath("0:/f_autostage.ks", "1:/"). runoncepath("f_autostage.ks").
copypath("0:/launch.ks", "1:/").
set tgt_direction to 84.
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


// REQUIRES MANUAL MANEUVER NODE SETUP
// This section runs maneuvers nodes set up by the player.
// DANGER! If this runs without a maneuver node, it will error and stop the 
// mission script.
copypath("0:/exe_nextnode.ks", "1:/").
rcs off.
lights off.
until 0 {
    if rcs {
        runpath("exe_nextnode.ks").
        rcs off.
    }
    if lights {
        break.
    }
    wait 2.
}
deletepath("1:/exe_nextnode.ks").

// Must be headed for Minmus SOI for the rest of the script to work.

// WAIT
clearscreen.
print "Waiting to enter Minmus SOI...".
wait until ship:body = Minmus. wait 30.


// CIRCULARIZE AROUND MINMUS
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


// WAIT FOR RETURN TRANSFER POINT 
// This has only been tested for Mun in orbit with 0 degrees inclination.
// May not work depending on current orbit.
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
wait ship:obt:period/4 - 30.
set warp to 0. wait 30.

// ESCAPE MINMUS SOI
clearscreen.
print "Performing transfer burn...".
lock steering to ship:prograde. wait 10.
until ship:orbit:hasnextpatch {
    autostage().
    lock throttle to 1.
    wait 0.01.
} lock throttle to 0. unlock steering.
clearscreen.
print "Waiting for escape for Minmus SOI...".
wait until ship:body = Kerbin. set warp to 0. wait 30.


// WAIT
clearscreen.
print "Waiting for burn point...".
wait ship:obt:period/32. set warp to 0. wait 60.


// BURN TO LOWER KERBIN PERIAPSIS
// TODO: Check for Mun encounters.
clearscreen.
print "Burning to lower periapsis...".
lock steering to retrograde. wait 10.
until ship:obt:periapsis < 38000 {
    set tval to remap(ship:obt:periapsis, 38000, 250000, .05, 1).
    autostage().
    lock throttle to tval.
    wait 0.01.
} lock throttle to 0. unlock steering.


// WAIT FOR KERBIN APPROACH
// TODO: Check body to make sure that this doesn't trigger on a Mun encounter.
clearscreen.
print "Waiting for Kerbin encounter...".
wait until ship:altitude < 250000.
set warp to 2.
wait until ship:altitude < 100000.
set warp to 0. wait 5.


// BURN OFF REMAINING FUEL AND STAGE
clearscreen.
print "Burrning off remaining fuel...".
lock steering to ship:retrograde. wait 5.
until 0 {
    if ship:obt:periapsis < 30000 { break. }
    if ship:liquidfuel < 1 { break. }
    lock throttle to 1.
    wait .01.
} lock throttle to 0. unlock steering.
clearscreen.
print "Preparing for re-entry.".
lock steering to ship:prograde. wait 8.
stage. wait 5.


// REENTRY
print "Added parachute trigger.".
when ((ship:airspeed < 250) and (alt:radar < 1500)) then {
    print "Deploying parachutes.".
    stage.
}
until ship:airspeed < .5 {
    print "ALT:RADAR: " + round(alt:radar, 2) + "    " at (5, 5).
    lock steering to ship:srfretrograde.
    wait 0.5.
}
unlock steering.
clearscreen.
print "Finished mission script.".

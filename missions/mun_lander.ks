// Mission: Land on the Mun!
// DV requirements => 6900
// If staging during powered landing, must set a stage max thrust multiplyer
// as second parameter for the powered_landing script.


// LAUNCH
clearscreen.
copypath("0:/launch.ks", "1:/").
set tgt_direction to 90.
runpath("launch.ks", 80000, 200, tgt_direction).
deletepath("1:/launch.ks").

// DEPLOY SOLAR PANELS
panels on.

// CIRCULARIZE
copypath("0:/circularize.ks", "1:/").
runpath("circularize.ks", tgt_direction).
wait 1.
clearscreen.
deletepath("1:/circularize.ks").

// TO THE MUN!
clearscreen.
copypath("0:/kerbin_to_mun.ks", "1:/").
runpath("kerbin_to_mun.ks", 25000).
deletepath("1:/kerbin_to_mun.ks").

// WAIT FOR DEORBIT SIGNAL
print "Turn on the lights to preview Mun deorbit trajectory.".
lights off.
until 0 {
    if lights { break. }
    wait 1.
}

// CREATE DEORBIT MANEUVER
set nd to node(time:seconds + 120, 0, 0, 0).
add nd.
until 0 {
    set nd:prograde to nd:prograde - 1.
    if nd:obt:periapsis < -ship:body:radius/4 { break. }
    wait .01.
}

// UPDATE MANEUVER AND WAIT FOR CONFIRM SIGNAL.
clearscreen.
print "Turn on RCS to confirm Mun deorbit.".
rcs off.
until 0 {
    if rcs { rcs off. break. }
    set nd:eta to 120.
    wait 0.5.
}
copypath("0:/exe_nextnode.ks", "1:/").
runpath("exe_nextnode.ks", 1).
deletepath("1:/exe_nextnode.ks").

// POWERED LANDING
copypath("0:/powered_landing.ks", "1:/").
runpath("powered_landing.ks", 100, .47).
deletepath("1:/powered_landing.ks").

// WAIT FOR TAKEOFF SIGNAL
print "Engage RCS to takeoff.".
rcs off.
until 0 {
    if rcs { break. }
    wait 1.
}

// TAKEOFF AND CIRCULARIZE
clearscreen.
copypath("0:/launch_noat.ks", "1:/").
runpath("launch_noat.ks", 25000).
deletepath("1:/launch_noat.ks").

// BACK TO KERBIN
clearscreen.
copypath("0:/mun_to_kerbin.ks", "1:/").
runpath("mun_to_kerbin.ks", 38000).
deletepath("1:/mun_to_kerbin.ks").

// WAIT
wait until ship:altitude < 300000.
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

// RE-ENTRY
when ship:altitude < 71000 then { panels off. }
print "Added parachute trigger.".
when ((ship:airspeed < 250) and (alt:radar < 2000)) then {
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

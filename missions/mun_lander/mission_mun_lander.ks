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
print "Press the large red button to deorbit for Mun landing.".
abort off.
until 0 {
    if abort { break. }
    wait 1.
}

// DEORBIT
copypath("0:/f_autostage.ks", "1:/"). runpath("f_autostage.ks").
lock steering to ship:retrograde. wait 10.
until ship:obt:periapsis < -Mun:radius/4 {
    lock throttle to 1.
    autostage().
    wait .01.
} unlock steering. lock throttle to 0. wait 1.

// // WAIT TIL COMING BACK DOWN
// print "Waiting til ship is traveling down.".
// until ship:verticalspeed < 0 {
    // print "verticalspeed: " + round(ship:verticalspeed,2) + "     " at (5, 5).
// }

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

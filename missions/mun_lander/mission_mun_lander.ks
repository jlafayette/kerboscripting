// Mission: Land on the Mun!
// DV requirements
// 3200, 860, 310, 580, 580, 310, 440 => 6280
// stage 1: 2600-3000                                                   2800
// stage 2: RE + 860 + 310 + 200-400 (stage during powered landing)     1870
// stage 3: RE(580) + 580 + 310 + 440                                   1610
// stage 4: 0

// LAUNCH
clearscreen.
copy launch.ks from 0.
set tgt_direction to 90.
run launch(80000, 200, tgt_direction).
delete launch.ks from 1.
delete f_pid.ks from 1.

// DEPLOY SOLAR PANELS
panels on.

// CIRCULARIZE
copy circularize.ks from 0.
run circularize(tgt_direction).
wait 1.
clearscreen.
delete circularize.ks from 1.

// TO THE MUN!
clearscreen.
copy kerbin_to_mun.ks from 0.
run kerbin_to_mun(25000).
delete kerbin_to_mun.ks from 1.

// WAIT FOR DEORBIT SIGNAL
print "Press the large red button to deorbit for Mun landing.".
abort off.
until 0 {
    if abort { break. }
    wait 1.
}

// DEORBIT
copy f_autostage.ks from 0. run f_autostage.ks.
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
copy powered_landing.ks from 0.
run powered_landing(100, .47).
delete powered_landing.ks from 1.

// WAIT FOR TAKEOFF SIGNAL
print "Engage RCS to takeoff.".
rcs off.
until 0 {
    if rcs { break. }
    wait 1.
}


// TAKEOFF AND CIRCULARIZE
clearscreen.
copy launch_noat.ks from 0.
run launch_noat(25000).
delete launch_noat.ks from 1.


// BACK TO KERBIN
clearscreen.
copy mun_to_kerbin.ks from 0.
run mun_to_kerbin(38000).
delete mun_to_kerbin.ks from 1.


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



// Mission: Space Bus Tour LKO and Mun!


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


// IN ORBIT! 
print "You are now in space.".


// TO THE MUN!
print "Next stop Mun!".
copy kerbin_to_mun.ks from 0.
run kerbin_to_mun(50000).
delete kerbin_to_mun.ks from 1.


print "Press the large red button to return to Kerbin.".
abort off.
until 0 {
    if abort { break. }
    wait 1.
}

clearscreen.
print "You are now returning to Kerbin...".
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
    wait 0.5.
}
unlock steering.
clearscreen.
print "Finished mission script.".
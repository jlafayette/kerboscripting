// Mission: Space Bus Tour LKO


// LAUNCH
clearscreen.
copy f_pid.ks from 0. run f_pid.
copy f_remap.ks from 0. run f_remap.ks.
copy f_autostage from 0. run once f_autostage.
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


// IN ORBIT! WAIT FOR ABORT TO DEORBIT
print "You are now in space.".
print "Press the large red button to return to Kerbin.".
abort off.
until 0 {
    if abort { break. }
    wait 1.
}
clearscreen.
print "You are now returning to Kerbin...".
copy deorbit.ks from 0.
run deorbit.ks.
delete deorbit.ks from 1.


// STAGE
clearscreen.
print "Preparing for re-entry.".
lock steering to ship:prograde. wait 8.
stage. wait 5.


// REENTRY
when ship:altitude < 71000 then { panels off. }
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
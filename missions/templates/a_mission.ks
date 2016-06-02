// Mission template
// Launches and circularizes orbit around Kerbin.
// Has section for deorbiting and re-entry.

// LAUNCH
clearscreen.
copy f_pid.ks from 0. run f_pid.
copy launch.ks from 0.

set tgt_direction to 90.
run launch(75000, 200, tgt_direction).
delete launch.ks from 1.

// DEPLOY SOLAR PANELS
panels on.

// DEPLOY ANTENNA FOR COMMUNICATION
set antenna_list to ship:partsdubbed("Communotron 16").
if antenna_list:length > 0 {
    set antenna to antenna_list[0].
    antenna:getmodule("ModuleAnimateGeneric"):doevent("extend").
    wait 1.
}

// CIRCULARIZE
copy circularize.ks from 0.
run circularize(tgt_direction).
wait 1.
clearscreen.
delete f_pid.ks from 1.
delete circularize.ks from 1.

// DO MISSION HERE



// DEORBIT
// This part assumes the ship is on the last stage before parachutes.
// Also assumes that ship is orbiting Kerbin and has enough fuel to lower 
// periapsis to 30000.
clearscreen.
print "Deorbiting...".
wait 10.
copy deorbit from 0.
run deorbit.
delete deorbit from 1.

// REENTRY
clearscreen.
print "Preparing for re-entry.".
lock steering to ship:prograde. wait 8.
stage. wait 5.

print "Added parachute trigger.".
when ((ship:airspeed < 250) and (alt:radar < 1500)) then {
    print "Deploying parachutes.".
    stage.
}
until alt:radar < 500 {
    print "ALT:RADAR: " + round(alt:radar, 2) + "    " at (5, 5).
    lock steering to ship:srfretrograde.
    wait 0.1.
}
unlock steering.
clearscreen.
print "Finished mission script.".
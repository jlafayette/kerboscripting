// Mission: TEMPLATE
parameter autowarp is true.

// LAUNCH
clearscreen.
copypath("0:/launch.ks", "1:/").
set tgt_direction to 90.
runpath("launch.ks", 80000, 200, tgt_direction).
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
deletepath("1:/circularize.ks").
wait 1. clearscreen.

// IN ORBIT!
print "You are now in space.".

// DO MISSION HERE



// DEORBIT
// This part assumes the ship is on the last stage before parachutes.
// Also assumes that ship is orbiting Kerbin and has enough fuel to lower 
// periapsis to 30000.
clearscreen.
print "Deorbiting...".
wait 10.
copypath("0:/deorbit.ks", "1:/").
runpath("deorbit.ks").
deletepath("1:/deorbit.ks").

// REENTRY
clearscreen.
print "Preparing for re-entry.".
lock steering to ship:north. wait 8.
stage. wait 5.

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

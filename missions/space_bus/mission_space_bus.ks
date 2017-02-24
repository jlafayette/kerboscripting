// Mission: Space Bus Tour LKO and Mun!

function mun_and_back {
    print "Next stop Mun!".
    copypath("0:/kerbin_to_mun.ks", "1:/").
    runpath("kerbin_to_mun.ks", 50000).
    deletepath("1:/kerbin_to_mun.ks").


    print "Press the large red button to return to Kerbin.".
    abort off.
    until 0 {
        if abort { break. }
        wait 1.
    }

    clearscreen.
    print "You are now returning to Kerbin...".
    copypath("0:/mun_to_kerbin.ks", "1:/").
    runpath("mun_to_kerbin.ks", 38000).
    deletepath("1:/mun_to_kerbin.ks").

    // WAIT
    wait until ship:altitude < 300000.
    set warp to 2.
    wait until ship:altitude < 100000.
    set warp to 0. wait 5.
}

// LAUNCH
clearscreen.
copypath("0:/launch.ks", "1:/").
set tgt_direction to 90.
runpath("launch.ks", 80000, 200, tgt_direction).
deletepath("1:/launch.ks").
deletepath("1:/f_pid.ks").

// DEPLOY SOLAR PANELS
panels on.

// CIRCULARIZE
copypath("0:/circularize.ks", "1:/").
runpath("circularize.ks", tgt_direction).
wait 1.
clearscreen.
deletepath("1:/circularize.ks").

// IN ORBIT! 
print "You are now in space.".

// TO THE MUN?
print "Press the large red button to return to Kerbin or turn on the lights to go to the Mun!".
abort off.
lights off.
until 0 {
    if abort { break. }
    if lights { mun_and_back(). break. }
    wait 1.
}

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

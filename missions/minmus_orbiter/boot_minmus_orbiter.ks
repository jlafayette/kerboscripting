clearscreen.
print "Booting up...".

set ship:control:pilotmainthrottle to 0. wait 1.

if ship:altitude < 500 and ship:obt:body = Kerbin and ship:airspeed < 1 {
    print "Initializing mission sequence...". wait 1.
    copypath("0:/mission_minmus_orbiter.ks", "1:/").
    runpath("mission_minmus_orbiter.ks").
    deletepath("1:/mission_minmus_orbiter.ks").
}
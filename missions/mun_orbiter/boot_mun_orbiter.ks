clearscreen.
print "Booting up...".

set ship:control:pilotmainthrottle to 0. wait 1.

if ship:altitude < 500 and ship:obt:body = Kerbin and ship:airspeed < 1 {
    print "Initializing mission sequence...". wait 1.
    copypath("0:/mission_mun_orbiter.ks", "1:/").
    runpath("mission_mun_orbiter.ks").
    deletepath("1:/mission_mun_orbiter.ks").
}

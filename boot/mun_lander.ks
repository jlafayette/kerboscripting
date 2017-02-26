clearscreen.
print "Booting up...".

set ship:control:pilotmainthrottle to 0. wait 1.

if ship:altitude < 500 and ship:obt:body = Kerbin and ship:airspeed < 1 {
    print "Initializing mission sequence...". wait 1.
    copypath("0:/missions/mun_lander.ks", "1:/").
    runpath("mun_lander.ks").
    deletepath("1:/mun_lander.ks").
}


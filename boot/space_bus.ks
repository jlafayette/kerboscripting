clearscreen.
print "Booting up...".

set ship:control:pilotmainthrottle to 0. wait 1.

if ship:altitude < 500 and ship:obt:body = Kerbin and ship:airspeed < 1 {
    print "Initializing mission sequence...". wait 1.
    copypath("0:/missions/space_bus.ks", "1:/").
    runpath("1:/space_bus.ks").
    deletepath("1:/space_bus.ks").
}


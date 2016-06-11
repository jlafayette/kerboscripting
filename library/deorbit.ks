lock steering to retrograde.
wait 10.

until ship:periapsis < 30000 {
    lock throttle to 1.
    wait 0.01.
}
unlock throttle. unlock steering.
set throttle to 0.
set ship:control:pilotmainthrottle to 0.
print "Ship is successfully de-orbited...".




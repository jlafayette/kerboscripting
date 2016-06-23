// Execute Next Manuver Node

// Adapted from tutorial script by the kOS Team.
// Link: http://ksp-kos.github.io/KOS_DOC/tutorials/exenode.html
// Copyright (c) 2013-2016 kOS Team
// License (GNU) http://ksp-kos.github.io/KOS_DOC/copyright.html

parameter autowarp is 0.


copy f_remap.ks from 0. run f_remap.ks.
copy f_autostage from 0. run once f_autostage.


set nd to nextnode.
print "Node in: " + round(nd:eta) + ", DeltaV: " + round(nd:deltav:mag).

set max_acc to ship:maxthrust/ship:mass.
set burn_duration to nd:deltav:mag/max_acc.
print "Crude Estimated burn duration: " + round(burn_duration) + "s".

print "Waiting for maneuver node.".
if autowarp {
    warpto(time:seconds + (nd:eta - (burn_duration/2 + 60))). 
}
wait until nd:eta <= (burn_duration/2 + 60).

set np to nd:deltav. //points to node, ignoring roll direction.
lock steering to np.

print "Waiting for alignment.".
wait until abs(np:direction:pitch - facing:pitch) < 0.3 and 
           abs(np:direction:yaw - facing:yaw) < 0.3.

print "Alignment completed, waiting for burn time.".
wait until nd:eta <= (burn_duration/2).

set tval to 0.
lock steering to nd:deltav.
set dv0 to nd:deltav. //initial deltav
until 0 {
    set tval to remap(nd:deltav:mag, 1, 50, .05, 1).

    // Cut the throttle as soon as nd:deltav and initial deltav start facing 
    // opposite directions
    if vdot(dv0, nd:deltav) < 0 {
        break.
    }
    autostage().
    lock throttle to tval.
    wait 0.01.
} lock throttle to 0. unlock throttle. unlock steering. wait 1.
print "End burn, remaining dv " + round(nd:deltav:mag,1) + 
      "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).

remove nd.
set ship:control:pilotmainthrottle to 0.
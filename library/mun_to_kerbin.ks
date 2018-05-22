// Escape Mun and fall back to Kerbin

parameter kerbin_tgt_periapsis.
parameter autowarp is true.

// FUNCTIONS
function periapsis_at_time {
    parameter nd, offset.    
    set nd:eta to offset.
    wait 0.01.
    if not nd:obt:hasnextpatch {
        return 2^64.
    } else {
        return nd:obt:nextpatch:periapsis.
    }
}

// CREATE TRANSFER MANEUVER / DETERMINE MANEUVER DELTAV
set nd to node(time:seconds + eta:periapsis, 0, 0, 10).
add nd.
until 0 {
    set nd:prograde to nd:prograde + 1.
    if nd:obt:hasnextpatch {
        set nd:prograde to nd:prograde + 10. // buffer
        break.
    }
}

// DETERMINE MANEUVER ETA
copypath("0:/f_bisection_search.ks", "1:/").
runpath("1:/f_bisection_search.ks").

// This sets the eta on maneuver node during test function.
bisection_search(0, ship:obt:period,           // min, max
                1000, 100,                     // tolerence, max iterations
                periapsis_at_time@:bind(nd)).  // test function
deletepath("1:/f_bisection_search.ks").

if nd:eta < 180 {
    set nd:eta to nd:eta + ship:obt:period.
}

// EXECUTE MANEUVER NODE
copypath("0:/exe_nextnode.ks", "1:/").
runpath("exe_nextnode.ks", 1).

clearscreen.
print "Waiting to leave Mun SOI...".
if autowarp {
    warpto(time:seconds + ship:orbit:nextpatcheta).
}
wait until ship:body = Kerbin. set warp to 0. wait 10.


// CREATE MANEUVER NODE TO LOWER KERBIN PERIAPSIS
set nd to node(time:seconds + 180, 0, 0, 0).
add nd.
until 0 {
    if nd:obt:periapsis > kerbin_tgt_periapsis {
        set nd:prograde to nd:prograde - 1.
        if nd:obt:periapsis < kerbin_tgt_periapsis { break. }
    } else {
        set nd:prograde to nd:prograde + 1.
        if nd:obt:periapsis > kerbin_tgt_periapsis { break. }
    }
}

// EXECUTE MANEUVER NODE
runpath("exe_nextnode.ks", 1).
deletepath("1:/exe_nextnode.ks").

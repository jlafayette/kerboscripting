// Kerbin to the Mun
// Assumes ship is in a circular LKO as a starting point.

parameter mun_tgt_altitude is 50000.
parameter autowarp is true.

// CREATE TRANSFER MANEUVER USING CLIMB LIB
copypath("0:/hill_climb.ks", "1:/"). runpath("hill_climb.ks").

local tgt is Mun.
local seekmode is 0.
local result_node is lexicon().
until seekmode = -1 {
    if seekmode = 0 {
        // with dv of 860, rough period finder
        local offset is ship:obt:period/24.
        local init_eta is 1000.
        until 0 {
            set result_node to climb_loop(tgt, -Mun:soiradius, eval_closest@, 
                                          list(init_eta,0,0,860), list("eta"), 
                                          ship:obt:period/10, 6).
            // switch to 0.
            // log "exit code: " + result_node["exit_code"] to "climb_data.txt".
            // switch to 1.
            if result_node["exit_code"] = 0 {
                break.
            }
            set init_eta to init_eta + offset.
            wait 0.01.
        }
        set seekmode to 1.
    } else if seekmode = 1 {
        // refine period + dv
        local init_list is init_list_from_node(result_node). // will only populate eta
        set init_list[3] to 860.
        set result_node to climb_loop(tgt, -tgt:radius, eval_closest@,
                                      init_list, list("eta", "prograde"), 
                                      5, 5).
        set seekmode to 2.
    } else if seekmode = 2 {
        // correct orbit altitude.
        local step_increment is 2.
        local goal is -2000.
        local init_list is init_list_from_node(result_node). // eta, prograde
        until 0 {
            set init_list to init_list_from_node(result_node).
            set result_node to climb_loop(tgt, goal, eval_tgt_altitude@:bind(mun_tgt_altitude),
                                          init_list, list("eta", "prograde"),
                                          step_increment, 20).
            if step_increment > .05 {
                set step_increment to step_increment/2.
            }
            if goal < -500 {
                set goal to goal/2.
            }
            // switch to 0.
            // log "goal: " + goal to "climb_data.txt".
            // log "eval: " + result_node["eval"] to "climb_data.txt".
            // log "step: " + step_increment to "climb_data.txt".
            // log "exit_code: " + result_node["exit_code"] to "climb_data.txt".
            // switch to 1.
            
            if result_node["eval"] > -500 {
                break. 
            }
            wait .01.
        }
        set seekmode to -1.
    }
    wait .01.
}
set nd to node(time:seconds + 100, 0, 0, 0).
add nd.
apply_data_to_maneuver_node(result_node["data"], nd).
print "Final data: " + result_node["data"].
print "Done".
deletepath("1:/hill_climb.ks").


// EXECUTE MANEUVER NODE
copypath("0:/exe_nextnode.ks", "1:/").
runpath("exe_nextnode.ks", 1).
deletepath("1:/exe_nextnode.ks").


clearscreen.
print "Waiting to enter Mun SOI... turn on lights to auto-warp".
lights off.
until 0 {
    if ship:body = Mun { break. }
    if lights or autowarp { warpto(time:seconds + (ship:orbit:nextpatcheta)). break. }
    wait 10.
} wait until ship:body = Mun.
set warp to 0.

// WAIT FOR MUN PERIAPSIS
clearscreen.
print "Waiting for Mun periapsis... turn on lights to auto-warp".
lights off.
until 0 {
    if lights or autowarp { lights off. (time:seconds + (eta:periapsis - 60)). }
    if eta:periapsis < 60 { break. }
    wait 1.
} set warp to 0.

// CIRCULARIZE AROUND MUN
lock steering to ship:retrograde.
wait until eta:periapsis < 10.
print "Starting circularization burn...".
until 0 {
    if ship:obt:eccentricity > 0.1 {
        set tval to 1.
    } else {
        set tval to max(.05, ship:obt:eccentricity*10).
        set p to ship:obt:period.
        if (eta:apoapsis < (p/2 - p/4)) or (eta:apoapsis > (p/2 + p/4)) {
            break.   
        }
    }
    autostage().
    lock throttle to tval.
    wait 0.01.
} lock throttle to 0. unlock steering.

clearscreen.
print "Orbit achieved!". wait 5.

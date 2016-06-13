function climb_loop {
    // returns node lexicon
    parameter tgt.
    parameter goal_eval.
    parameter eval_function. 
    parameter init_data. // [offset, radial, normal, prograde] [300, 0, 0, 860]
    parameter seek_data. // list of maneuver node parameters to adjust ["eta", "prograde",]
    parameter step_size.
    parameter max_iterations.
    
    set maneuver_node to node(init_data[0], init_data[1], init_data[2], init_data[3]).
    add maneuver_node.
    
    local current_node is node_from_input_data(init_data, seek_data).
    set current_node["eval"] to eval_function(tgt, current_node["data"], maneuver_node).
    
    local inf is 2^64.
    local count is 0.
    until 0 {
        set count to count + 1.
        set neighbor_list to create_neighbors(current_node, step_size).
        set next_eval to -inf.
        set next_node to lexicon().
        for neighbor in neighbor_list {
            set neighbor["eval"] to eval_function(tgt, neighbor["data"], maneuver_node).
            if neighbor["eval"] > next_eval {
                set next_node to neighbor.
                set next_eval to neighbor["eval"].
            }
        }
        if next_eval <= current_node["eval"] {
            set current_node["exit_code"] to 2.
            break. 
        }
        set current_node to next_node.
        apply_data_to_maneuver_node(current_node["data"], maneuver_node).
        wait 0.001.
        if current_node["eval"] >= goal_eval { 
            set current_node["exit_code"] to 0.
            break.
        } else if count >= max_iterations {
            set current_node["exit_code"] to 1.
            break.
        }
    }
    print "Calculated tranfer maneuver.".
    print "Attempts: " + count.
    
    remove maneuver_node.
    
    return current_node.
}

function node_from_input_data {
    parameter init_list.
    parameter seek_list.
    
    local matcher is lexicon("eta", 0, "radial", 1, "normal", 2, "prograde", 3).
    local data is lexicon().
    
    for axis in seek_list {
        set data[axis] to init_list[matcher[axis]].
    }
    return lexicon("data", data).
}

function init_list_from_node {
    parameter node.
    local init_list is list(0,0,0,0).
    local matcher is lexicon("eta", 0, "radial", 1, "normal", 2, "prograde", 3).
    for key in node["data"]:keys {
        set init_list[matcher[key]] to node["data"][key].
    }
    return init_list.
}
    

function create_neighbors {
    parameter input_node, step_size.
    
    set neighbor_list to list().
    
    for key in input_node["data"]:keys {
        set increment_data to input_node["data"]:copy().
        set increment_data[key] to input_node["data"][key] + step_size.
        neighbor_list:add(lexicon("data", increment_data)).
        set decrement_data to input_node["data"]:copy().
        set decrement_data[key] to input_node["data"][key] - step_size.
        neighbor_list:add(lexicon("data", decrement_data)).
    }
    return neighbor_list.
}

function apply_data_to_maneuver_node {
    parameter data, maneuver_node.
    for key in data:keys {
        if key = "eta" {
            set maneuver_node:eta to data[key].
        } else if key = "radial" {
            set maneuver_node:radialout to data[key].
        } else if key = "normal" {
            set maneuver_node:normal to data[key].
        } else if key = "prograde" {
            set maneuver_node:prograde to data[key].
        }
    }
}

function eval_closest {
    parameter tgt, data, maneuver_node.
    apply_data_to_maneuver_node(data, maneuver_node).
    wait 0.001.
    return -closest_approach(tgt, maneuver_node).
}

function eval_tgt_altitude {
    parameter tgt_altitude, tgt_body, data, maneuver_node.
    apply_data_to_maneuver_node(data, maneuver_node).
    wait 0.001.
    local inf is 2^64.
    
    if maneuver_node:obt:hasnextpatch {
        if maneuver_node:obt:nextpatch:body = tgt_body {
            local p is maneuver_node:obt:nextpatch:periapsis.
            if p > tgt_altitude {
                return -(p - tgt_altitude).
            } else {
                return -(tgt_altitude - p).
            }
        }
    }
    return -inf.
}

function closest_approach{
    parameter tgt, maneuver_node.
    // return the closest distance between ship and target orbital
    
    // search over time equal to ship orbit
    // use bisection to narrow the search range
    
    set tol to 10.   //improvement to continue (in m)
    set best to 2^64.
    set start_time to time:seconds.
    // set best_time to 0.
    set smax to maneuver_node:eta + maneuver_node:obt:period.
    set smin to 0.
    
    set n to 0. set nmax to 100. //maximum iterations
    until n > nmax {
        set mid to (smin + smax)/2.
        set hi_mid to (mid + smax)/2.
        set lo_mid to (smin + mid)/2.
        // test mid point for each half
        set hi_d to distance_at_time(tgt, start_time + hi_mid).
        set lo_d to distance_at_time(tgt, start_time + lo_mid).
        
        // set smin and smax for half with closest midpoint
        if lo_d < hi_d {
            set smax to mid.
            // set best_time to start_time + lo_mid.
        } else {
            set smin to mid.
            // set best_time to start_time + hi_mid.
        }
        set best to min(lo_d, hi_d).
        if abs(abs(hi_d) - abs(lo_d)) < tol {
            break.
        }
        set n to n + 1.
    }
    // switch to 0.
    // log "Closest approach distance: " + round(best,2) to "climb_data.txt".
    // log "    Iterations: "+ n to "climb_data.txt".
    // switch to 1.
    // for debugging, add a maneuver node at the best time
    // set x to node(best_time, 0, 0, 0).
    // add x.
    return best.
}

function distance_at_time {
    parameter tgt, time.
    return (positionat(ship, time) - positionat(tgt, time)):mag.
}

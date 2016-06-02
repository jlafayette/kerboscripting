// 

function init_pid {
    parameter kp_input.
    parameter ki_input.
    parameter kd_input.
    
    set kp to kp_input.
    set ki to ki_input.
    set kd to kd_input.
    
    set lastP to 0.
    set lastTime to 0.
    set totalP to 0.
    
    // for logging
    set tic_num to 0.
}


function pid_loop {
    parameter target.
    parameter current.
    
    set output to 0.
    set now to time:seconds.
    
    set p to target - current.
    set i to 0.
    set d to 0.
    
    if lastTime > 0 {
        set i to totalP + ((p + lastP)/2 * (now - lastTime)).
        set d to (p - lastP) / (now - lastTime).
    }
        
    set output to p * kp + i * ki + d * kd.
    
    print "p: " + round(p) at (0, 0).
    print "i: " + round(i) at (0, 1).
    print "d: " + round(d) at (0, 2).
    print "target:  " + round(target,2) at (0, 4).
    print "current: " + round(current,2) at (0, 5).
    
    // // So it only logs every 10 cycles
    // if mod(tic_num, 10) = 0 {
        // // p only log
        // log (time:seconds - startTime)+"," + target+"," + current+"," + p+"," + output to "pid_data.csv".
        // // full log
        // //log (time:seconds - startTime)+"," + target+"," + current+"," + p+"," + i+"," + d+"," + output to "circ_pid_data13.csv".
    // }
    // set tic_num to tic_num + 1.
    
    set lastP to p.
    set lastTime to now.
    set totalP to i.
    
    return output.
}
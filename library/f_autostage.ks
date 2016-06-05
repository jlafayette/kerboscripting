set prev_thrust to 0.

function autostage {
    if maxthrust < (prev_thrust - 10) {
        lock throttle to 0. wait .5.
        stage. wait .5.
        until maxthrust > 0 { stage. wait .5. }
    }
    set prev_thrust to maxthrust.
}
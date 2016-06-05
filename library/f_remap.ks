function remap {
    parameter x, a, b, c, d. // input inputLow inputHigh outputLow outputHigh
    
    // d must be greater than c for this function to work.
    set r to (x-a)/(b-a) * (d-c) + c.
    if r > d { return d. }
    else if r < c { return c. }
    else { return r. }
}
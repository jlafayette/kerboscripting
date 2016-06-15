// results of test should be given so that a lower number is better.
function bisection_search {
    parameter smin, smax, tol, nmax, test.
    local best is 2^64.
    local n is 0.
    until n > nmax {
        set mid to (smin + smax)/2.
        set hi_mid to (mid + smax)/2.
        set lo_mid to (smin + mid)/2.
        
        set hi_result to test(hi_mid).
        set lo_result to test(lo_mid).
        
        if lo_result < hi_result {
            set smax to mid.
        } else {
            set smin to mid.
        }
        set best to min(lo_result, hi_result).
        if abs(abs(hi_result) - abs(lo_result)) < tol {
            break.
        }
        set n to n + 1.
        wait 0.01.
    }
    return best.
}

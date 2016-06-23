// Copied from Kevin Gisi with some minor modifications.
// Project: ksprogramming https://github.com/gisikw/ksprogramming
// Copyright (c) 2015 Kevin Gisi
// License (MIT) https://github.com/gisikw/ksprogramming/blob/master/license.txt


function lng_to_deg {
    parameter lng.
    return mod(lng + 360, 360).
}

function tgt_angle {
    parameter tgt.
    return mod(lng_to_deg(tgt:longitude) + 360 - 
               lng_to_deg(ship:longitude),
               360).
}

function close_enough {
    parameter n1.
    parameter n2.
    parameter margin.
    if abs(abs(n1) - abs(n2)) < margin { return 1. }
    else { return 0. }
}
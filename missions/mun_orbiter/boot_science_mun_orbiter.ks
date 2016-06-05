// SCIENCE BOOT

// SCIENCE GOALS
// Kerbin upper atmosphere (18 km < altitude < 70 km)
// In Space Low over Kerbin (Kerbin SOI, altitude < 250 km, > 70 km)
// In Space High over Kerbin (Kerbin SOI, altitude > 250 km)
// In Space High over Mun (Mun SOI, altitude > 60 km)
// In Space Low over Mun (Mun SOI, altitude < 60 km)

// rcs on indicate that science has been gathered and needs to be picked up
// by a scientist.
set scientist_on_board to true.

rcs off.

function gather_science {
    for p in ship:parts {
        if p:hasmodule("ModuleScienceExperiment") {
            set m to p:getmodule("ModuleScienceExperiment").
            if scientist_on_board {
                if not m:inoperable {
                    if m:hasdata { m:dump. wait 1. m:reset(). wait 2. }
                    m:deploy.
                    wait until m:hasdata.
                }
            } else {
                if m:rerunnable { 
                    m:deploy.
                    wait until m:hasdata.
                }
            }   
        }
    }
}
function kerbin_upper_atmosphere {
    if ship:body <> Kerbin { return 0. }
    if ship:altitude > 18000 and ship:altitude < 70000 { return 1. }
    else { return 0. }
}
function kerbin_low_space {
    if ship:body <> Kerbin { return 0. }
    if ship:altitude > 70000 and ship:altitude < 250000 { return 1. }
    else { return 0. }
}
function kerbin_high_space {
    if ship:body <> Kerbin { return 0. }
    if ship:altitude > 250000 { return 1. }
    else { return 0. }
}
function mun_high_space {
    if ship:body <> Mun { return 0. }
    if ship:altitude > 60000 { return 1. }
    else { return 0. }
}
function mun_low_space {
    if ship:body <> Mun { return 0. }
    if ship:altitude < 60000 { return 1. }
    else { return 0. }
}

set zone_lex to lexicon("kerbin upper atmosphere", kerbin_upper_atmosphere@,
                        "kerbin low space", kerbin_low_space@,
                        "kerbin high space", kerbin_high_space@,
                        "mun high space", mun_high_space@,
                        "mun low space", mun_low_space@).
set remove_key to "".

//TODO: Write better info messages and clear them each time through the loop.
clearscreen.                     
until 0 {
    if not rcs and warp = 0 {
        for key in zone_lex:keys {
            print "Checking science conditions..." at (5, 8).
            set condition to zone_lex[key].
            if condition() {
                print "Gathering science for zone <"+key+">".
                gather_science().
                rcs on. // user should turn if off to continue.
                set remove_key to key.
            }    
        }
        if zone_lex:haskey(remove_key) { zone_lex:remove(remove_key). }
        
    }
    print "Waiting for Kerbal to retrieve science data. Turn off RCS when ready." at (5, 8).
    wait 5.
}



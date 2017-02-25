// Science boot

// SCIENCE GOALS
// Kerbin upper atmosphere (18 km < altitude < 70 km)
// In Space Low over Kerbin (Kerbin SOI, altitude < 250 km, > 70 km)
// In Space High over Kerbin (Kerbin SOI, altitude > 250 km)
// In Space High over Mun (Mun SOI, altitude > 60 km)
// In Space Low over Mun (Mun SOI, altitude < 60 km)
// In Space High over Minmus (Minmus SOI, altitude > 30 km)
// In Space Low over Minmus (Minmus SOI, altitude < 30 km)

// BRAKES on indicate that science has been gathered and needs to be picked up
// by a scientist.
set scientist_on_board to true.

brakes off.

function gather_science {
    for p in ship:parts {
        if p:hasmodule("ModuleScienceExperiment") {
            set m to p:getmodule("ModuleScienceExperiment").
            if scientist_on_board {
                if not m:inoperable {
                    if m:hasdata { m:reset(). wait 2. }
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

function science_zone {
    parameter body.
    parameter min_alt.
    parameter max_alt.
    if ship:body <> body { return 0. }
    if ship:altitude > min_alt and ship:altitude < max_alt { return 1. }
    else { return 0. }
}

// Mun Dividing line is 60000
set zone_lex to lexicon(
    "kerbin upper atmosphere", science_zone@:bind(Kerbin, 18000, 70000),
    "kerbin low space", science_zone@:bind(Kerbin, 70000, 250000),
    "kerbin high space", science_zone@:bind(Kerbin, 250000, 90000000),
    "minmus high space", science_zone@:bind(Minmus, 30000, 3000000),
    "minmus low space", science_zone@:bind(Minmus, 0, 30000)).
set remove_key to "".

clearscreen.                        
until 0 {
    clearscreen.
    if warp <> 0 {
        print "Science check disabled while time warping." at (5, 5).
    }
    else if brakes {
        print "Waiting for Kerbal to retrieve science data. Turn off BRAKES when ready." at (5, 5).
    } else {
        for key in zone_lex:keys {
            print "Checking science conditions..." at (5, 8).
            set condition to zone_lex[key].
            if condition:call() {
                print "Gathering science for zone <"+key+">".
                gather_science().
                brakes on. // user should turn if off to continue.
                set remove_key to key.
            }    
        }
        if zone_lex:haskey(remove_key) { 
            print "Removing key: " + remove_key.
            zone_lex:remove(remove_key). }
        wait 5.
    } 
    wait 5.
}

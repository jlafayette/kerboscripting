// =============================================================================
// BASIC SCIENCE
// =============================================================================
function get_science {
    for p in ship:parts {
        if p:hasmodule("ModuleScienceExperiment") {
            set m to p:getmodule("ModuleScienceExperiment").
            if not m:inoperable { 
                m:deploy.
                wait until m:hasdata.
            }
        }
    }
}

function transmit_rerunnable_science {
    for p in ship:parts {
        if p:hasmodule("ModuleScienceExperiment") {
            set m to p:getmodule("ModuleScienceExperiment").
            if m:rerunnable { 
                m:deploy.
                wait until m:hasdata.
                m:transmit.
            }
        } 
    }
}

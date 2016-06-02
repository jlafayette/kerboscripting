// function has_file {
    // parameter name.
    // parameter vol.
    
    // switch to vol.
    // list files in allfiles.
    // for file in allfiles {
        // if file:name = name {
            // switch to 1.
            // return true.
        // }
    // }
    // switch to 1.
    // return false.
// }

// Get a file from KSC
function download {
    parameter name.
    switch to 0.
    if exists(name) {
        switch to 1.
        if exists(name) { delete name. }
        copy name from 0.
    }
}
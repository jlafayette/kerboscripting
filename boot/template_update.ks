clearscreen.
print "Booting up...".

set ship:control:pilotmainthrottle to 0. wait 1.

if ship:altitude < 500 and ship:obt:body = Kerbin and ship:airspeed < 1 {
    print "Initializing mission sequence...". wait 1.
    copypath("0:/missions/template.ks", "1:/").
    runpath("template.ks").
    deletepath("1:/template.ks").
} wait 3.

// CHECK FOR UPDATE LOOP
until 0 {
    // Check for update script and run it if found.
    clearscreen.
    print "Checking for update script... ". wait 3.
    if exists("0:/a_update.ks") {
        print "    Update script found!". wait 3.
        if exists("1:/a_update.ks") {
            deletepath("1:/a_update.ks").
        }
        copypath("0:/a_update.ks", "1:/").
        deletepath("0:/a_update.ks").
        clearscreen.
        runpath("1:/a_update.ks").
        deletepath("1:/a_update.ks").
    }
    else {
        print "    No update script found.". wait 5.
    }
}

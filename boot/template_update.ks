clearscreen.
print "Booting up...".

set ship:control:pilotmainthrottle to 0. wait 1.

if ship:altitude < 500 and ship:obt:body = Kerbin and ship:airspeed < 1 {
    print "Initializing mission sequence...". wait 1.
    copy a_mission.ks from 0.
    run a_mission.
    delete a_mission.ks from 1.
} wait 3.

// CHECK FOR UPDATE LOOP
until 0 {
    // Check for update script and run it if found.
    clearscreen.
    print "Checking for update script... ". wait 3.
    switch to 0.
    if exists(a_update.ks) {
        print "    Update script found!". wait 3.
        switch to 1.
        if exists(a_update.ks) { delete a_update.ks. }
        copy a_update.ks from 0.
        switch to 0. 
        delete a_update.ks. 
        switch to 1.
        clearscreen.
        run a_update.ks.
        delete a_update.ks from 1.
    }
    else {
        switch to 1.
        print "    No update script found.". wait 5.
    }
}
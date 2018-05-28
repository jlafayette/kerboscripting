// Mission: KerboSCAN 1
parameter autowarp is true.

// LAUNCH
clearscreen.
copypath("0:/launch.ks", "1:/").
set tgt_direction to 0.
runpath("launch.ks", 275000, tgt_direction).
deletepath("1:/launch.ks").

// DEPLOY SOLAR PANELS
panels on.

// DEPLOY ANTENNA FOR COMMUNICATION
copypath("0:/extend_antenna.ks", "1:/").
runpath("extend_antenna.ks", "Communotron 16").
deletepath("1:/extend_antenna.ks").

// CIRCULARIZE
copypath("0:/circularize.ks", "1:/").
runpath("circularize.ks", tgt_direction).
deletepath("1:/circularize.ks").
wait 1. clearscreen.

// IN ORBIT!
print "Orbit achieved.". wait 3.

// DO MISSION HERE
clearscreen. print "Deploying Scanner...".
set radar_list to ship:partsdubbed("SCAN RADAR Altimetry Sensor").
set radar to radar_list[0].
set scansat to radar:getmodule("SCANsat").
scansat:doevent("start scan: radar").
print "Radar SCAN started".

// DEPLOY ANTENNA FOR COMMUNICATION
parameter antenna_type is "Communotron 16".

set antenna_list to ship:partsdubbed(antenna_type).
if antenna_list:length > 0 {
    set antenna to antenna_list[0].
    antenna:getmodule("ModuleDeployableAntenna"):doevent("extend antenna").
    wait 1.
}
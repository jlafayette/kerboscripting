parameter fairing_type is "fairingSize1".

set fairing_list to ship:partsdubbed(fairing_type).
if fairing_list:length > 0 {
    set fairing to fairing_list[0].
    fairing:getmodule("ModuleProceduralFairing"):doevent("deploy").
    wait 2.
}
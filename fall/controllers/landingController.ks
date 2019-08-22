@lazyglobal off.
// landingController ::
//     landingData ->
//     hoverslam ->
//     int* ->
//     int* ->
//     landingController
function landingController {
    parameter ldata,
              hoverslam,
              aoa is 10,
              errorScaling is 1.

    // public getSteering :: nothing -> direction
    function getSteering {
        // returns steering vector accounting for max angle of attack
        local errorVector is ldata["errorVector"]().
        local velVector is -ship:velocity:surface.
        local result is velVector - errorVector*errorScaling.

        // [ improvement ] could check if velVector and errorVector ratio is
        // larger than tan(aoa)
        if vang(result, velVector) > aoa
        {
            set result to velVector:normalized
                          - tan(aoa)*errorVector:normalized.
        }

        return lookdirup(result, facing:topvector).
    }

    // public getThrottle :: nothing -> float
    function getThrottle { return hoverslam["getThrottle"](). }

    // public completed :: nothing -> bool
    function completed {
        return ship:status = "landed" or ship:status = "splashed".
    }

    // public passControl :: bool* -> nothing
    function passControl {
        // performs powered landing maneuver
        parameter isUnlocking is true.

        lock steering to getSteering().
        lock throttle to getThrottle().
        wait until completed().

        if isUnlocking { unlock throttle. unlock steering. }
    }

    // Return Public Fields
    return lexicon(
        "getSteering", getSteering@,
        "getThrottle", getThrottle@,
        "completed", completed@,
        "passControl", passControl@
    ).
}

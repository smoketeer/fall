@lazyglobal off.
// boostbackController :: landingData -> boostbackController
function boostbackController {
    parameter ldata,
              errorScaling is 5.

    lock landingPosition to ldata["getSite"]():position.
    lock impactPosition to ldata["getImpact"]():position.

    // private endBurn :: nothing -> bool
    function endBurn {
        // returns true if boostback burn should end
        local landingProjection to vxcl(up:forevector, landingPosition).
        local impactProjection  to vxcl(up:forevector, impactPosition).

        return vang(landingProjection, impactProjection) < 45
               and impactProjection:mag > landingProjection:mag.
    }

    // public getSteering :: nothing -> vector
    function getSteering {
        local errorVector is ldata["errorVector"]().
        local yawVector is vxcl(up:forevector, -errorVector):normalized.

        return yawVector*errorScaling - ship:velocity:surface:normalized.
    }

    // public getThrottle :: nothing -> float
    function getThrottle {
        if endBurn() { return 0. }
        return ldata["errorVector"]():mag/1000 + 0.25.
    }

    // public completed :: nothing -> bool
    function completed { return endBurn(). }

    // public passControl :: bool* -> nothing
    function passControl {
        // performs boostback maneuver
        parameter isUnlocking is true.

        local initialSteering is getSteering().
        lock steering to initialSteering.
        wait until vang(initialSteering, ship:facing:forevector) < 5.

        lock steering to getSteering().
        lock throttle to getThrottle().
        wait until completed().

        if isUnlocking { unlock throttle. unlock steering. }
    }

    return lexicon(
        "getThrottle", getThrottle@,
        "getSteering", getSteering@,
        "completed", completed@,
        "passControl", passControl@
    ).
}

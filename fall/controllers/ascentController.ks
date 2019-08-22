@lazyglobal off.
// ascentController :: int -> int -> int -> int -> ascentController
function ascentController {
    parameter desiredAp is 10000,
              pitchVelocity is 70,
              pitchDegrees is 10,
              AoA is 5,
              inclination is 0.

    local followPrograde is false.
    local finalDir is up - R(0, pitchDegrees, 0).

    // private compensateInclination :: nothing -> vector
    function compensateInclination {
        local inclination is ship:orbit:inclination.

    }

    // public getSteering :: nothing -> direction
    function getSteeringRaw {
        compensateInclination().
        if (ship:velocity:surface:mag > pitchVelocity) and not followPrograde
        {
            if vang(finalDir:vector, ship:srfprograde:vector) > 0.5
            {
                return ship:srfprograde - R(0, AoA, 0).
            }

            set followPrograde to True.
        }

        if followPrograde
        {
            return ship:srfprograde.
        }
        else
        {
            return up.
        }
    }
    function getSteering {
        local rawDirection is getSteeringRaw().
        local incCompensation is (heading(90, 90) - rawDirection):pitch.
        return R(incCompensation, rawDirection:yaw, rawDirection:roll).
    }

    // public getThrottle :: nothing -> float
    function getThrottle {
        if (ship:apoapsis < desiredAp - 1000) { return 1. }

        return (desiredAp - ship:apoapsis)/1000 + 0.2.
    }

    // public completed :: nothing -> bool
    function completed { return ship:apoapsis > desiredAp. }

    // public passControl :: bool* -> nothing
    function passControl {
        // performs ascent maneuver
        parameter isUnlocking is true.

        lock steering to getSteering().
        lock throttle to getThrottle().
        wait until completed().

        if isUnlocking { unlock throttle. unlock steering. }
    }

    // Return Public Fields
    return lexicon(
        "getThrottle", getThrottle@,
        "getSteering", getSteering@,
        "completed", completed@,
        "passControl", passControl@
    ).
}

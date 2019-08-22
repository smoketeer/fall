@lazyglobal off.
// glidePIDController ::
//     landingData ->
//     float* ->
//     float* ->
//     float* ->
//     float* ->
//     float* ->
//     glidePIDController
function glidePIDController {
    parameter ldata,
              Kp is 0,
              Ki is 0,
              Kd is 0,
              minOut is -10,
              maxOut is 10.

    local yawPid is pidloop(Kp, Ki, Kd, minOut, maxOut).
    local pitchPid is pidloop(Kp, Ki, Kd, minOut, maxOut).
    set yawPid:setpoint to 0.
    set pitchPid:setpoint to 0.

    // private pidOutput :: nothing -> direction
    function pidOutput {
        local yaw is yawPid:update(time:seconds, ldata["lngError"]()).
        local pitch is pitchPid:update(time:seconds, ldata["latError"]()).

        return R(pitch, yaw, 0).
    }

    // public getSteering :: nothing -> direction
    function getSteering { return ship:srfretrograde + pidOutput(). }

    // public getThrottle :: nothing -> float
    function getThrottle { return 0. } // no throttle during gliding

    // public completed :: nothing -> bool
    function completed { return throttle > 0. }

    // public passControl :: bool* -> nothing
    function passControl {
        // performs gliding towards target maneuver
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

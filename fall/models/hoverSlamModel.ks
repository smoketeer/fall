@lazyglobal off.
// hoverSlamModel :: int -> int -> hoverSlamModel
function hoverSlamModel {
    // Constructor
    parameter bias is 20,
              maxTwr is -1.

    if maxTwr < 0 {
        set maxTwr to ship:availablethrust/ship:mass/g.
    }

    lock deltalt to (alt:radar+getBurnAlt()).

    // private g :: nothing -> float
    function g { return body:mu/(ship:altitude + body:radius)^2. }

    // private getBurnAlt :: nothing -> float
    function getBurnAlt {
        local v0 to ship:velocity:surface:mag.
        return -(v0^2)/(2*g*(maxTwr - 1)).
    }

   // private burnTwr :: nothing -> float
   function burnTwr {
       local v0 to ship:velocity:surface:mag.
       local s0 to alt:radar - bias.
       return (v0^2)/(2*g*s0) + 1.
   }

   // private getThrust :: nothing -> float
   function getThrust {
       parameter twr.
       return twr*ship:mass*g/ship:availablethrust.
   }

   // public getThrottle :: nothing -> float
   function getThrottle {
       if deltalt > 1 or ship:verticalspeed > 0 { return 0. }
       lock deltalt to 0.
       if ship:velocity:surface:mag < 3 { return getThrust(0.99). }
       return getThrust(burnTwr()).
   }

   // Return Public Fields
   return lexicon(
       "getThrottle", getThrottle@
   ).
}

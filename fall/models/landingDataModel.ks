@lazyglobal off.
// landingDataModel :: geo -> landingDataModel
function landingDataModel {
    // Constructor
    parameter landingsite is ship:geoposition.

    // public getImpact :: nothing -> geo
    function getImpact {
        if addons:tr:hasimpact { return addons:tr:impactpos. }
        return ship:geoposition.
    }

    // public lngError :: nothing -> float
    function lngError {
        return getImpact():lng - landingsite:lng.
    }

    // public latError :: nothing -> float
    function latError {
        return getImpact():lat - landingsite:lat.
    }

    // public errorVector :: nothing -> vector
    function errorVector {
        return getImpact():position - landingSite:position.
    }

    // public overshoot :: float -> landingDataModel
    function overshoot {
        parameter meters is 50.
        local overshootUnit is vxcl(up:vector, landingSite:position):normalized.
        local overshootPosition is landingSite:position + meters*overshootUnit.

        return landingDataModel(body:geopositionof(overshootPosition)).
    }

    // public getSite :: nothing -> geoposition
    function getSite { return landingSite. }

    // Return Public Fields
    return lexicon(
        "getImpact", getImpact@,
        "lngError", lngError@,
        "latError", latError@,
        "errorVector", errorVector@,
        "overshoot", overshoot@,
        "getSite", getSite@
    ).
}

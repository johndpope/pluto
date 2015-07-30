//
// Created by John Sparks on 7/30/15.
// Copyright (c) 2015 John Sparks. All rights reserved.
//

import Foundation

public struct SpaceBodyData {

    let skin:String
    let name:String
    let radius:Float
    let orbitDistance:Float
    let orbitBody:String?

    init(dict:[String:String]){

        let distanceScale:Float = 1.0 / 10000.0 // keep numbers understandable
        var radisuScale:Float   = 1.0 / 1000.0 // keep numbers understandable

        skin = dict["skin"]!
        name = dict["name"]!

        // pluto gets a size multiplier to avoid jittering, sorry science
        if name == "Pluto" {
            radisuScale = 20 * radisuScale
        }

        radius = (dict["radius"]! as NSString).floatValue * radisuScale

        var tempOrbitDist:Float = 0
        if let distString:String = dict["orbit_radius"] {
            var floatDist = (distString as NSString).floatValue

            tempOrbitDist = floatDist * distanceScale
        }
        orbitDistance = tempOrbitDist
        orbitBody = dict["orbital_body"]
    }

}
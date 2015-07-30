//
// Created by John Sparks on 7/30/15.
// Copyright (c) 2015 John Sparks. All rights reserved.
//

import Foundation
import SceneKit


public func ==(a:SpaceBodyNode, b:SpaceBodyNode) -> Bool {
    return a.name == b.name
}

public class SpaceBodyNode: SCNNode {

    var data:SpaceBodyData?

    public var cameraDistance:Float {
        get {
            return data!.radius * 6
        }
    }

    public var cameraLocation:SCNVector3 {
        get {
            return SCNVector3(x: 0, y: 0, z: data!.orbitDistance + cameraDistance)
        }
    }

    public var rotationSpeed:CGFloat {
        get {
            let factor:Float = name == "Pluto" ? 400 : 20
            return CGFloat(factor / data!.radius)
        }
    }

    public init(data: SpaceBodyData) {
        super.init()
        self.data = data
        name = data.name
        geometry = SCNSphere(radius: CGFloat(data.radius))
        geometry!.firstMaterial?.diffuse.contents = UIImage(named: data.skin)
        let zero:Float = 0
        position = SCNVector3(x: zero, y: zero, z: data.orbitDistance)
    }

    // Required

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
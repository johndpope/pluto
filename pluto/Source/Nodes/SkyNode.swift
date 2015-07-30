//
// Created by John Sparks on 7/30/15.
// Copyright (c) 2015 John Sparks. All rights reserved.
//

import Foundation
import SceneKit

public class SkyNode:SCNNode {

    public override init() {
        super.init()

        geometry = SCNSphere(radius: 1000000.0)

        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "sky.jpg")
        material.doubleSided = true
//        material.specular.contents = UIColor.whiteColor()
//        material.shininess = 1.0
        geometry!.materials = [material]

    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
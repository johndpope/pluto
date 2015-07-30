//
// Created by John Sparks on 7/30/15.
// Copyright (c) 2015 John Sparks. All rights reserved.
//

import Foundation
import SceneKit

public class Hubble : SCNNode {

    let cameraNode:SCNNode

    public override init() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera!.zNear = 0.1
        cameraNode.camera!.zFar = 5000000 // 5,000,000
        super.init()

        addChildNode(cameraNode)
    }

    public func orbit(node:SpaceBodyNode) {

        removeAllActions()

        let look = SCNLookAtConstraint(target: node)
        cameraNode.constraints = [look]
        cameraNode.position = SCNVector3(x: 0, y: 0, z: node.cameraDistance)

        let pos = node.position

        let zoom = SCNAction.group([
                SCNAction.moveTo(pos, duration: 1.5),
                SCNAction.rotateToX(-0.25, y: 0, z: 0, duration: 1.5)
        ])

        zoom.timingMode = .EaseInEaseOut;

        let lat = SCNAction.repeatActionForever(SCNAction.sequence([
                SCNAction.rotateByX(0.5, y: 0, z: 0, duration: 7),
                SCNAction.rotateByX(-0.5, y: 0, z: 0, duration: 7),
        ]))

        lat.timingMode = .EaseInEaseOut

        let lon = SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 1, z: 0, duration: 5))

        let orbit = SCNAction.group([lat, lon])

        runAction(zoom, completionHandler: {
            println("\(node.name) \(node.data!.radius) \(node.position.z) \(self.position.z) \(self.cameraNode.position.z)")

            self.runAction(orbit)
        })
    }

    // Required

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
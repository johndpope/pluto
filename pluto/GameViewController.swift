//
//  GameViewController.swift
//  pluto
//
//  Created by John Sparks on 7/3/15.
//  Copyright (c) 2015 John Sparks. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit


class JupiterNode: SCNNode {

    required override init() {
        super.init()
        geometry = SCNSphere(radius: 1)
        geometry!.firstMaterial?.diffuse.contents = UIImage(named: "jupiter")
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SunNode: SCNNode {
    
    required override init() {
        super.init()
        geometry = SCNSphere(radius: 2)
        geometry!.firstMaterial?.diffuse.contents = UIImage(named: "jupiter")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SaturnNode: SCNNode {
    
    required override init() {
        super.init()
        geometry = SCNSphere(radius: 1)
        geometry!.firstMaterial?.diffuse.contents = UIImage(named: "saturn")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class GameViewController: UIViewController {

    let cameraNode:SCNNode
    let jupiterNode:JupiterNode
    let saturnNode:SaturnNode
    let scene:SCNScene
    
    var rotateAction:SCNAction?
    
    required init(coder aDecoder: NSCoder) {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.focalDistance = 1
        print(cameraNode.camera)
        jupiterNode = JupiterNode()
        saturnNode = SaturnNode()
        scene = SCNScene()
        super.init(coder:aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add a camera to the scene
        scene.rootNode.addChildNode(cameraNode)
        //  Right, Left, Top, Bottom, Back, Front.
        scene.background.contents = ["sky_right", "sky_left", "sky_top", "sky_bottom", "sky_back", "sky_front"]
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 4)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
        
        scene.rootNode.addChildNode(jupiterNode)
        scene.rootNode.addChildNode(saturnNode)
        
        jupiterNode.position = SCNVector3()
        saturnNode.position = SCNVector3(x: 0, y: 0, z: 70)
        
        // animate the 3d object
        rotateAction = SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 1, z: 0, duration: 10))
        jupiterNode.runAction(rotateAction!, forKey: "rotate")
        saturnNode.runAction(rotateAction!, forKey: "rotate")
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = false
        
        // configure the view
        scnView.backgroundColor = UIColor.blackColor()
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        var gestureRecognizers = [AnyObject]()
        gestureRecognizers.append(tapGesture)
        if let existingGestureRecognizers = scnView.gestureRecognizers {
            gestureRecognizers.extend(existingGestureRecognizers)
        }
        scnView.gestureRecognizers = gestureRecognizers

//        let zoomPan = UIPanGestureRecognizer(target: self, action: "handlePan:")
//        scnView.addGestureRecognizer(zoomPan)

    }
    
    func addLightToSceneAt(postion:SCNVector3) {
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = postion
        scene.rootNode.addChildNode(lightNode)
    }
    
    func handlePan(gesture: UIPanGestureRecognizer) {
        let point = gesture.velocityInView(view!)
        
        let zoomThreshold:CGFloat = 1000
        
        print(zoomThreshold, point.y, "\n")
        
        if(point.y > zoomThreshold){
            cameraNode.runAction(SCNAction.moveTo(SCNVector3(x: 0, y: 0, z: 4), duration: 0.8))
            //let mat = jupiterNode.geometry!.firstMaterial!
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(1)
            jupiterNode.opacity = 1;
            SCNTransaction.commit()
        } else if(point.y < -1 * zoomThreshold){
            cameraNode.runAction(SCNAction.moveTo(SCNVector3(x: 0, y: 0, z: 99), duration: 0.2))
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(1)
            jupiterNode.opacity = 0.01;
            SCNTransaction.commit()
        } else {
//            jupiterNode.removeAllActions()
//            let old = jupiterNode.rotation
//            jupiterNode.rotation = SCNVector4(x: Float(point.x), y: Float(point.y), z: old.z, w: old.w)
        }
        
    }
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.locationInView(scnView)
        if let hitResults = scnView.hitTest(p, options: nil) {
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                // retrieved the first clicked object
                let result: AnyObject! = hitResults[0]
                
                // get its material
                let material = result.node!.geometry!.firstMaterial!
                
                // highlight it
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                
                // on completion - unhighlight
                SCNTransaction.setCompletionBlock {
                    SCNTransaction.begin()
                    SCNTransaction.setAnimationDuration(0.5)
                    
                    material.emission.contents = UIColor.blackColor()
                    
                    SCNTransaction.commit()
                }
                
                material.emission.contents = UIColor.redColor()
                
                SCNTransaction.commit()
            }
        }
    }
    
    func moveCameraTo(node:SCNNode) {
        
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}

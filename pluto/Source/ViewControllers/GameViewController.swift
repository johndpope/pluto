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

public class GameViewController: UIViewController {

    let cameraNode:Hubble
    let scene:SCNScene
    let ambientLightNode:SCNNode
    let lightNode:SCNNode
    var bodies:[SpaceBodyNode]
    
    var bodyIndex:Int = 0
    
    required public init(coder aDecoder: NSCoder) {
        cameraNode = Hubble()
        ambientLightNode = SCNNode()
        lightNode = SCNNode()
        scene = SCNScene()
        bodies = []
        super.init(coder:aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // add a camera to the scene
        scene.rootNode.addChildNode(cameraNode)

        scene.rootNode.addChildNode(SkyNode())
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        // create and add an ambient light to the scene
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = false
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = false
        
        // configure the view
        scnView.backgroundColor = UIColor.blackColor()
        
        // BEGIN!!
        addPlanets()
        
        moveBetweenBodies()
        
        let tap = UITapGestureRecognizer(target: self, action: "moveBetweenBodies")
        view.addGestureRecognizer(tap)
        
        view.addSubview(GameInterfaceView(frame: view.frame))
        
    }
    
    
    func addLightToSceneAt(postion:SCNVector3) {
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeAmbient
        lightNode.position = postion
        scene.rootNode.addChildNode(lightNode)
    }
    
    func addPlanets() {
        for planet in PlanetDataSource().spaceNodes {
            bodies.append(planet)
            scene.rootNode.addChildNode(planet)
            addLightToSceneAt(planet.position)
        }
    }
    
    func moveBetweenBodies() {
        if bodyIndex >= bodies.count {
            bodyIndex = 0
        }
        let node = bodies[bodyIndex]
        cameraNode.orbit(node)
        bodyIndex += 1
    }
    
    public override func shouldAutorotate() -> Bool {
        return true
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    public override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}

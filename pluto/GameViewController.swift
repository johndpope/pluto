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


func ==(a:SpaceBodyNode, b:SpaceBodyNode) -> Bool {
    return a.name == b.name
}

class SpaceBodyNode: SCNNode {
    
    var data:SpaceBodyData?
    
    var cameraDistance:Float {
        get {
            return data!.radius * 3.5
        }
    }
    
    var cameraLocation:SCNVector3 {
        get {
            return SCNVector3(x: 0, y: 0, z: data!.orbitDistance + cameraDistance)
        }
    }
    
    required override init() {
        super.init()
    }
    
    convenience init(data: SpaceBodyData) {
        self.init()
        self.data = data
        name = data.name
        geometry = SCNSphere(radius: CGFloat(data.radius))
        geometry!.firstMaterial?.diffuse.contents = UIImage(named: data.skin)
        let zero:Float = 0
        position = SCNVector3(x: zero, y: zero, z: data.orbitDistance)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct SpaceBodyData {

    let skin:String
    let name:String
    let radius:Float
    let orbitDistance:Float
    let orbitBody:String?
    
    init(dict:Dictionary<String, String>){
        
        let distanceScale:Float = 1.0 / 10000.0 // keep numbers understandable
        let radisuScale:Float   = 1.0 / 1000.0 // keep numbers understandable
        
        skin = dict["skin"]!
        name = dict["name"]!
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


class PlanetDataSource {
    
    func planetDatas() -> [SpaceBodyData] {
        
        var data:[SpaceBodyData] = []
        let csv = self.csv()
        
        for row in csv.rows {
            data.append(SpaceBodyData(dict: row))
        }
        
        return data
    }
    
    func csv() -> CSV {
        return CSV(contentsOfURL: csvURL(), error: nil)!
    }

    func csvURL() -> NSURL {
        let urlString = NSBundle.mainBundle().pathForResource("planet_data", ofType: ".csv")!
        return NSURL(fileURLWithPath: urlString)!
    }
}

class GameViewController: UIViewController {

    let cameraNode:SCNNode
    let scene:SCNScene
    let ambientLightNode:SCNNode
    let lightNode:SCNNode
    var bodies:[SpaceBodyNode]
    
    var bodyIndex:Int = 0
    
    required init(coder aDecoder: NSCoder) {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera!.zNear = 1
        cameraNode.camera!.zFar = 590638
        ambientLightNode = SCNNode()
        lightNode = SCNNode()
        scene = SCNScene()
        bodies = []
        super.init(coder:aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add a camera to the scene
        scene.rootNode.addChildNode(cameraNode)
        //  Right, Left, Top, Bottom, Back, Front.
        scene.background.contents = ["sky_right", "sky_left", "sky_top", "sky_bottom", "sky_back", "sky_front"]
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 228)
        
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
    }
    
    func addLightToSceneAt(postion:SCNVector3) {
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeAmbient
        lightNode.position = postion
        scene.rootNode.addChildNode(lightNode)
    }
    
    func addPlanets() {
        for data in PlanetDataSource().planetDatas() {
            let node = SpaceBodyNode(data: data)
            node.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 1, z: 0, duration: 10)))
            scene.rootNode.addChildNode(node)
            bodies.append(node)
        }
    }
    
    func moveBetweenBodies() {
        if bodyIndex >= bodies.count {
            bodyIndex = 0
        }
        let node = bodies[bodyIndex]
        println("\(node.name) \(node.data!.radius) \(node.position.z) \(node.cameraLocation.z)")
        cameraNode.runAction(SCNAction.moveTo(node.cameraLocation, duration: 1))
        bodyIndex += 1
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

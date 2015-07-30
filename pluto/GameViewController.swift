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
            return data!.radius * 6
        }
    }
    
    var cameraLocation:SCNVector3 {
        get {
            return SCNVector3(x: 0, y: 0, z: data!.orbitDistance + cameraDistance)
        }
    }
    
    var rotationSpeed:CGFloat {
        get {
            let factor:Float = name == "Pluto" ? 400 : 20
            return CGFloat(factor / data!.radius)
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

class GameInterfaceView : UIView {
    
    let forwardButton : UIImageView
    let backButton : UIImageView
    let buttonSize: CGSize
    
    override init(frame: CGRect) {
        
        let forwardImage = UIImage(named: "right_arrow")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let backImage = UIImage(named: "left_arrow")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)

        buttonSize = forwardImage!.size
        
        forwardButton = UIImageView(image: forwardImage)
        forwardButton.tintColor = UIColor.whiteColor()

        backButton = UIImageView(image: backImage)
        backButton.tintColor = UIColor.whiteColor()

        
        super.init(frame: frame)
        
        addSubview(forwardButton)
        addSubview(backButton)
    
    }
    
    
    override func layoutSubviews() {
    
        let margin:CGFloat = 10.0
        let y = frame.size.height - buttonSize.height - margin
        let backX:CGFloat = 10.0
        let forwardX = frame.size.width - buttonSize.width - margin
        
        let backOrigin = CGPoint(x: backX, y: y)
        let forwardOrigin = CGPoint(x: forwardX, y: y)

        backButton.frame = CGRect(origin: backOrigin, size: buttonSize)
        forwardButton.frame = CGRect(origin: forwardOrigin, size: buttonSize)
        
        super.layoutSubviews()
    }
    

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class SkyNode:SCNNode {
    
    override init() {
        super.init()
        
        geometry = SCNSphere(radius: 1000000.0)

        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "sky.jpg")
        material.doubleSided = true
//        material.specular.contents = UIColor.whiteColor()
//        material.shininess = 1.0
        geometry!.materials = [material]

    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PlanetDataSource {
    
    let spaceNodes:[SpaceBodyNode]
    
    init(){
        spaceNodes = PlanetDataSource.makeSpaceNodes()
    }
    
    static func makeSpaceNodes() -> [SpaceBodyNode] {
        var nodes:[SpaceBodyNode] = []
        for data in PlanetDataSource.planetDatas() {
            let node = SpaceBodyNode(data: data)
            node.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: -node.rotationSpeed, z: 0, duration: 10)))
            nodes.append(node)
        }
        return nodes
    }
    
    static func planetDatas() -> [SpaceBodyData] {
        
        var data:[SpaceBodyData] = []
        let csv = PlanetDataSource.csv()
        
        for row in csv.rows {
            data.append(SpaceBodyData(dict: row))
        }
        
        return data
    }
    
    static func csv() -> CSV {
        return CSV(contentsOfURL: csvURL(), error: nil)!
    }

    static func csvURL() -> NSURL {
        let urlString = NSBundle.mainBundle().pathForResource("planet_data", ofType: ".csv")!
        return NSURL(fileURLWithPath: urlString)!
    }
}


class Hubble : SCNNode {

    let cameraNode:SCNNode
    
    override init() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera!.zNear = 0.1
        cameraNode.camera!.zFar = 5000000 // 5,000,000
        super.init()
        
        
        addChildNode(cameraNode)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func orbit(node:SpaceBodyNode) {

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
}

class IntervalLogger {
    
    static let interval = 0.2
    
    static func log(block:() -> String){
        print(block())
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(interval * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
            self.log(block)
        }
    }
}



class GameViewController: UIViewController {

    let cameraNode:Hubble
    let scene:SCNScene
    let ambientLightNode:SCNNode
    let lightNode:SCNNode
    var bodies:[SpaceBodyNode]
    
    var bodyIndex:Int = 0
    
    required init(coder aDecoder: NSCoder) {
        cameraNode = Hubble()
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

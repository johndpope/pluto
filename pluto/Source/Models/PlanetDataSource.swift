//
// Created by John Sparks on 7/30/15.
// Copyright (c) 2015 John Sparks. All rights reserved.
//

import Foundation
import SceneKit

public class PlanetDataSource {

    public let spaceNodes:[SpaceBodyNode]

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
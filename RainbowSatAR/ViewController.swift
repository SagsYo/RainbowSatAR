//
//  ViewController.swift
//  RainbowSatAR
//
//  Created by Dylan Maryk on 19/10/2019.
//  Copyright © 2019 rainbow6. All rights reserved.
//

import ARKit
import SceneKit
import UIKit

struct SatelliteParams {
    let id: String
    let imageName: String
    let lineColor: UIColor
}

struct CoordinatesWrapper: Decodable {
    let coordinates: [Coordinates]
}

struct Coordinates: Decodable {
    let x: Double
    let y: Double
    let z: Double
}

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    private let scaleDivider: Double = 30000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
//        sceneView.showsStatistics = true
//        sceneView.debugOptions = [.showBoundingBoxes, .showWorldOrigin]
        let scene = SCNScene()
        let globe = createGlobe()
        scene.rootNode.addChildNode(globe)
        let satellitesParams = [SatelliteParams(id: "40059",
                                                imageName: "art.scnassets/cow.png",
                                                lineColor: .red),
                                SatelliteParams(id: "28376",
                                                imageName: "art.scnassets/bee.png",
                                                lineColor: .green),
                                SatelliteParams(id: "27424",
                                                imageName: "art.scnassets/dolphin.png",
                                                lineColor: .blue),
                                SatelliteParams(id: "25544",
                                                imageName: "art.scnassets/astronaut.png",
                                                lineColor: .purple)]
        for satelliteParams in satellitesParams {
            getSatelliteAndLines(id: satelliteParams.id,
                                 imageName: satelliteParams.imageName,
                                 lineColor: satelliteParams.lineColor) { satellite, lines in
                scene.rootNode.addChildNode(satellite)
                for line in lines {
                    scene.rootNode.addChildNode(line)
                }
            }
        }
        sceneView.scene = scene
        
//        let tle: TLE
//        do {
//            tle = try TLE(name: "ISS",
//                          lineOne: "1 25544U 98067A   18077.09047010  .00001878  00000-0  35621-4 0  9999",
//                          lineTwo: "2 25544  51.6412 112.8495 0001928 208.4187 178.9720 15.54106440104358")
//            print(tle)
//        } catch {
//            print(error)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    private func getSatelliteAndLines(id: String,
                                      imageName: String,
                                      lineColor: UIColor,
                                      completionHandler: @escaping (_ satellite: SCNNode, _ lines: [SCNNode]) -> Void) {
        URLSession.shared.dataTask(with: URL(string: "http://192.168.1.34:3000/\(id)")!) { data, _, _ in
            let coordinatesWrapper = try? JSONDecoder().decode(CoordinatesWrapper.self, from: data!)
            let coordinates = coordinatesWrapper!.coordinates
            let satellite = self.createSatellite(coordinates: coordinates, imageName: imageName)
            let lines = self.createLines(coordinates: coordinates, color: lineColor)
            completionHandler(satellite, lines)
            }.resume()
    }
    
    private func createGlobe() -> SCNNode {
        let sphere = SCNSphere(radius: 0.2)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/snapshot-2019-10-18.jpg")
        sphere.firstMaterial = material
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3(0, 0, 0)
        return sphereNode
    }
    
    private func createSatellite(coordinates: [Coordinates], imageName: String) -> SCNNode {
        let node = SCNNode(geometry: SCNPlane(width: 0.1, height: 0.1))
        let sequence = coordinates.map {
            SCNAction.move(to: SCNVector3($0.x / scaleDivider,
                                          $0.y / scaleDivider,
                                          $0.z / scaleDivider),
                           duration: 0.1)
        }
        let actionSequence = SCNAction.repeatForever(.sequence(sequence))
        node.constraints = [SCNBillboardConstraint()]
        node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: imageName)
        node.runAction(actionSequence)
        return node
    }
    
    private func createLines(coordinates: [Coordinates], color: UIColor) -> [SCNNode] {
        var lineNodes: [SCNNode] = []
        for coordinateIndex in 0 ..< coordinates.count - 1 {
            if !coordinateIndex.isMultiple(of: 2) {
                continue
            }
            let currentCoordinate = coordinates[coordinateIndex]
            let nextCoordinate = coordinates[coordinateIndex + 1]
            let source = SCNGeometrySource(vertices: [SCNVector3(currentCoordinate.x / scaleDivider,
                                                                 currentCoordinate.y / scaleDivider,
                                                                 currentCoordinate.z / scaleDivider),
                                                      SCNVector3(nextCoordinate.x / scaleDivider,
                                                                 nextCoordinate.y / scaleDivider,
                                                                 nextCoordinate.z / scaleDivider)])
            let element = SCNGeometryElement(indices: [1, 0], primitiveType: .line)
            let geometry = SCNCylinder(sources: [source], elements: [element])
            let material = SCNMaterial()
            material.diffuse.contents = color
            geometry.firstMaterial = material
            let lineNode = SCNNode(geometry: geometry)
            lineNodes.append(lineNode)
        }
        return lineNodes
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
}

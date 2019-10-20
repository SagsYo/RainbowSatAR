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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
//        sceneView.showsStatistics = true
        sceneView.debugOptions = [.showBoundingBoxes, .showWorldOrigin]
        let scene = SCNScene()
        let globe = createGlobe()
        let auraSatellite = createAuraSatellite()
        scene.rootNode.addChildNode(globe)
        scene.rootNode.addChildNode(auraSatellite)
        URLSession.shared.dataTask(with: URL(string: "http://192.168.1.34:3000")!) { data, _, _ in
            let coordinatesWrapper = try? JSONDecoder().decode(CoordinatesWrapper.self, from: data!)
            let issSatellite = self.createIssSatellite(coordinates: coordinatesWrapper!.coordinates)
            scene.rootNode.addChildNode(issSatellite)
        }.resume()
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
    
    private func createGlobe() -> SCNNode {
        let sphere = SCNSphere(radius: 0.1)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/snapshot-2019-10-18.jpg")
        sphere.firstMaterial = material
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3(0, 0, 0)
        return sphereNode
    }
    
    private func createIssSatellite(coordinates: [Coordinates]) -> SCNNode {
        return createSatellite(coordinates: coordinates, imageName: "art.scnassets/COW_SAT.png")
    }
    
    private func createAuraSatellite() -> SCNNode {
        return createSatellite(coordinates: auraCoordinates(), imageName: "art.scnassets/bee.png")
    }
    
    private func createSatellite(coordinates: [Coordinates], imageName: String) -> SCNNode {
        let node = SCNNode(geometry: SCNPlane(width: 0.1, height: 0.1))
        let scaleDivider: Double = 30000
        let sequence = coordinates.map {
            SCNAction.move(to: SCNVector3($0.x / scaleDivider,
                                          $0.y / scaleDivider,
                                          $0.z / scaleDivider),
                           duration: 1)
        }
        let actionSequence = SCNAction.repeatForever(.sequence(sequence))
        node.constraints = [SCNBillboardConstraint()]
        node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: imageName)
        node.runAction(actionSequence)
        return node
    }
    
    private func createSatellite(coordinates: [(x: Double, y: Double, z: Double)], imageName: String) -> SCNNode {
        let node = SCNNode(geometry: SCNPlane(width: 0.1, height: 0.1))
        let scaleDivider: Double = 30000
        let sequence = coordinates.map {
            SCNAction.move(to: SCNVector3($0.x / scaleDivider,
                                          $0.y / scaleDivider,
                                          $0.z / scaleDivider),
                           duration: 1)
        }
        let actionSequence = SCNAction.repeatForever(.sequence(sequence))
        node.constraints = [SCNBillboardConstraint()]
        node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: imageName)
        node.runAction(actionSequence)
        return node
    }
    
    private func auraCoordinates() -> [(x: Double, y: Double, z: Double)] {
        return [(4175.1386847399945, 5103.473834123183, -2596.7573130501364),
            (4117.192297424878, 4923.778767118069, -3005.0297055665183),
            (4042.651028713853, 4724.2376716663, -3401.158484780311),
            (3951.82289883011, 4505.663817424097, -3783.548579615365),
            (3845.081320941498, 4268.9462440779325, -4150.662872919229),
            (3722.8635950898206, 4015.046466274278, -4501.027230859472),
            (3585.6689163264136, 3744.994256603818, -4833.236567287427),
            (3434.056188734125, 3459.8833072997168, -5145.960311774203),
            (3268.6416153337054, 3160.866667325456, -5437.947534526356),
            (3090.0960787578056, 2849.1519786632516, -5708.0317143737375),
            (2899.1423277770614, 2525.996535235377, -5955.135138713457),
            (2696.551984740701, 2192.702187255194, -6178.272926780426),
            (2483.1423887886303, 1850.6101129834938, -6376.556669827626),
            (2259.773289322239, 1501.0954788895608, -6549.197683726091),
            (2027.343245043265, 1145.5617680474027, -6695.509960247858),
            (1786.7866889808809, 785.4362336329802, -6814.9122623317135),
            (1539.0693182996235, 422.16290766628515, -6906.930790687951),
            (1285.184940914546, 57.197953963394404, -6971.200457862401),
            (1026.1514653777438, -307.99618863410836, -7007.466287594019),
            (763.0069689873126, -671.9564339253625, -7015.584315382175),
            (496.8057018727208, -1033.224668890878, -6995.522097732802),
            (228.61403737844324, -1390.3533529814913, -6947.358830364678),
            (-40.49362106519938, -1741.9110821394718, -6871.285075370248),
            (-309.438966371855, -2086.4881034314362, -6767.6020970408545),
            (-577.1439371815602, -2422.701765922014, -6636.720805816569),
            (-842.5350564382135, -2749.202108277837, -6479.160195220743),
            (-1104.5468837064573, -3064.6762674422534, -6295.545940668937),
            (-1362.1272359916338, -3367.8549610699993, -6086.607529498114),
            (-1614.2406022673267, -3657.516643969479, -5853.176037174234),
            (-1859.8724144912787, -3932.492624267814, -5596.181008916358),
            (-2098.0330889653387, -4191.671792230355, -5316.6470474322905),
            (-2327.7620017964573, -4434.005164121797, -5015.690013421662),
            (-2548.1313825107572, -4658.510220410649, -4694.512844030513),
            (-2758.2501090792002, -4864.275017032546, -4354.400996519573),
            (-2957.2673869364844, -5050.46204806941, -3996.7175267617513),
            (-3144.3762940400266, -5216.3118380999995, -3622.897814789408),
            (-3318.8172862304873, -5361.1463326149615, -3234.44368736794),
            (-3479.880959879696, -5484.371511196896, -2832.9185375570796),
            (-3626.9117874952626, -5585.4806253993465, -2419.939528880907),
            (-3759.3104668126143, -5664.056098310903, -1997.1721221916343),
            (-3876.5366437985385, -5719.77156217454, -1566.3230653457615),
            (-3978.11127357273, -5752.39340712785, -1129.133420159809),
            (-4063.6187252912487, -5761.7819321515335, -687.3714031490795),
            (-4132.708617167438, -5747.892087603363, -242.8250745637952),
            (-4185.097369473138, -5710.7738014775405, 202.70508784394488),
            (-4220.569465237424, -5650.57188447926, 647.413692376012),
            (-4238.978410407176, -5567.525512081633, 1089.4979752561037),
            (-4240.247382511466, -5461.967206636023, 1527.165632803807),
            (-4224.369581962712, -5334.32177878437, 1958.6411498737295),
            (-4191.408268484235, -5185.104135723748, 2382.174981791989),
            (-4141.496466446795, -5014.917383696766, 2796.0496766177785),
            (-4074.8363837650786, -4824.450212922611, 3198.587314989366),
            (-3991.698521434, -4614.473975642114, 3588.1564636019384),
            (-3892.4204875349205, -4385.839412048456, 3963.178904216328),
            (-3777.4055247711494, -4139.473044082368, 4322.136107360224),
            (-3647.12076221895, -3876.3732586641086, 4663.575422528776),
            (-3502.0952033777066, -3597.6061031716085, 4986.11595950727),
            (-3342.917463754158, -3304.3008168489528, 5288.454138349151),
            (-3170.233272119851, -2997.6451223625854, 5569.368888459371),
            (-2984.7426217272746, -2678.880084404461, 5827.726645539663)]
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

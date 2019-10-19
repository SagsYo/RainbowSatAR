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

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
//        sceneView.showsStatistics = true
        sceneView.debugOptions = [.showBoundingBoxes, .showWorldOrigin]
        let scene = SCNScene()
        let globe = createGlobe()
        let satellile = createSatellite()
        scene.rootNode.addChildNode(globe)
        scene.rootNode.addChildNode(satellile)
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
    
    private func createSatellite() -> SCNNode {
        let node = SCNNode(geometry: SCNPlane(width: 0.1, height: 0.1))
        let scaleDivider: Double = 30000
        let sequence = tles().map {
            SCNAction.move(to: SCNVector3($0.x / scaleDivider, $0.y / scaleDivider, $0.z / scaleDivider), duration: 1)
        }
        let actionSequence = SCNAction.sequence(sequence)
        node.constraints = [SCNBillboardConstraint()]
        node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/COW_SAT.png")
        node.runAction(actionSequence)
        return node
    }
    
    private func tles() -> [(x: Double, y: Double, z: Double)] {
        return [(4256.71988558714, 233.9667771815204, -5297.163528957276),
         (4172.478736445338, 684.2032513928972, -5325.509047266578),
         (4069.258481736479, 1131.3279099322149, -5329.561313019196),
         (3947.5314254285195, 1573.307076880308, -5309.30531322404),
         (3807.852857842979, 2008.1316240015299, -5264.835787041644),
         (3650.858846877661, 2433.8246176241646, -5196.356746489054),
         (3477.263368954648, 2848.4503349971365, -5104.180582911667),
         (3287.8551786954426, 3250.122815353846, -4988.726712335642),
         (3083.4943636524354, 3637.014216865067, -4850.519773163758),
         (2865.1085939664777, 4007.3629491120773, -4690.187379471534),
         (2633.6890776569758, 4359.481550104974, -4508.457434028625),
         (2390.2862332314658, 4691.764276294503, -4306.155006231794),
         (2136.0050925887035, 5002.694373292468, -4084.198781534975),
         (1872.0004485197828, 5290.850994625395, -3843.5970905203076),
         (1599.471577401138, 5554.915904146952, -3585.4433489293438),
         (1319.6576622458135, 5793.678899287049, -3310.9119826799115),
         (1033.8311788394362, 6006.04453898121, -3021.2522251510572),
         (743.2929248586512, 6191.036599038043, -2717.7832693843807),
         (449.36598511939707, 6347.802923431932, -2401.888224786619),
         (153.3897444313141, 6475.619545724258, -2075.0079171759107),
         (-143.28620494205933, 6573.894238090248, -1738.634390253221),
         (-439.30823253584197, 6642.169462611669, -1394.3041366958798),
         (-733.3248854970487, 6680.124702436163, -1043.591089736651),
         (-1023.9931195928215, 6687.578153793667, -688.0994085671521),
         (-1309.9845131146965, 6664.487763647392, -329.45609314738107),
         (-1589.9916162488425, 6610.951555827918, 30.696775708768705),
         (-1862.7332846827167, 6527.207495185456, 390.70868140148946),
         (-2126.961772048549, 6413.63229777861, 748.9297882140598),
         (-2381.4677897746387, 6270.739908384255, 1103.7176537420119),
         (-2625.086332591788, 6099.1791647187365, 1453.445120179776),
         (-2856.702103404636, 5899.730835081778, 1796.5078946705266),
         (-3075.254698600121, 5673.304020189074, 2131.3320193539384),
         (-3279.743526817843, 5420.931939912154, 2456.3811916118852),
         (-3469.232436322458, 5143.767129567376, 2770.16389645983),
         (-3642.8540284348355, 4843.076073936701, 3071.240314840449),
         (-3799.813636941982, 4520.233310310078, 3358.2289736955995),
         (-3939.393043578529, 4176.714797545026, 3629.8132827281916),
         (-4060.9533766312657, 3814.0919965568787, 3884.7468571099444),
         (-4163.9385556381685, 3434.023208443203, 4121.860306653299),
         (-4247.877398511123, 3038.2468206766252, 4340.06582181055),
         (-4312.385818389809, 2628.5730763469996, 4538.362296346127),
         (-4357.168519308089, 2206.8757623251736, 4715.839853641672),
         (-4382.020286831931, 1775.083632731375, 4871.683948156606),
         (-4386.826872133471, 1335.1716073805735, 5005.1790284953795),
         (-4371.565469558893, 889.1517843639532, 5115.711750682769),
         (-4336.304789131698, 439.0643052786464, 5202.773732176608),
         (-4281.204726623307, -13.03188908998489, 5265.963838849195),
         (-4206.515578264149, -465.068678161888, 5304.990016673668),
         (-4112.577131335619, -914.9769016505105, 5319.670538632731),
         (-3999.816851454862, -1360.6975330678351, 5309.935015080717),
         (-3868.748175250499, -1800.189782721572, 5275.824640776235),
         (-3719.968195966866, -2231.4406471059024, 5217.492110281812),
         (-3554.1550240403385, -2652.4740483382443, 5135.201011041862),
         (-3372.0647874550605, -3061.3598312939134, 5029.324728373727),
         (-3174.5282811812303, -3456.2225823507015, 4900.344863370819),
         (-2962.447276090117, -3835.25023317639, 4748.84916593042),
         (-2736.7904989994654, -4196.702412454613, 4575.528986529473),
         (-2498.5892969402316, -4538.918507922779, 4381.176252013764),
         (-2248.933000358615, -4860.325400654346, 4166.679972567224),
         (-1988.9638242520384, -5159.44502603073, 3933.0221263337526)]
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

//
//  GameViewController.swift
//  gameVebinar
//
//  Created by Марк Мирзоян on 23.09.2020.
//  Copyright © 2020 Марк Мирзоян. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var count = 0 {
        didSet {
            scoreLabel.text = "Очки: \(count)"
        }
    }
    var duration: TimeInterval = 5
    var gameOver = false {
        didSet {
            DispatchQueue.main.async {
                self.scoreLabel.numberOfLines = 2
                self.scoreLabel.text = "Игра окончена\nОчки: \(self.count)"
            }
        }
    }
    var scene: SCNScene!
    var ship: SCNNode!
    
    func spawnShip() {
        ship = SCNScene(named: "art.scnassets/ship.scn")!.rootNode.clone()
        
        // Add ship to the scene
        scene.rootNode.addChildNode(ship)
        
        // Position the ship
        let x = Int.random(in: -25...25)
        let y = Int.random(in: -25...25)
        let z = -105
        ship.position = SCNVector3(x, y, z)
        
        //Look at position
        ship.look(at: SCNVector3(2 * x, 2 * y, 2 * z))
        
        // Animate the ship
        ship.runAction(.move(to: SCNVector3(), duration: duration)) {
            self.gameOver = true
            self.removeShip()
        }
        
        duration *= 0.9
    }

    func removeShip() {
        scene.rootNode.childNode(withName: "ship", recursively: true)?.removeFromParentNode()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        count = 0
        
        // create a new scene
        scene = SCNScene(named: "art.scnassets/ship.scn")!
        removeShip()
        spawnShip()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
     //   let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        
        // animate the 3d object
    //    ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        // retrieve the SCNView
//        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        if gameOver { return }
        // retrieve the SCNView
//        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.25
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                self.count += 1 
                self.ship.removeAllActions()
                self.removeShip()
                self.spawnShip()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}

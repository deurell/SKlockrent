//
//  MenuViewController.swift
//  SKlockrent
//
//  Created by Mikael Deurell on 2021-02-17.
//

import UIKit
import QuartzCore
import SceneKit
import simd

class MenuViewController: UIViewController, SCNSceneRendererDelegate {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let scene = SCNScene()
    let cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    scene.rootNode.addChildNode(cameraNode)
    cameraNode.position = SCNVector3(x: 0, y: 0, z: 16)
    
    let lightNode = SCNNode()
    lightNode.light = SCNLight()
    lightNode.light!.type = .omni
    lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
    scene.rootNode.addChildNode(lightNode)
    
    let ambientLightNode = SCNNode()
    ambientLightNode.light = SCNLight()
    ambientLightNode.light!.type = .ambient
    ambientLightNode.light!.color = UIColor.darkGray
    scene.rootNode.addChildNode(ambientLightNode)
    
    let text = SCNText(string: "Push!", extrusionDepth: 0)
    text.font = UIFont(name: "Commodore-64-Rounded", size: 7)
    text.firstMaterial?.diffuse.contents = UIColor.black
    let scrollNode = SCNNode()
    scrollNode.geometry = text
    scrollNode.simdScale = [0.2,0.2,0.2]
    scrollNode.simdPosition = [-2.5,0,0]
    scene.rootNode.addChildNode(scrollNode)
  
    let scnView = self.view as! SCNView
    scnView.scene = scene
    scnView.allowsCameraControl = false
    scnView.backgroundColor = UIColor.white
    scnView.delegate = self
    scnView.isPlaying = true
    
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    scnView.addGestureRecognizer(tapRecognizer)
  }
    
  @objc
  func handleTap(_ tapGesture: UITapGestureRecognizer) {
    if (tapGesture.state == .ended) {
      print("tap!")
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let vc = storyboard.instantiateViewController(withIdentifier: "GameViewController")
      //self.present(vc, animated: true, completion: nil)
      self.show(vc, sender: self)
    }
  }
  
  override var shouldAutorotate: Bool {
    return false
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }
}

//
//  MenuStage.swift
//  SKlockrent
//
//  Created by Mikael Deurell on 2021-03-15.
//

import Foundation
import SceneKit

class MenuStage : Renderer
{
  var state: SceneState = .active
  
  var scene: SCNScene
  var _view: SCNView
  
  init(view: SCNView) {
    _view = view
    scene = SCNScene()
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
  
    _view.backgroundColor = UIColor.white
    
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    _view.addGestureRecognizer(tapRecognizer)
  }
  
  @objc
  func handleTap(_ tapGesture: UITapGestureRecognizer) {
    if (tapGesture.state == .ended) {
      print("tap!")
      state = .done
    }
  }
  
  func update(delta: Double) {
    
  }
  
  
}

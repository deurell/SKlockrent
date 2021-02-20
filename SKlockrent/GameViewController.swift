//
//  GameViewController.swift
//  SKlockrent
//
//  Created by Mikael Deurell on 2021-02-17.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
  
  var hourNode:SCNNode?
  var minuteNode:SCNNode?
  var clockNode:SCNNode?
  var isAnimating:Bool = false
  var trackedHandNode:SCNNode?
  static let HAND_SCALE:simd_float3 = [0.4,0.4,1.0]
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let scene = SCNScene()
    
    let cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    scene.rootNode.addChildNode(cameraNode)
    
    cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
    
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
    
    clockNode = SCNNode()
    clockNode?.name = "clock"
    clockNode?.position = SCNVector3(x:0, y:0, z:3)
    clockNode?.pivot = SCNMatrix4MakeTranslation(0, 1.1, 0)
    clockNode?.simdScale = [3.0,3.0,3.0]
    if let modelScene = SCNScene(named: "assets.scnassets/AlarmClock.scn") {
      clockNode?.addChildNode(modelScene.rootNode.childNode(withName: "AlarmClock", recursively: true)!)
    }
    if let clock = clockNode {
      scene.rootNode.addChildNode(clock)
    }
    hourNode = SCNNode()
    hourNode?.name = "hour"
    let hourPlane = SCNPlane(width: 0.5, height: 2)
    hourNode?.geometry = hourPlane
    hourNode?.position = SCNVector3(x:0, y:1.1, z:0.6)
    hourNode?.pivot = SCNMatrix4MakeTranslation(0, -0.7, 0)
    hourNode?.simdScale = GameViewController.HAND_SCALE
    hourPlane.firstMaterial?.diffuse.contents = UIImage(named: "hourhand")
    clockNode?.addChildNode(hourNode!)
    
    minuteNode = SCNNode()
    minuteNode?.name = "minute"
    let minutePlane = SCNPlane(width: 0.5, height: 1.8)
    minuteNode?.geometry = minutePlane
    minuteNode?.position = SCNVector3(x:0, y:1.1, z:0.9)
    minuteNode?.pivot = SCNMatrix4MakeTranslation(0, -0.7, 0)
    minuteNode?.simdScale = GameViewController.HAND_SCALE
    minutePlane.firstMaterial?.diffuse.contents = UIImage(named: "minutehand")
    clockNode?.addChildNode(minuteNode!)
    
    let scnView = self.view as! SCNView
    scnView.scene = scene
    scnView.allowsCameraControl = false
    scnView.backgroundColor = UIColor.white
    
    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
    longPressGesture.allowableMovement = 1000
    longPressGesture.minimumPressDuration = 0
    scnView.addGestureRecognizer(longPressGesture)
  }
  
  @objc
  func handleLongPress(_ longPressGesture: UILongPressGestureRecognizer) {
    guard let scnView = self.view as? SCNView else { return }
    let screenspaceTapLocation = longPressGesture.location(in: scnView)
    let hitResult = scnView.hitTest(screenspaceTapLocation, options: [SCNHitTestOption.firstFoundOnly : true])
    
    if let hit = hitResult.first {
      let node = hit.node
      if (node.name == "hour" || node.name == "minute") {
        switch longPressGesture.state {
        case .began:
          // we are starting to drag, set up dragging state
          trackedHandNode = node
          let scaleUp = SCNAction.scale(by: 1.1, duration: 0.2)
          scaleUp.timingMode = .easeInEaseOut
          node.runAction(SCNAction.sequence([scaleUp, scaleUp.reversed()]), completionHandler: {
            node.simdScale = GameViewController.HAND_SCALE
          })
        case .changed:
          break
        default:
          // we are ending drag so just reset everything and end drag state
          trackedHandNode = nil
        }
      }
      if (node.name == "clock" && trackedHandNode == nil && !isAnimating) {
        isAnimating = true
        let translate = SCNAction.moveBy(x: 0, y: 0, z: -20, duration: 0.5)
        translate.timingMode = .easeInEaseOut
	
        node.runAction(SCNAction.sequence([translate, translate.reversed()]),completionHandler: {
          node.simdRotation = [0,0,0,0]
          self.isAnimating = false
        })
        
      }
    }
    if let node = trackedHandNode {
      // we are dragging so get the angle and rotate
      guard let touch = hitResult.first?.simdWorldCoordinates else { return }
      let clock = clockNode!.simdWorldPosition + [0,1,0]
      let delta = touch - clock
      let rad = atan2(delta.x, delta.y)
      node.eulerAngles = SCNVector3Make(0, 0, -rad);
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

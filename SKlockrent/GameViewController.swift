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
  var isAnimating:Bool = false
  var isPanning:Bool = false
  var lastPanWorldLocation:SCNVector3 = SCNVector3(0,0,0)
  var screenSpaceViewZ:CGFloat = 0
  var currentlyPannedNode: SCNNode?
  var draggedNode:SCNNode?
  var lastDragWorldPosition:SCNVector3 = SCNVector3()
  
  
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
    
    let clockNode = SCNNode()
    clockNode.name = "clock"
    let plane = SCNPlane(width: 9, height: 9)
    clockNode.geometry = plane
    clockNode.position = SCNVector3(x:0, y:0, z:5)
    plane.firstMaterial?.diffuse.contents = UIImage(named: "clock")
    scene.rootNode.addChildNode(clockNode)
    
    hourNode = SCNNode()
    hourNode?.name = "hour"
    let hourPlane = SCNPlane(width: 0.5, height: 2)
    hourNode?.geometry = hourPlane
    hourNode?.position = SCNVector3(x:0, y:0, z:0.2)
    hourNode?.pivot = SCNMatrix4MakeTranslation(0, -0.7, 0)
    hourPlane.firstMaterial?.diffuse.contents = UIImage(named: "hourhand")
    clockNode.addChildNode(hourNode!)
    
    minuteNode = SCNNode()
    minuteNode?.name = "minute"
    let minutePlane = SCNPlane(width: 0.5, height: 2.8)
    minuteNode?.geometry = minutePlane
    minuteNode?.position = SCNVector3(x:0, y:0, z:0.1)
    minuteNode?.pivot = SCNMatrix4MakeTranslation(0, -1.1, 0)
    minutePlane.firstMaterial?.diffuse.contents = UIImage(named: "minutehand")
    clockNode.addChildNode(minuteNode!)
    
    let scnView = self.view as! SCNView
    scnView.scene = scene
    scnView.allowsCameraControl = false
    scnView.backgroundColor = UIColor.white
    
    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
    longPressGesture.allowableMovement = 1000
    longPressGesture.minimumPressDuration = 0
    scnView.addGestureRecognizer(longPressGesture)
  }
  
  
  var handPosWorld:simd_float3 = [0,0,0]
  var touchPosWorld:simd_float3 = [0,0,0]
  var touchHandDist:simd_float3 = [0,0,0]
  
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
          draggedNode = node
          screenSpaceViewZ = CGFloat(scnView.projectPoint(hit.worldCoordinates).z)
          lastDragWorldPosition = hit.worldCoordinates
          let scaleUp = SCNAction.scale(by: 1.1, duration: 0.2)
          scaleUp.timingMode = .easeInEaseOut
          node.runAction(SCNAction.sequence([scaleUp, scaleUp.reversed()]), completionHandler: {
            node.simdScale = [1,1,1]
          })
          handPosWorld = node.simdPosition
          touchPosWorld = hit.simdWorldCoordinates
          touchHandDist = handPosWorld - touchPosWorld
          
        case .changed:
          break
        default:
          // we are ending drag so just reset everything and end drag state
          draggedNode = nil
          self.lastDragWorldPosition = SCNVector3(0,0,0);
        }
      }
      if (node.name == "clock" && draggedNode == nil) {
        isAnimating = true
        let rotate = SCNAction.rotateTo(x: CGFloat(-Float.pi/4), y: 0, z: 0, duration: 0.5, usesShortestUnitArc: false)
        rotate.timingMode = SCNActionTimingMode.easeInEaseOut
        node.runAction(SCNAction.sequence([rotate, rotate.reversed()]),completionHandler: {
          node.simdRotation = [0,0,0,0]
          self.isAnimating = false
        })
        
      }
    }
    if let node = draggedNode {
      // we are dragging so get the angle and rotate
      let scHand = scnView.projectPoint(node.position)
      let hand:simd_float2 = [Float(scHand.x), Float(scHand.y)]
      let touch:simd_float2 = simd_float2(Float(screenspaceTapLocation.x), Float(screenspaceTapLocation.y))
      let delta = touch - hand
      let rad = atan2(delta.x, delta.y)
      node.eulerAngles = SCNVector3Make(0, 0, rad - Float.pi);
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

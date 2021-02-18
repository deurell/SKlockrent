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
  
  var hourNode: SCNNode?
  var minuteNode: SCNNode?
  var isAnimating:Bool = false
  var isPanning:Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // create a new scene
    let scene = SCNScene()
    
    // create and add a camera to the scene
    let cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    scene.rootNode.addChildNode(cameraNode)
    
    // place the camera
    cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
    
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
    
    let clockNode = SCNNode()
    let plane = SCNPlane(width: 9, height: 9)
    clockNode.geometry = plane
    clockNode.position = SCNVector3(x:0, y:0, z:5)
    plane.firstMaterial?.diffuse.contents = UIImage(named: "clock")
    scene.rootNode.addChildNode(clockNode)
    
    hourNode = SCNNode()
    hourNode?.name = "hour"
    let hourPlane = SCNPlane(width: 0.5, height: 2)
    hourNode!.geometry = hourPlane
    hourNode!.position = SCNVector3(x:0, y:0, z:5.2)
    hourNode!.pivot = SCNMatrix4MakeTranslation(0, -0.7, 0)
    hourPlane.firstMaterial?.diffuse.contents = UIImage(named: "hourhand")
    scene.rootNode.addChildNode(hourNode!)
    
    minuteNode = SCNNode()
    minuteNode?.name = "minute"
    let minutePlane = SCNPlane(width: 0.5, height: 2.8)
    minuteNode!.geometry = minutePlane
    minuteNode!.position = SCNVector3(x:0, y:0, z:5.1)
    minuteNode!.pivot = SCNMatrix4MakeTranslation(0, -1.1, 0)
    minutePlane.firstMaterial?.diffuse.contents = UIImage(named: "minutehand")
    scene.rootNode.addChildNode(minuteNode!)
    
    
    // retrieve the SCNView
    let scnView = self.view as! SCNView
    
    // set the scene to the view
    scnView.scene = scene
    
    scnView.allowsCameraControl = true
    //scnView.showsStatistics = true
    
    // configure the view
    scnView.backgroundColor = UIColor.white
    
    // add a tap gesture recognizer
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    scnView.addGestureRecognizer(tapGesture)
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    scnView.addGestureRecognizer(panGesture)
  }
  
  var lastPanLocation:SCNVector3 = SCNVector3(0,0,0)
  var screenSpaceViewZ:CGFloat = 0
  var node: SCNNode?
  
  @objc
  func handlePan(_ panGesture: UIPanGestureRecognizer) {
    guard let view = view as? SCNView else { return }
    let screenSpaceLocation = panGesture.location(in: view)
    switch panGesture.state {
    case .began:
      guard let hitNodeResult = view.hitTest(screenSpaceLocation, options: [SCNHitTestOption.firstFoundOnly : true]).first else { return }
      node = hitNodeResult.node
      screenSpaceViewZ = CGFloat(view.projectPoint(lastPanLocation).z)
      lastPanLocation = hitNodeResult.worldCoordinates
    case .changed:
      // This entire case has been replaced
      let worldTouchPosition = view.unprojectPoint(SCNVector3(screenSpaceLocation.x, screenSpaceLocation.y, screenSpaceViewZ))
      let translate = SCNVector3(
        worldTouchPosition.x - lastPanLocation.x,
        worldTouchPosition.y - lastPanLocation.y,
        0)
      node?.localTranslate(by: translate)
      self.lastPanLocation = worldTouchPosition
    default:
      node = nil
      break
    }
  }
  
  @objc
  func handleTap(_ gestureRecognize: UIGestureRecognizer) {
    // retrieve the SCNView
    let scnView = self.view as! SCNView
    
    // check what nodes are tapped
    let p = gestureRecognize.location(in: scnView)
    let hitResults = scnView.hitTest(p, options: [SCNHitTestOption.firstFoundOnly : true])
    
    if (hitResults.count > 0) {
      let firstHit = hitResults.first
      let node = firstHit!.node
      if (node.name == "hour" || node.name == "minute") {
        let scaleUp = SCNAction.scale(by: 2.0, duration: 0.5)
        scaleUp.timingMode = .easeInEaseOut
        node.runAction(SCNAction.sequence([scaleUp, scaleUp.reversed()]), completionHandler: {
          node.simdScale = [1,1,1]
        })
      }
    }
    
    if (hitResults.count > 0 && !isAnimating) {
      isAnimating = true
      minuteNode!.runAction(SCNAction.rotateTo(x: 0, y: 0, z: CGFloat(Float.pi*2), duration: 1.5), completionHandler: {
        self.minuteNode?.simdEulerAngles = [0,0,0]
      })
      hourNode!.runAction(SCNAction.rotateTo(x: 0, y: 0, z: CGFloat(-Float.pi*2), duration: 1.5), completionHandler: {
        self.hourNode?.simdEulerAngles = [0,0,0]
        self.isAnimating = false
      })
      
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

//
//  GameViewController.swift
//  SKlockrent
//
//  Created by Mikael Deurell on 2021-02-17.
//

import UIKit
import QuartzCore
import SceneKit
import simd

class GameViewController: UIViewController, SCNSceneRendererDelegate {
  
  var _hourNode:SCNNode = SCNNode()
  var _minuteNode:SCNNode = SCNNode()
  var _clockNode:SCNNode?
  var _isAnimating:Bool = false
  var _trackedHandNode:SCNNode?
  var _startTime:Double = 0
  var _previousUpdate:Double = 0
  
  var _scroller:Scroller?
  
  static let hand_scale:simd_float3 = [0.4,0.4,1.0]
  
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
    
    if let modelScene = SCNScene(named: "assets.scnassets/AlarmClock.scn") {
      guard let node = modelScene.rootNode.childNode(withName: "AlarmClock", recursively: true) else { return }
      node.name = "clock"
      node.position = SCNVector3(x:0, y:1.2, z:1)
      node.pivot = SCNMatrix4MakeTranslation(0, 1.1, 0)
      node.simdScale = [3.0,3.0,3.0]
      _clockNode = node
      scene.rootNode.addChildNode(node)
    }
    
    _hourNode.name = "hour"
    let hourPlane = SCNPlane(width: 0.5, height: 2)
    _hourNode.geometry = hourPlane
    _hourNode.position = SCNVector3(x:0, y:1.1, z:0.61)
    _hourNode.pivot = SCNMatrix4MakeTranslation(0, -0.7, 0)
    _hourNode.simdScale = GameViewController.hand_scale
    hourPlane.firstMaterial?.diffuse.contents = UIImage(named: "hourhand")
    _clockNode?.addChildNode(_hourNode)
    
    _minuteNode.name = "minute"
    let minutePlane = SCNPlane(width: 0.5, height: 1.8)
    _minuteNode.geometry = minutePlane
    _minuteNode.position = SCNVector3(x:0, y:1.1, z:0.6)
    _minuteNode.pivot = SCNMatrix4MakeTranslation(0, -0.7, 0)
    _minuteNode.simdScale = GameViewController.hand_scale
    minutePlane.firstMaterial?.diffuse.contents = UIImage(named: "minutehand")
    _clockNode?.addChildNode(_minuteNode)
    
    _scroller = Scroller(scene: scene, position: [0,-8,-2])
    
    let scnView = self.view as! SCNView
    scnView.scene = scene
    scnView.allowsCameraControl = false
    scnView.backgroundColor = UIColor.white
    scnView.delegate = self
    scnView.isPlaying = true
    
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
          _trackedHandNode = node
          let scaleUp = SCNAction.scale(by: 1.1, duration: 0.2)
          let seq = SCNAction.sequence([scaleUp, scaleUp.reversed()])
          seq.timingMode = .easeInEaseOut
          node.runAction(seq, completionHandler: {
            node.simdScale = GameViewController.hand_scale
          })
        case .changed:
          break
        default:
          // we are ending drag so just reset everything and end drag state
          _trackedHandNode = nil
        }
      }
      if (node.name == "clock" && _trackedHandNode == nil && !_isAnimating) {
        _isAnimating = true
        let translate = SCNAction.moveBy(x: 0, y: -20, z: -80, duration: 1.0)
        let rotate = SCNAction.rotateBy(x: CGFloat(Float.pi/2), y: 0, z: 0, duration: 1.0)
        let par = SCNAction.group([translate, rotate])
        par.timingFunction = { time in
          return simd_smoothstep(0, 1, time)
        }
        node.runAction(SCNAction.sequence([par, par.reversed()]),completionHandler: {
          self._isAnimating = false
        })
      }
    }
    if let node = _trackedHandNode {
      // we are dragging so get the angle and rotate
      guard let touch = hitResult.first?.simdWorldCoordinates else { return }
      let clock = _clockNode!.simdWorldPosition + [0,1,0]
      let delta = touch - clock
      let rad = atan2(delta.x, delta.y)
      node.eulerAngles = SCNVector3Make(0, 0, -rad);
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    if (_previousUpdate == 0) {
      _previousUpdate = time
      _startTime = time
    }
    let delta = time - _previousUpdate
    _previousUpdate = time
    
    _scroller?.update(delta: delta)
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

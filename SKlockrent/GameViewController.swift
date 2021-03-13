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
  
  var hourNode:SCNNode = SCNNode()
  var minuteNode:SCNNode = SCNNode()
  var clockNode:SCNNode?
  var logoNode:SCNNode = SCNNode()
  var isAnimating:Bool = false
  var trackedHandNode:SCNNode?
  var startTime:Double = 0
  var previousUpdate:Double = 0
  var scrollOffset:Double = 0
  var logo:SCNText?
  
  static let HAND_SCALE:simd_float3 = [0.4,0.4,1.0]
  
  
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
      clockNode = node
      scene.rootNode.addChildNode(node)
    }
    
    hourNode.name = "hour"
    let hourPlane = SCNPlane(width: 0.5, height: 2)
    hourNode.geometry = hourPlane
    hourNode.position = SCNVector3(x:0, y:1.1, z:0.61)
    hourNode.pivot = SCNMatrix4MakeTranslation(0, -0.7, 0)
    hourNode.simdScale = GameViewController.HAND_SCALE
    hourPlane.firstMaterial?.diffuse.contents = UIImage(named: "hourhand")
    clockNode?.addChildNode(hourNode)
    
    minuteNode.name = "minute"
    let minutePlane = SCNPlane(width: 0.5, height: 1.8)
    minuteNode.geometry = minutePlane
    minuteNode.position = SCNVector3(x:0, y:1.1, z:0.6)
    minuteNode.pivot = SCNMatrix4MakeTranslation(0, -0.7, 0)
    minuteNode.simdScale = GameViewController.HAND_SCALE
    minutePlane.firstMaterial?.diffuse.contents = UIImage(named: "minutehand")
    clockNode?.addChildNode(minuteNode)
    
    let logoText = """
      Klockrent tillverkades under tiden Deurell Labs kompilerande C++ kod för andra projekt. Vi tjänar inga pengar på detta, spelet innehåller ingen reklam eller köp och vi kommer aldrig på någ sätt spara uppgifter om användaren. Ever! Ha en fin dag och ta hand om varandra...
    """
    logo = SCNText(string: logoText, extrusionDepth: 0)
    logo?.font = UIFont(name: "Commodore-64-Rounded", size: 7)
    logoNode.geometry = logo
    logoNode.simdScale = [0.2,0.2,0.2]
    logoNode.simdPosition = [-5,-8,-2]
    let vertShader = """
      uniform float scroll_offset;
      float d = _geometry.position.x;
      _geometry.position.y += (8.0 * sin(-4.0 * u_time + 0.08*d));
      _geometry.position.x -= (14.0 * scroll_offset);
    """
    let fragShader = """
        #pragma body
        float iTime = scn_frame.time;
        float3 lb64 = float3(.0, 136.0/255.0, 1.0);
        float3 b64 = float3(.0, .0, 170.0/255.0);
        _output.color.rgba = float4(mix(b64,lb64,abs(sin(2.0*iTime))), 1.0);
    """
    logo?.shaderModifiers = [.geometry: vertShader ,.fragment: fragShader]
    logo?.setValue(0.0, forKey: "scroll_offset")
    scene.rootNode.addChildNode(logoNode)
    
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
          trackedHandNode = node
          let scaleUp = SCNAction.scale(by: 1.1, duration: 0.2)
          let seq = SCNAction.sequence([scaleUp, scaleUp.reversed()])
          seq.timingMode = .easeInEaseOut
          node.runAction(seq, completionHandler: {
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
        let translate = SCNAction.moveBy(x: 0, y: -20, z: -80, duration: 1.0)
        let rotate = SCNAction.rotateBy(x: CGFloat(Float.pi/2), y: 0, z: 0, duration: 1.0)
        let par = SCNAction.group([translate, rotate])
        par.timingFunction = { time in
          return simd_smoothstep(0, 1, time)
        }
        node.runAction(SCNAction.sequence([par, par.reversed()]),completionHandler: {
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
  
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    if (previousUpdate == 0) {
      previousUpdate = time
      startTime = time
    }
    
    let delta = time - previousUpdate
    previousUpdate = time
    
    scrollOffset += delta
    if (scrollOffset >= 109.0) {
      scrollOffset = 0
    }
    logo?.setValue(scrollOffset, forKey: "scroll_offset")
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

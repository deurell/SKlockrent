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
  var state: SceneState = .initializing
  
  var scene: SCNScene
  var _view: SCNView
  var _scroller:Scroller?
  var _scroller2:Scroller?
  var _gameOne: SCNNode?
  var _gameTwo: SCNNode?
  var _gameThree: SCNNode?
  
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
    
    _gameOne = createLabel(string: "Lätt", position: [-2.2,2,0], fromCol: [0, 0, 0], toCol: [0.73,0.73,0.73], offset: 0.0)
    scene.rootNode.addChildNode(_gameOne!)

    _gameTwo = createLabel(string: "Medel", position: [-2.55,0,0], fromCol: [0, 0, 0], toCol: [0.73,0.73,0.73], offset: -1.5)
    scene.rootNode.addChildNode(_gameTwo!)

    _gameThree = createLabel(string: "Svårt", position: [-2.6,-2,0], fromCol: [0, 0, 0], toCol: [0.73,0.73,0.73],offset: -3.0)
    scene.rootNode.addChildNode(_gameThree!)

    _scroller = Scroller(scene: scene,
                         position: [0, 7, -4],
                         scrollText: "Klockrent   innehåller ingen reklam eller dolda köp och vi kommer aldrig någonsin spara/spåra uppgifter om användaren. Ha en fin dag och ta hand om varandra...       *wrap*       ",
                         twist: 1.5)
    if let scroller = _scroller {
      scroller._timeline = [
        SpeedCommand(time: 0.0, scroller: scroller, speed: 75),
        SpeedCommand(time: 1.0, scroller: scroller, speed: 0),
        SpeedCommand(time: 3.0, scroller: scroller, speed: 16),
        WrapCommand(time: 64.0, scroller: scroller)
      ]
    }
    
    _scroller2 = Scroller(scene: scene,
                         position: [0, -7, -4],
                         scrollText: "Lätt är hela timmar. Medel tar med halvtimmar och svårt tar även med kvart i/över. Ha det kul, och öva massor!  <3 <3 <3     ",
                         twist: 0.5)
    if let scroller = _scroller2 {
      scroller._timeline = [
        SpeedCommand(time: 0.0, scroller: scroller, speed: 0),
        SpeedCommand(time: 1.5, scroller: scroller, speed: 22),
        WrapCommand(time: 40.0, scroller: scroller)
      ]
    }
  
    _view.backgroundColor = UIColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    _view.addGestureRecognizer(tapRecognizer)
    state = .active
  }
  
  func createLabel(string: String, position: simd_float3, fromCol: simd_float3, toCol: simd_float3, offset: Float) -> SCNNode {
    let text = SCNText(string: string, extrusionDepth: 0)
    text.firstMaterial?.diffuse.contents = UIColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    text.font = UIFont(name: "Commodore-64-Rounded", size: 7)

    let fragShader = """
        #pragma arguments
        float3 from_col;
        float3 to_col;
        float offset;

        #pragma body
        float iTime = scn_frame.time;
        float2 uv = _surface.diffuseTexcoord;
        _output.color.rgba = float4(mix(from_col,to_col,0.5*sin(2.0*iTime + offset)), 1.0);
    """
    text.shaderModifiers = [.fragment: fragShader]
    let from = NSValue(scnVector3: SCNVector3(fromCol))
    let to = NSValue(scnVector3: SCNVector3(toCol))
    
    text.setValue(from, forKey: "from_col")
    text.setValue(to, forKey: "to_col")
    text.setValue(offset, forKey: "offset")
    
    let textNode = SCNNode()
    textNode.geometry = text
    textNode.simdScale = [0.2,0.2,0.2]
    textNode.simdPosition = position
    return textNode
  }
  
  @objc
  func handleTap(_ tapGesture: UITapGestureRecognizer) {
    if (tapGesture.state == .ended) {
      print("tap!")
      state = .done
    }
  }
  
  func update(delta: Double) {
    _scroller?.update(delta: delta)
    _scroller2?.update(delta: delta)
  }
  
  
}

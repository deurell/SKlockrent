//
//  Scroller.swift
//  SKlockrent
//
//  Created by Mikael Deurell on 2021-03-14.
//

import Foundation
import SceneKit
import simd


protocol TimelineCommand {
  var isDone:Bool { get }
  var time:Double { get }
  func shouldRun(time:Double) -> Bool
  func execute(delta:Double)
}

class WrapCommand : TimelineCommand
{
  var time: Double
  let scroller: Scroller
  var isDone: Bool = false
  
  init(time:Double, scroller:Scroller) {
    self.time = time
    self.scroller = scroller
  }
  
  func shouldRun(time:Double) -> Bool {
    return time >= self.time && isDone == false
  }
  
  func execute(delta:Double) {
    scroller._time = 0
    self.isDone = true
  }
}

class Scroller
{
  
  let wrap_time:Double = 92.0
  
  let _scene:SCNScene
  let _text:SCNText
  let _scrollNode:SCNNode
  var _time:Double = 0

  var _timelineOffset = 0
  var _timeline:[TimelineCommand]?

  init(scene: SCNScene, position: simd_float3, scrollText:String) {
    _scene = scene
    _text = SCNText(string: scrollText, extrusionDepth: 0)
    _text.font = UIFont(name: "Commodore-64-Rounded", size: 7)
    _scrollNode = SCNNode()
    _scrollNode.geometry = _text
    _scrollNode.simdScale = [0.2,0.2,0.2]
    _scrollNode.simdPosition = position
    let vertShader = """
      uniform float scroll_offset;
      float d = _geometry.position.x;
      _geometry.position.y += (8.0 * sin(-4.0 * u_time + 0.08*d));
      _geometry.position.x -= (14.0 * scroll_offset - 50);
    """
    let fragShader = """
        #pragma body
        float iTime = scn_frame.time;
        float3 lb64 = float3(.0, 136.0/255.0, 1.0);
        float3 b64 = float3(.0, .0, 170.0/255.0);
        _output.color.rgba = float4(mix(b64,lb64,abs(sin(2.0*iTime))), 1.0);
    """
    _text.shaderModifiers = [.geometry: vertShader ,.fragment: fragShader]
    _text.setValue(0.0, forKey: "scroll_offset")
    scene.rootNode.addChildNode(_scrollNode)
  }
  
  func update(delta:Double) {
    _time += delta
  
    if let timeline = _timeline {
    let currentAction = timeline[_timelineOffset]
      if (currentAction.shouldRun(time: _time)) {
        currentAction.execute(delta: delta)
      }
    }
    
    _text.setValue(_time, forKey: "scroll_offset")
  }
}

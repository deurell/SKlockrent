//
//  Scroller.swift
//  SKlockrent
//
//  Created by Mikael Deurell on 2021-03-14.
//

import Foundation
import SceneKit
import simd


class TimelineCommand {
  
  var isDone:Bool = false
  var time:Double = 0
  var scroller: Scroller
  
  init(time:Double, scroller:Scroller) {
    self.time = time
    self.scroller = scroller
  }
  
  func shouldRun(time:Double) -> Bool {
    return time >= self.time && isDone == false
  }
  
  func execute(delta:Double) {
    fatalError("no execute implementation on command")
  }
  
  func reset() {
    isDone = false
  }
}

class WrapCommand : TimelineCommand
{
  override init(time: Double, scroller: Scroller) {
    super.init(time: time, scroller: scroller)
  }
  
  override func execute(delta:Double) {
    scroller._scrollOffset = 0
    self.isDone = true
  }
}

class SpeedCommand : TimelineCommand
{
  var speed:Double
  
  init(time: Double, scroller: Scroller, speed:Double) {
    self.speed = speed
    super.init(time: time, scroller: scroller)
  }
  
  override func execute(delta: Double) {
    scroller._speed = speed
    isDone = true
  }
}

class Scroller
{
  let _scene:SCNScene
  let _text:SCNText
  let _scrollNode:SCNNode
  var _time:Double = 0
  var _scrollOffset:Double = 0
  var _speed:Double = 16
  
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
      _geometry.position.x = _geometry.position.x - scroll_offset + 50;
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
    _scrollOffset = _scrollOffset + (delta * _speed)
    
    if let timeline = _timeline {
    let currentAction = timeline[_timelineOffset]
      if (currentAction.shouldRun(time: _time)) {
        currentAction.execute(delta: delta)
        _timelineOffset+=1
        if (_timelineOffset > timeline.count-1) {
          _timelineOffset = 0
          for command in self._timeline! {
            command.reset()
            self._time = 0
          }
        }
      }
    }
    _text.setValue(_scrollOffset, forKey: "scroll_offset")
  }
}

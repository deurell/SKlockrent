//
//  Scroller.swift
//  SKlockrent
//
//  Created by Mikael Deurell on 2021-03-14.
//

import Foundation
import SceneKit
import simd

class Scroller
{
  let _scene:SCNScene
  let _text:SCNText
  let _scrollNode:SCNNode
  var _scrollOffset:Double = 0
  
  let _scrollText = "Klockrent innehåller ingen reklam eller dolda köp och vi kommer aldrig på något sätt spara/spåra uppgifter om användaren. Ever! Ha en fin dag och ta hand om varandra...       *wrap*       "
  
  let wrap_time:Double = 100.0
  
  init(scene: SCNScene, position: simd_float3) {
    _scene = scene
    _text = SCNText(string: _scrollText, extrusionDepth: 0)
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
    _scrollOffset += delta
    if (_scrollOffset >= wrap_time) {
      _scrollOffset = 0
    }
    _text.setValue(_scrollOffset, forKey: "scroll_offset")
  }
}

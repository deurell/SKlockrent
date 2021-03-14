//
//  Scroller.swift
//  SKlockrent
//
//  Created by Mikael Deurell on 2021-03-14.
//

import Foundation
import SceneKit

class Scroller
{
  let _scene:SCNScene
  let _text:SCNText
  let _scrollNode:SCNNode
  var _scrollOffset:Double = 0
  
  let _scrollText = "Klockrent tillverkades under tiden Deurell Labs kompilerade C++ kod för andra projekt. Spelet innehåller ingen reklam eller köp och vi kommer aldrig på något sätt spara uppgifter om användaren. Ever! Ha en fin dag och ta hand om varandra...       *wrap*       "
  
  init(scene: SCNScene) {
    _scene = scene
    _text = SCNText(string: _scrollText, extrusionDepth: 0)
    _text.font = UIFont(name: "Commodore-64-Rounded", size: 7)
    _scrollNode = SCNNode()
    _scrollNode.geometry = _text
    _scrollNode.simdScale = [0.2,0.2,0.2]
    _scrollNode.simdPosition = [5.5,-8,-2]
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
    _text.shaderModifiers = [.geometry: vertShader ,.fragment: fragShader]
    _text.setValue(0.0, forKey: "scroll_offset")
    scene.rootNode.addChildNode(_scrollNode)
  }
  
  func update(delta:Double) {
    _scrollOffset += delta
    if (_scrollOffset >= 109.0) {
      _scrollOffset = 0
    }
    _text.setValue(_scrollOffset, forKey: "scroll_offset")
  }
}

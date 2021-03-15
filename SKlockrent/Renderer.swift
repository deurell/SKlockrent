//
//  Renderer.swift
//  SKlockrent
//
//  Created by Mikael Deurell on 2021-03-15.
//

import Foundation
import SceneKit

enum SceneState {case active; case done}

protocol Renderer {
  var state:SceneState { get }
  var scene:SCNScene { get }
  func update(delta:Double)
}

//
//  GameViewController.swift
//  SKlockrent
//
//  Created by Mikael Deurell on 2021-02-17.
//

import UIKit
import SceneKit
import SpriteKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {
  
  var _startTime:Double = 0
  var _previousUpdate:Double = 0
  var _currentStage:Renderer?
  var _view:SCNView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    _view = self.view as? SCNView
    guard let view = _view else { fatalError("Not displaying in SCNView.") }
    view.delegate = self
    view.isPlaying = true
    displayStage(stage:MenuStage(view: view))
  }
  
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    if (_previousUpdate == 0) {
      _previousUpdate = time
      _startTime = time
    }
    let delta = time - _previousUpdate
    _previousUpdate = time
    
    if (_currentStage?.state == .done) {
      _currentStage = nil
      DispatchQueue.main.async {
        let stage = GameStage(view: self._view!)
        self.displayStage(stage: stage)
      }
    }
    _currentStage?.update(delta: delta)
  }
  
  func displayStage(stage: Renderer) {
    _currentStage = stage
    _view?.scene = stage.scene
    
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

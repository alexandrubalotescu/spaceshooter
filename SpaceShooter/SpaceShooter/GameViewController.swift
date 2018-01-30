//
//  GameViewController.swift
//  SpaceShooter
//
//  Created by Cristian Macovei on 12.12.17.
//  Copyright © 2017 Cristian Macovei. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

@available(iOS 10.0, *)
class GameViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        let scene = GameScene(size: CGSize(width: 1536, height: 2048))
        
        //Configure the view
        let skView = self.view as! SKView
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        //Rendering improvements by SpriteKit
        skView.ignoresSiblingOrder = true
        
        //Set the scale mode to scale to fit windows
        scene.scaleMode = .aspectFill
        
        skView.presentScene(scene)
        
        
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }
}

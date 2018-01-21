//
//  GameScene.swift
//  SpaceShooter
//
//  Created by Cristian Macovei on 12.12.17.
//  Copyright © 2017 Cristian Macovei. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene {
    
    let motionManager : CMMotionManager = CMMotionManager()
    var timer : Timer!
    
    let player = SKSpriteNode(imageNamed: "spaceShip.png")
    let rocketCountLabel = SKLabelNode(fontNamed: "Thonburi")
    let missileCountLabel = SKLabelNode(fontNamed: "Thonburi")
    let outOfMissilesLabel = SKLabelNode(fontNamed: "Thonburi")

    var destX:CGFloat  = 0.0
    
    
    func holdPosition() {
        self.player.position = CGPoint(x: self.position.x, y: self.size.height*0.2)
    }
    
    override func didMove(to view: SKView) {
        
        if motionManager.isAccelerometerAvailable {
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler:{
                data, error in
                
                let currentX = self.player.position.x
                
                // 3
                if (data?.acceleration.x)! < -0.05 {
                    self.destX = currentX + CGFloat((data?.acceleration.x)! * 1500)
                    print("X Coordinate: \((data?.acceleration.x)!)")
                    print("Player coordinate: \(self.destX)")
                }
                    
                else if (data?.acceleration.x)! > 0.05 {
                    self.destX = currentX + CGFloat((data?.acceleration.x)! * 1500)
                    print("X Coordinate: \((data?.acceleration.x)!)")
                    print("Player coordinate: \(self.destX)")
                } else if (data?.acceleration.x)! >= -0.05 && (data?.acceleration.x)! <= 0.05 {
                    self.holdPosition()
                    print("X Coordinate: \((data?.acceleration.x)!)")
                    print("Player coordinate: \(self.destX)")
                }
                
            })
        }
        
        //Game over - no more missiles
        outOfMissilesLabel.text = "Game Over! No more Missiles"
        outOfMissilesLabel.fontSize = 60
        outOfMissilesLabel.position = CGPoint(x: 750, y: 1000)
        outOfMissilesLabel.zPosition = -1
        outOfMissilesLabel.isHidden = false
        
        
        //Counter for the missiles
        missileCountLabel.text = String("Missiles: 100")
        missileCountLabel.fontSize = 45
        missileCountLabel.position = CGPoint(x: 340, y: 75)
        missileCountLabel.zPosition = 0.5
        
        //Counter for the rockets
        rocketCountLabel.text = String("Rockets: \(rocketCount)")
        rocketCountLabel.fontSize = 45
        rocketCountLabel.position = CGPoint(x: 330, y: 30)
        rocketCountLabel.zPosition = 0.5
        
        //Player node
        player.setScale(0.7)
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)
        player.zPosition = 2
        
        //Background node
        let background = SKSpriteNode(imageNamed: "spaceWallpaper.jpg")
        background.size =  self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        
        //Add items to the scene (self)
        self.addChild(background)
        self.addChild(player)
        self.addChild(missileCountLabel)
        self.addChild(rocketCountLabel)
        self.addChild(outOfMissilesLabel)
        
        
    }
 
    override func update(_ currentTime: CFTimeInterval) {
        let action = SKAction.moveTo(x: destX, duration: 1)
        self.player.run(action)
    }
    
    var missileCount = 100
    var rocketCount = 20
    
    func fireLaser() {
        
        let laser = SKSpriteNode(imageNamed: "laser.png")
        laser.setScale(0.3)
        laser.position = player.position
        laser.zPosition = 1
        self.addChild(laser)
        
        let rotation = SKAction.rotate(byAngle: CGFloat.pi / 4.0, duration: 0)
        let moveLaser = SKAction.moveTo(y: self.size.height + laser.size.height, duration: 0.3)
        let destroyLaser = SKAction.removeFromParent()
        
        let laserSequence = SKAction.sequence([rotation, moveLaser, destroyLaser])
        laser.run(laserSequence)
    }
    
    func fireMissile() {
        
        //Instantiate missile
        let missile = SKSpriteNode(imageNamed: "missile.png")
        missile.setScale(0.1)
        missile.position = player.position
        missile.zPosition = 1
        self.addChild(missile)
        
        //Run in this order
        let rotation : SKAction = SKAction.rotate(byAngle: CGFloat.pi / 4.0, duration: 0)
        let moveMissile : SKAction = SKAction.moveTo(y: self.size.height + missile.size.height, duration: 0.6)
        let destroyMisile : SKAction = SKAction.removeFromParent()
        
        //Run action sequence
        let missileSequence = SKAction.sequence([rotation, moveMissile, destroyMisile])
        missile.run(missileSequence)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if missileCount > 0 {
            fireMissile()
            missileCount = missileCount - 1
            print("Missiles: \(missileCount)")
            missileCountLabel.text = "Missiles: \(missileCount)"
            
        }
        else {
            outOfMissilesLabel.zPosition = 4
        }
 
    }
    
    
}

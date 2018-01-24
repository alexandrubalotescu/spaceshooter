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
    
    //Create a motionManager to fetch accelerometer data
    let motionManager : CMMotionManager = CMMotionManager()
    
    let player = SKSpriteNode(imageNamed: "spaceShip.png")
    let rocketCountLabel = SKLabelNode(fontNamed: "Thonburi")
    let missileCountLabel = SKLabelNode(fontNamed: "Thonburi")
    let outOfMissilesLabel = SKLabelNode(fontNamed: "Thonburi")
    
    //Create a gameArea the size of the display
    var gameArea:CGRect
    //Initialize gameArea by size
    override init(size: CGSize) {
        let maxAspectRatio = CGFloat(16.0/9.0)
        let playableWidth = size.width/maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAccelerometerData() {
        
        //Acc hardware available
        if self.motionManager.isAccelerometerAvailable {
            self.motionManager.startAccelerometerUpdates()
            
            //Check if data is your accelerometerData (always true)
            if let data = self.motionManager.accelerometerData {
                //Create variable that stores your x accelerometerData
                let x = CGFloat(data.acceleration.x)
                
                //Move left for x>0
                if x > 0 {
                    player.position.x += x*100
                    print(player.position.x)
                }
                    //Move right for x<0
                else if x < 0 {
                    player.position.x += x*100
                    print(player.position.x)
                }
                //Switch to left side if spaceShip too far right
                if player.position.x > gameArea.maxX + player.size.width {
                    player.position.x = gameArea.minX - player.size.width
                }
                    //Switch to right side if spaceShip too far left
                else if player.position.x < gameArea.minX - player.size.width {
                    player.position.x = gameArea.maxX + player.size.width
                }
            }
        }
        
    }
    
    //Create all the objects that appear on the game scene
    override func didMove(to view: SKView) {
        
        startNewLevel()
        
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
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        //Start accelerometer updates to move the spaceShip when phone tilted
        startAccelerometerData()
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
    
    func startNewLevel() {
        
        let spawn = SKAction.run(spawnMeteorites)
        //Time between spawning meteorites
        let waitToSpawn = SKAction.wait(forDuration: 1.2)
        let spawnSequence = SKAction.sequence([spawn, waitToSpawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever)
        
        
    }
    
    func spawnMeteorites() {
        
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height*1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height*0.2)
        
        let meteorite : SKSpriteNode!
        meteorite = SKSpriteNode(imageNamed: "meteor.png")
        meteorite.setScale(2)
        
        meteorite.position = startPoint
        meteorite.zPosition = 2
        
        self.addChild(meteorite)
        
        let moveMeteorite : SKAction = SKAction.move(to: endPoint, duration: 1.2)
        let deleteMeteorite : SKAction = SKAction.removeFromParent()
        let meteoriteSequence : SKAction = SKAction.sequence([moveMeteorite, deleteMeteorite])
        meteorite.run(meteoriteSequence)
        
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


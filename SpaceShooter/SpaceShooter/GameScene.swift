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
import UIKit


var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate, UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        return UIViewController()
    }
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        return
    }
    
    struct PhysicsCategories {
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1 //1
        static let Missile: UInt32 = 0b10 //2
        static let Meteorite: UInt32 = 0b100 //3
    }
    
    enum gameState {
        case preGame
        case inGame
        case endGame
    }
    
    var currentGameState = gameState.preGame
    
    //Create a motionManager to fetch accelerometer data
    let motionManager : CMMotionManager = CMMotionManager()
    
    var missileCountLabel = SKLabelNode(fontNamed: "Thonburi")
    var numberOfLivesLabel = SKLabelNode(fontNamed: "Thonburi")
    var gameScoreLabel : SKLabelNode = SKLabelNode(fontNamed: "Thonburi")
    let levelNumberLabel = SKLabelNode(fontNamed: "Thonburi")
    var startGameLabel : SKLabelNode = SKLabelNode(fontNamed: "Thonburi")
    let shieldCounterLabel = SKLabelNode(fontNamed: "Thonburi")
    
    
    //Variables
    var numberOfLives = 3
    var hitsCounter = 0
    var levelNumber = 0
    var missileCount = 100
    var shieldsAvailable = 0
    
    //Labels
    let player = SKSpriteNode(imageNamed: "spaceShip.png")
    let rocketCountLabel = SKLabelNode(fontNamed: "Thonburi")
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
                    //print(player.position.x)
                }
                    //Move right for x<0
                else if x < 0 {
                    player.position.x += x*100
                    //print(player.position.x)
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
        
        gameScore = 0
        
        self.physicsWorld.contactDelegate = self
    
        //Level Label
        levelNumberLabel.text = "\(levelNumber)"
        levelNumberLabel.fontSize = 50
        levelNumberLabel.fontColor = .white
        levelNumberLabel.position = CGPoint(x: self.size.width*0.8, y: self.size.height*0.925)
        levelNumberLabel.zPosition = 1
        let levelNumberAction = SKAction.moveTo(x: self.size.width*0.8, duration: 0.5)
        levelNumberLabel.run(levelNumberAction)
        
        //Counter for lives
        numberOfLivesLabel.text = "Lives: \(numberOfLives)"
        numberOfLivesLabel.fontSize = 45
        numberOfLivesLabel.position = CGPoint(x: self.size.width*0.2 - numberOfLivesLabel.frame.width, y: self.size.height*0.8875)
        numberOfLivesLabel.zPosition = 100
        numberOfLivesLabel.horizontalAlignmentMode = .center
        let moveToScreenAction = SKAction.moveTo(x: self.size.width*0.2, duration: 0.5)
        numberOfLivesLabel.run(moveToScreenAction)
       
        
        //Game score label
        gameScoreLabel.text = "Score: \(gameScore)"
        gameScoreLabel.fontSize = 45
        gameScoreLabel.horizontalAlignmentMode = .center
        gameScoreLabel.position = CGPoint(x: self.size.width*0.20 - gameScoreLabel.frame.width, y: self.size.height*0.925)
        gameScoreLabel.zPosition = 100
        let moveToScreenAction2 = SKAction.moveTo(x: self.size.width*0.20, duration: 0.5)
        gameScoreLabel.run(moveToScreenAction2)
        
        
        
        //Counter for the missiles
        missileCountLabel.text = "Missiles: \(missileCount)"
        missileCountLabel.fontSize = 45
        missileCountLabel.position = CGPoint(x: self.size.width*0.145 - missileCountLabel.frame.width, y: self.size.height*0.85)
        missileCountLabel.zPosition = 0.5
        missileCountLabel.horizontalAlignmentMode = .left
        let moveToScreenAction3 = SKAction.moveTo(x: self.size.width*0.145, duration: 0.5)
        missileCountLabel.run(moveToScreenAction3)
        
        //Shield counter label
        shieldCounterLabel.text = "Shields: \(shieldsAvailable)"
        shieldCounterLabel.fontColor = .white
        shieldCounterLabel.fontSize = 45
        shieldCounterLabel.position = CGPoint(x: self.size.width*0.8,y: self.size.height*0.765)
        shieldCounterLabel.zPosition = 5
        
        
        /*
        //Counter for the rockets
        rocketCountLabel.text = "Rockets: \(rocketCount)"
        rocketCountLabel.fontSize = 45
        rocketCountLabel.position = CGPoint(x: self.size.width*0.15, y: self.size.height*0.95)
        rocketCountLabel.zPosition = 0.5
        rocketCountLabel.horizontalAlignmentMode = .left
        */
 
        //Player node
        player.setScale(0.7)
        player.position = CGPoint(x: self.size.width/2, y: -self.size.height * 0.2)
        player.zPosition = 2
        
        
        //Player PhysicsBody
        
        let rect2 = SKPhysicsBody(rectangleOf: CGSize(width: 45, height: 300))
        let rect1 = SKPhysicsBody(rectangleOf: CGSize(width: 350, height: 45))
        let spaceShipBody = SKPhysicsBody(bodies: [rect2, rect1])

        player.physicsBody = spaceShipBody
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.categoryBitMask = PhysicsCategories.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategories.Meteorite
        player.physicsBody?.collisionBitMask = PhysicsCategories.None
        
        
        //Background node
        let background = SKSpriteNode(imageNamed: "spaceWallpaper.jpg")
        background.size =  self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        
        
        //Tap to play label
        startGameLabel.text = "Start Game"
        startGameLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        startGameLabel.zPosition = 1
        startGameLabel.fontSize = 100
        startGameLabel.fontColor = .white
        startGameLabel.alpha = 0
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        startGameLabel.run(fadeIn)
        
        
        //Add items to the scene (self)
        self.addChild(background)
        self.addChild(player)
        self.addChild(missileCountLabel)
        self.addChild(rocketCountLabel)
        self.addChild(numberOfLivesLabel)
        self.addChild(startGameLabel)
        self.addChild(gameScoreLabel)
        self.addChild(shieldCounterLabel)
    }
    
    //Method to add score
    func addScore() {
        gameScore += 1
        gameScoreLabel.text = "Score: \(gameScore)"
        
        if gameScore == 10 || gameScore == 25 || gameScore == 50 || gameScore == 65 {
            startNewLevel()
        }
    }
    
    //Method to subtract number of lives
    func subtractNumberOfLives() {
        
        numberOfLives -= 1
        numberOfLivesLabel.text = "Lives: \(numberOfLives)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        
        numberOfLivesLabel.run(scaleSequence)
        
        if numberOfLives == 0 {
            gameOver()
        }
    }
    //Method to for gameOver
    func gameOver() {
        
        currentGameState = .endGame
        self.removeAllActions()
        self.enumerateChildNodes(withName: "Missile") {
            missile, stop in
            missile.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Meteorite") {
            meteorite, stop in
            meteorite.removeAllActions()
        }
        print("Score: \(gameScore)")
        
        let changeSceneAction = SKAction.run(changeScene)
        let wait = SKAction.wait(forDuration: 1)
        let seq = SKAction.sequence([wait, changeSceneAction])
        
        self.run(seq) 
        
    }
    
    //Method to add missiles
    func addMissiles() {
        missileCount += 5
        missileCountLabel.text = "Missiles: \(missileCount)"
    }
    
    //Method to add shields
    func addShield() {
        shieldsAvailable += 1
        shieldCounterLabel.text = "Shield: \(shieldsAvailable)"
    }
    
    //Method to subtract shields available
    func subtractShieldAvailable() {
        shieldsAvailable -= 0
        shieldCounterLabel.text = "Shield: \(shieldsAvailable)"
    }
    
    //Method to subtract missiles
    func subtractMissiles() {
        missileCount -= 1
        missileCountLabel.text = "Missiles: \(missileCount)"
    }
    
    //Generate random values for spawning
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
<<<<<<< HEAD
    
    //Generate random values for spawning
=======
>>>>>>> 517eff9bd63943cd8b1d9dcda9e3883b6f9a9614
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    //Update called once per frame BEFORE loading the frame itself
    override func update(_ currentTime: CFTimeInterval) {
        //Start accelerometer updates to move the spaceShip when phone tilted
        startAccelerometerData()
    }
    
    var rocketCount = 20
    
    func fireLaser() {
        
        let laser = SKSpriteNode(imageNamed: "laser.png")
        laser.setScale(0.12)
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
        
        //Create a CGRect for physicsBody for missile
        let missilePhysicsBodyRect = CGRect(x: self.player.position.x, y: self.player.position.y, width: 110, height: 250)
        
        
        //Instantiate missile
        let missile = SKSpriteNode(imageNamed: "missile.png")
        missile.setScale(0.1)
        missile.name = "Missile"
        missile.position = player.position
        missile.zPosition = 1
        self.addChild(missile)
        
        missile.physicsBody = SKPhysicsBody(rectangleOf: missilePhysicsBodyRect.size)
        missile.physicsBody?.affectedByGravity = false
        missile.physicsBody?.categoryBitMask = PhysicsCategories.Missile
        missile.physicsBody?.collisionBitMask = PhysicsCategories.None
        missile.physicsBody?.contactTestBitMask = PhysicsCategories.Meteorite
        
        //Run in this order
        let rotation : SKAction = SKAction.rotate(byAngle: CGFloat.pi / 4.0, duration: 0)
        let moveMissile : SKAction = SKAction.moveTo(y: self.size.height + missile.size.height, duration: 0.6)
        let destroyMisile : SKAction = SKAction.removeFromParent()
        
        //Run action sequence
        let missileSequence = SKAction.sequence([rotation, moveMissile, destroyMisile])
        missile.run(missileSequence)
        if missileCount == 0 {
            gameOver()
            //self.addChild(outOfMissilesLabel)
        }
    }
    /*
    func shieldCreator() {
        
        while shieldsAvailable > 0 {
            
            
        }
        
        
    }
    */
    //Check for contact with other bodies
    func didBegin(_ contact: SKPhysicsContact) {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        if body1.categoryBitMask == PhysicsCategories.Player  && body2.categoryBitMask == PhysicsCategories.Meteorite {
            //If the player has hit the meteorite
            if body1.node != nil {
                //1. Spwn explosion
                spawnExplosion(spawnPosition: body1.node!.position)
                //2. Subtract 1 life from player
                subtractNumberOfLives()
                //3. If player has no lives left, destroy the spaceShip
                if numberOfLives == 0 {
                    body1.node?.removeFromParent()
                    outOfMissilesLabel.zPosition = 4
                }
            }
            if body2.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            //Remove both bodies from the scene
            //body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
        if body1.categoryBitMask == PhysicsCategories.Missile && body2.categoryBitMask == PhysicsCategories.Meteorite && (body2.node?.position.y)! < self.size.height {
            
            //Add points
            addScore()
            
            //Initialize a counter to add missiles every 10 meteorites
            hitsCounter+=1
            if hitsCounter % 10 == 0 {
                addMissiles()
                addShield()
            }
            
            //If the missile has hit the meteorite and it's not nil spawn explosion
            if body2.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            //Remove both bodies from the scene
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
    
    }
    
    //Create explosion node
    func spawnExplosion(spawnPosition: CGPoint) {
        
        let explosion = SKSpriteNode(imageNamed: "explosion.png")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        
        
        self.addChild(explosion)
        let scaleIn = SKAction.scale(to: 2, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
        
    }
    
    
    //Create new level
    func startNewLevel() {
        //Add 1 to the level
        levelNumber += 1
        
        //Stop enemies from spawning
        if self.action(forKey: "spawningEnemies") != nil {
            self.removeAction(forKey: "spawningEnemies")
        }
        
        //Declare a variable for spawning duration
        var spawnDuration = TimeInterval()
        
        //Level cases with respect to spawning duration
        switch levelNumber {
        case 1:
            spawnDuration = 2
        case 2:
            spawnDuration = 1.8
        case 3:
            spawnDuration = 1.6
        case 4:
            spawnDuration = 1.4
        case 5:
            spawnDuration = 1.2
        case 6:
            spawnDuration = 1
        case 7:
            spawnDuration = 0.8
        case 8:
            spawnDuration = 0.6
        default:
            spawnDuration = 0.6
            
        }
        
        let spawn = SKAction.run(spawnMeteorites)
        
        //Time between spawning meteorites
        let waitToSpawn = SKAction.wait(forDuration: spawnDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
        
    }
    
    func startGame() {
        
        currentGameState = .inGame
        
        
        let deleteStartButton = SKAction.sequence([SKAction.fadeOut(withDuration: 0.5), SKAction.removeFromParent()])
        startGameLabel.run(deleteStartButton)
        
        let movePlayerToStart = SKAction.moveTo(y: self.size.height * 0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let seq = SKAction.sequence([movePlayerToStart, startLevelAction])
        player.run(seq)
        
    }
    
    //Self explanatory
    var meteorite : SKSpriteNode!
    func spawnMeteorites() {
        
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height*1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height*0.2)
        
        //meteorite physicsbody by cgrect
        // -->> fail -->> let meteoritePhysicsBody = CGRect(x: (self.meteorite?.position.x)!, y: (self.meteorite?.position.y)!, width: 96, height: 96)
        //                                                                                                         / \
        //                                                                                                        /_|_\
        meteorite = SKSpriteNode(imageNamed: "meteor.png") //                                                       |
        meteorite.setScale(1.5) //                                                                                  |
        meteorite.name = "Meteorite" //                                                                             |
        meteorite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 70, height: 70))  //<<-- much better than this
        meteorite.physicsBody?.affectedByGravity = false
        meteorite.physicsBody?.categoryBitMask = PhysicsCategories.Meteorite
        meteorite.physicsBody?.collisionBitMask = PhysicsCategories.None
        meteorite.physicsBody?.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Missile
        
        meteorite.position = startPoint
        meteorite.zPosition = 2
        
        self.addChild(meteorite)
        
        let moveMeteorite : SKAction = SKAction.move(to: endPoint, duration: 1.2)
        let deleteMeteorite : SKAction = SKAction.removeFromParent()
        let meteoriteSequence : SKAction = SKAction.sequence([moveMeteorite, deleteMeteorite])
        meteorite.run(meteoriteSequence)
        
    }
    
    func changeScene() {
        let sceneToMove = GameOverScene(size: self.size)
        sceneToMove.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration: 1)
        self.view!.presentScene(sceneToMove, transition: transition)
    }
    
    
    //CHESTIA ASTA INCA MAI TREBUIE PRELUCRATA GONNA DO IT SWEAR <3 PWP #easteregg
    
    
    
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        /*if let touch = touches.first {
            if view?.traitCollection.forceTouchCapability == .available {
                if touch.force == touch.maximumPossibleForce {
                    if shieldsAvailable > 0 {
                        subtractShieldAvailable()
                        //Shield
                        let shield : SKSpriteNode = SKSpriteNode(imageNamed: "shield")
                        shield.position = CGPoint(x: self.player.position.x/4, y: self.player.position.y/4)
                        shield.alpha = 0.5
                        shield.zPosition = 5
                        shield.setScale(3)
                        
                        //Run
                        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
                        let wait = SKAction.wait(forDuration: 10)
                        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
                        let destroy = SKAction.removeFromParent()
                        let seq = SKAction.sequence([fadeInAction, wait, fadeOutAction, destroy])
                        shield.run(seq)
                    }
                }
            }
        }*/
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if currentGameState == .inGame {
            fireMissile()
        } else if currentGameState == .preGame {
            print("trueasghsh")
            startGame()
        }
        
        if missileCount > 0 && currentGameState == .inGame {
            fireMissile()
            subtractMissiles()
        }
        else {
            gameOver()
            
            motionManager.stopAccelerometerUpdates()
        }
        
    }
    
    
    
    
}


//
//  GameOverScene.swift
//  SpaceShooter
//
//  Created by Cristian Macovei on 28.01.18.
//  Copyright © 2018 Cristian Macovei. All rights reserved.
//

import Foundation
import SpriteKit


class GameOverScene : SKScene {
    
    
    let playAgainLabel = SKLabelNode(fontNamed: "Thonburi")
    
    override func didMove(to view: SKView) {
        
        //Background of the scene
        let background = SKSpriteNode(imageNamed: "spaceWallpaper.jpg")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.size = self.size
        self.view!.contentMode = .scaleAspectFill
        background.zPosition = 0
        self.addChild(background)
        
        //Label saying "Game over"
        let gameOverLabel = SKLabelNode(fontNamed: "Thonburi")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 100
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.75)
        gameOverLabel.fontColor = .white
        self.addChild(gameOverLabel)
        
        //Label saying final score
        let scoreLabel = SKLabelNode(fontNamed: "Thonburi")
        scoreLabel.text = "Score: \(gameScore)"
        scoreLabel.fontSize = 65
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.55)
        scoreLabel.zPosition = 1
        scoreLabel.fontColor = .white
        self.addChild(scoreLabel)
        
        
        //Access the savedata
        let userDefaults = UserDefaults()
        var highScore = userDefaults.integer(forKey: "highScore")
        
        if gameScore > highScore {
            highScore = gameScore
            userDefaults.set(highScore, forKey: "highScore")
         }
        //      |
        //      |
        //      V
        //High Score label
        let highScoreLabel = SKLabelNode(fontNamed: "Thonburi")
        highScoreLabel.text = "High Score: \(highScore)"
        highScoreLabel.fontSize = 65
        highScoreLabel.fontColor = .white
        highScoreLabel.position = CGPoint(x: self.size.width/2,y: self.size.height*0.45)
        highScoreLabel.zPosition = 1
        self.addChild(highScoreLabel)
        
        //Restart label
        
        playAgainLabel.text = "PLAY AGAIN"
        playAgainLabel.fontColor = .white
        playAgainLabel.fontSize = 65
        playAgainLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.25)
        playAgainLabel.zPosition = 1
        self.addChild(playAgainLabel)
        
        
    }
    
    //Transform the restart label into a button
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            
            let touchPos = touch.location(in: self)
            
            if playAgainLabel.contains(touchPos) {
                
                let startNewGame = GameScene(size: self.size)
                startNewGame.scaleMode = self.scaleMode
                self.view!.presentScene(startNewGame, transition: SKTransition.fade(withDuration: 0.3))
            }
            
        }
        
    }
    
    
    
    
    
    
    
}

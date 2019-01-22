//
//  GameScene.swift
//  Lil Flappy Watch Extension
//
//  Created by Charles Martin Reed on 1/21/19.
//  Copyright © 2019 Charles Martin Reed. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    //MARK:- Properties
    var playerBirb = SKSpriteNode()
    var levelBG = SKSpriteNode()
    var playerScoreLabel = SKLabelNode()
    
    var backgroundAnimationDuration: TimeInterval = 3.0
    var playerScore: Int = 0 {
        didSet {
            playerScoreLabel.text = "\(playerScore)"
        }
    }
    
    override func sceneDidLoad() {
        
        initGameScene()

    }
    
    func initGameScene() {
        createPlayerSprite()
        createLevelBackground()
        createScoreLabel()
    }
    
    func createPlayerSprite() {
        let birbTexture1 = SKTexture(imageNamed: "flappy1")
        let birbTexture2 = SKTexture(imageNamed: "flappy2")
        let birbAnimation = SKAction.repeatForever(SKAction.animate(with: [birbTexture1, birbTexture2], timePerFrame: 0.1))
        
        //initializaiton and positioning
        playerBirb = SKSpriteNode(texture: birbTexture1)
        playerBirb.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        playerBirb.zPosition = 1
        playerBirb.run(birbAnimation)
        
        //physics
        playerBirb.physicsBody = SKPhysicsBody(circleOfRadius: birbTexture1.size().height / 2)
        playerBirb.physicsBody?.isDynamic = false //set to true when tap recognized
        
        addChild(playerBirb)
    }
    
    func movePlayerSprite() {
        playerBirb.physicsBody?.isDynamic = true
        playerBirb.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 12))
    }
    
    func createLevelBackground() {
        let levelTexture = SKTexture(imageNamed: "bg")
        
        //MARK:- Background animation
        let moveBGOut = SKAction.move(by: CGVector(dx: -levelTexture.size().width, dy: 0), duration: backgroundAnimationDuration)
        let moveBGIn = SKAction.move(by: CGVector(dx: levelTexture.size().width, dy: 0), duration: 0)
        let bgAnimationSequence = SKAction.sequence([moveBGOut, moveBGIn])
        
        //two backgrounds seems fine on the Apple Watch screen
        for i in 0...1 {
            levelBG = SKSpriteNode(texture: levelTexture)
            levelBG.size = CGSize(width: levelTexture.size().width, height: self.frame.height)
            levelBG.position = CGPoint(x: levelTexture.size().width * CGFloat(i), y: self.frame.midY)
            levelBG.zPosition = 0
            levelBG.run(SKAction.repeatForever(bgAnimationSequence))
            
            addChild(levelBG)
        }
    }
    
    func createScoreLabel() {
        playerScoreLabel.text = "\(playerScore)"
        playerScoreLabel.fontName = "Helvetica"
        playerScoreLabel.fontColor = UIColor.white
        playerScoreLabel.fontSize = 48
        playerScoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2 - 50)
        playerScoreLabel.zPosition = 2
        addChild(playerScoreLabel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
}

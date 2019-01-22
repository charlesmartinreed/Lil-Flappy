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
    var pipeSpawnFrequency: TimeInterval = 1.5
    var pipeGenerationTimer: Timer!
    
    var playerScore: Int = 0 {
        didSet {
            playerScoreLabel.text = "\(playerScore)"
        }
    }
    
    //MARK:- Collision properties
    let birbCategory: UInt32 = 0x1 << 1 //1
    let pipeCategory: UInt32 = 0x1 << 2 //2
    let gapCategory: UInt32 = 0x1 << 3 //4
    let levelBoundsCategory: UInt32 = 0x1 << 4 //8
    
    override func sceneDidLoad() {
        
        initGameScene()
        physicsWorld.contactDelegate = self

    }
    
    func initGameScene() {
        createPlayerSprite()
        createLevelBackground()
        createLevelBounds()
        createScoreLabel()
        
        //start the pipe generation timer
        pipeGenerationTimer = Timer.scheduledTimer(timeInterval: pipeSpawnFrequency, target: self, selector: #selector(createLevelObstacles), userInfo: nil, repeats: true)
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
        playerBirb.physicsBody?.categoryBitMask = birbCategory
        playerBirb.physicsBody?.contactTestBitMask = levelBoundsCategory
        playerBirb.physicsBody?.collisionBitMask = 0
        
        addChild(playerBirb)
    }
    
    func movePlayerSprite() {
        //fired when the tap is detected in the screen, via the Interface Controller
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
    
    func createLevelBounds() {
        //initalization and positioning
        let levelFloor = SKNode()
        levelFloor.position = CGPoint(x: self.frame.midX , y: -self.frame.height / 2 - playerBirb.size.height) //fix to allow the sprite to fall off the screen in full before "game over" occurs
        levelFloor.zPosition = 1
        
        //physics
        levelFloor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        levelFloor.physicsBody?.isDynamic = false
        levelFloor.physicsBody?.affectedByGravity = false
        levelFloor.physicsBody?.categoryBitMask = levelBoundsCategory
        levelFloor.physicsBody?.contactTestBitMask = birbCategory
        levelFloor.physicsBody?.collisionBitMask = 0
        
        addChild(levelFloor)
    }
    
    @objc func createLevelObstacles() {
        //pipe placement logic
        let gapHeight = playerBirb.size.height * 3 //this will be used to size the area between the pipes/the area the user touches to gain a point
        let movementAmount = arc4random() % UInt32(self.frame.height / 2)
        let pipeOffset = CGFloat(movementAmount) - self.frame.height / 4 //between -1/4 of the screen and 1/4 of the screen
        
        //initialization and positioning
        let pipeTexture1 = SKTexture(imageNamed: "pipe1")
        let pipeTexture2 = SKTexture(imageNamed: "pipe2")
        
        //pipe animations
        let pipeAnimationDuration: TimeInterval = Double(self.frame.width) / 100
        let moveAndRemoveAnimation = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: pipeAnimationDuration)
        
        let pipe1 = SKSpriteNode(texture: pipeTexture1)
        pipe1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeTexture1.size().height / 2 + gapHeight / 2 + pipeOffset) //offscreen, in the mid point
        pipe1.zPosition = 1
        pipe1.run(moveAndRemoveAnimation) {
            pipe1.removeFromParent()
        }
        
        addChild(pipe1)
        
        let pipe2 = SKSpriteNode(texture: pipeTexture2)
        pipe2.position = CGPoint(x: self.frame.midX + self.frame.width, y: -self.frame.midY - pipeTexture2.size().height / 2 - gapHeight / 2 + pipeOffset)
        pipe2.zPosition = 1
        pipe2.run(moveAndRemoveAnimation) {
            pipe2.removeFromParent()
        }
        
        addChild(pipe2)
        
        //physics
        
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

extension GameScene : SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        print("contact detected")
        scene?.isPaused = true
    }
}

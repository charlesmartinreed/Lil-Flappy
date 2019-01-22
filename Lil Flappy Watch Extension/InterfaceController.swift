//
//  InterfaceController.swift
//  Lil Flappy Watch Extension
//
//  Created by Charles Martin Reed on 1/21/19.
//  Copyright © 2019 Charles Martin Reed. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    @IBOutlet var skInterface: WKInterfaceSKScene!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
        // Load the SKScene from 'GameScene.sks'
        if let scene = GameScene(fileNamed: "GameScene") {
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            self.skInterface.presentScene(scene)
            
            // Use a value that will maintain a consistent frame rate
            self.skInterface.preferredFramesPerSecond = 30
            
            
            
        }
    }
    
    @IBAction func handleTap(tapGesture: WKTapGestureRecognizer) {

        if let scene = skInterface.scene as? GameScene {
            if scene.isGameActive {
                scene.movePlayerSprite()
            } else {
                //set the scene to active again so that our init func fires properly
                scene.removeAllChildren()
                scene.isGameActive = true
                scene.initGameScene()
            }
            
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

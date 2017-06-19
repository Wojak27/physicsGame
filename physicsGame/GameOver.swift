//
//  GameOver.swift
//  physicsGame
//
//  Created by Karol Wojtulewicz on 2017-05-26.
//  Copyright © 2017 Karol Wojtulewicz. All rights reserved.
//

import UIKit
import SpriteKit

class GameOver: SKScene {
    
    private var startOverButton: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        
        startOverButton = self.childNode(withName: "startOver") as! SKSpriteNode
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self){
            let nodesArray = self.nodes(at: location)
            
            if ((nodesArray.first?.name = "startOver") != nil){
                let transition = SKTransition.flipHorizontal(withDuration: 1)
                let gameScene = GameScene(size: self.size)
                self.view?.presentScene(gameScene, transition: transition)
            }
        }

    }
}

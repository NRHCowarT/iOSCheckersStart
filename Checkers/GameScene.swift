//
//  GameScene.swift
//  Checkers
//
//  Created by Cal on 11/26/14.
//  Copyright (c) 2014 Cal. All rights reserved.
//

import SpriteKit




class GameScene: SKScene {
    
    var board : SKNode?
    var manager : TileManager?
    
    
   
    override func didMoveToView(view: SKView) {
        
        board = SKNode()
        board!.name = "Board"
        let tileWidth : Int = 100
        
        // TILEMANAGER IS PRETTY MUCH AN INSTANCE OF BOARD
        manager = TileManager(board: board!, tileWidth: tileWidth)
        self.addChild(board!)
        self.size = CGSizeMake(800, 800)
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let touched = board!.nodeAtPoint((touch as UITouch).locationInNode(board!)) as SKNode
            
            // send the locationInBord to our instance of manager
            manager!.processTouch(touched)
        }
    }
   
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        if let touch = touches.allObjects.last as? UITouch {
            
        }
    }
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
}

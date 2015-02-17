//ù
//  Player.swift
//  Checkers
//
//  Created by Cal on 11/26/14.
//  Copyright (c) 2014 Cal. All rights reserved.
//

import Foundation
import SpriteKit

class Checker{
    
    var owner : Tile
    let player : Player
    var king : Bool = false
    let node : SKShapeNode

    
    init(owner : Tile, player : Player) {
        self.player = player
      
        self.node = SKShapeNode(circleOfRadius: 40)
        self.node.fillColor = player.checkerFill()
        self.node.strokeColor = player.checkerBorder()
        self.node.lineWidth = 10.0
        self.node.zPosition = 1
        self.owner = owner
        moveToTile(owner, animate: false)
    }
    
    
    // the tile argument is the owner
    func moveToTile(tile : Tile, animate : Bool = true) -> NSTimeInterval{
        self.owner.checker = nil
        self.owner = tile
        tile.checker = self
        node.name = tile.node.name
        
        // center of the node
        let newPosition = CGPoint(x: owner.node.position.x + 50, y: owner.node.position.y + 50)
        
        
        // distance only used for duration (node position is the initial checker and new position is its new position))
        
        // (diff.x ^ 2, diff.y ^ 2)^0.5
        let distance = pow(pow(node.position.x - newPosition.x, 2) + pow(node.position.y - newPosition.y, 2), 0.5)
        let duration = distance / 1000
        if(animate){
            
            // while it animates scale will be 2 times bigger for first 1/3 and become initial size (2 * 0.5 = 1) for last 1/3
            let translate = SKAction.moveTo(newPosition, duration: NSTimeInterval(duration))
            let scale = SKAction.sequence([
                SKAction.scaleBy(2, duration: NSTimeInterval(duration / 3)),
                SKAction.waitForDuration(NSTimeInterval(duration / 3)),
                SKAction.scaleBy(0.5, duration: NSTimeInterval(duration / 3)),
                
                // return to zposition at end
                SKAction.runBlock({ self.node.zPosition = 1 })
            ])
            node.zPosition = 2
            node.runAction(translate)
            node.runAction(scale)
        } else {
            node.position = newPosition
        }
        return NSTimeInterval(duration)
    }
    
    func jumpAlongPath(path: [(jump: Tile, over: Tile)]) -> NSTimeInterval {
        var startTile = self.owner
        var totalDuration : NSTimeInterval = 0
        var actions : [SKAction] = []
        for (jump, over) in path {
            var animationDuration = moveToTile(jump, animate: false)
            
            // (more than one jump, over) so add for each
            totalDuration += animationDuration
            
            // make the over tile smaller and then make it disappear
            actions.append(SKAction.sequence([
                SKAction.runBlock({ let time = self.moveToTile(jump) }),
                
                // make the thru disappear
                SKAction.runBlock({ over.checker!.node.runAction(SKAction.scaleBy(0.01, duration: animationDuration)) }),
                SKAction.runBlock({ over.checker = nil }),
                SKAction.waitForDuration(animationDuration)
            ]))
        }

       // do one big move even for multiple jumps
        moveToTile(startTile, animate: false)
        node.runAction(SKAction.sequence(actions))
        return totalDuration
    }

}

enum Player {
    

    case One, Two, AI
    
    var description : String {
        get {
            switch(self) {
            case .One:
                return "PlayerOne"
            case .Two:
                return "PlayerTwo"
            case .AI:
                return "AI"
            }
        }
    }

    func checkerBorder() -> UIColor {
        switch(self){
        case .One: return UIColor(red: 0.667, green: 0.224, blue: 0.224, alpha: 1)
        case .Two: return UIColor(red: 0.133, green: 0.4, blue: 0.4, alpha: 1)
        case .AI: return UIColor(red: 0.133, green: 0.4, blue: 0.4, alpha: 1)
        }
    }
    
    func checkerFill() -> UIColor {
        switch(self){
        case .One: return UIColor(red: 0.831, green: 0.416, blue: 0.416, alpha: 1)
        case .Two: return UIColor(red: 0.251, green: 0.498, blue: 0.498, alpha: 1)
        case .AI: return UIColor(red: 0.251, green: 0.498, blue: 0.498, alpha: 1)
        }
    }
    
    func tileFill() -> UIColor {
        switch(self){
        case .One: return UIColor(red: 0.831, green: 0.416, blue: 0.416, alpha: 1)
        case .Two: return UIColor(red: 0.251, green: 0.498, blue: 0.498, alpha: 1)
        case .AI: return UIColor(red: 0.251, green: 0.498, blue: 0.498, alpha: 1)
        }
    }
    
    func darkestColor() -> UIColor {
        switch(self){
        case .One: return UIColor(red: 0.502, green: 0.082, blue: 0.082, alpha: 1)
        case .Two: return UIColor(red: 0.051, green: 0.302, blue: 0.302, alpha: 1)
        case .AI: return UIColor(red: 0.133, green: 0.4, blue: 0.4, alpha: 1)
        }
    }
    
    func other() -> Player {
        switch(self){
            
        case .One: if (AIGame == true) {
            
            return .AI
        }
        
        else {
            
        return .Two
            
            }
        case .Two: return .One
        case .AI: return .One
        }
        
           }
    
}
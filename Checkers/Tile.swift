//
//  Tile.swift
//  Checkers
//
//  Created by Cal on 11/26/14.
//  Copyright (c) 2014 Cal. All rights reserved.
//

import Foundation
import SpriteKit

class Tile {
    
    let manager : TileManager
    
    // enum (see end of this class)
    let tileColor : TileColor
    let row: Int
    let col: Int
    let tileID : Int
    
    // An SKShapeNode object draws a shape defined by a Core Graphics path.
    let node : SKShapeNode
    
    var checker : Checker?
    
    init(manager: TileManager, row: Int, col: Int, width: Int){
        self.manager = manager
        self.row = row
        self.col = col
        
        // a special number related to the col and row
        self.tileID = manager.idFromGrid(row, col)
        
        
        if ((col + row % 2) % 2 == 0) {
            tileColor = TileColor.Dark
        } else {
            tileColor = TileColor.Light
        }
        
        
        // shape is rect (size of width and height
        self.node = SKShapeNode(rect: CGRect(x: 0, y: 0, width: width, height: width))
        
        // position is col - 1 * width (0 x 3, 1 x 3 etc...)
        self.node.position = CGPointMake(CGFloat((col - 1) * width), CGFloat((row - 1) * width))
        self.node.fillColor = tileColor.color
        self.node.strokeColor = tileColor.color
        self.node.name = "\(tileID)"
        self.node.zPosition = 0
    }
    
    
    // RETURN ALL THE VALID JUMPS (THE LAST ELEMENT IS THE LAST JUMP IN THE MULTIPLE JUMPS
    // THE ONLY THROUGHS STUFF IS AT FIRST: SO DON'T GET CONFUSED
    

    func getValidMoveOptions() -> [Tile] {
        var options : [Tile?] = []
        if (self.checker?.player == Player.One || self.checker?.king == true) {
            
            // Diagonals up-lef and up right
            options.append(manager.getTile(row: self.row + 1, col: self.col + 1))
            options.append(manager.getTile(row: self.row + 1, col: self.col - 1))
        }
        if (self.checker?.player == Player.Two || self.checker?.player == Player.AI || self.checker?.king == true) {
            
            // Diagonals below left and below right
            options.append(manager.getTile(row: self.row - 1, col: self.col + 1))
            options.append(manager.getTile(row: self.row - 1, col: self.col - 1))
        }
        
        
            
        
        var validOptions : [Tile] = []
        
        // safety
        for possibleValid in options {
            if var validTile = possibleValid {
                // if there is no checker then we can move
                if validTile.checker == nil { validOptions.append(validTile) }
            }
        }
        
        return validOptions
    }
    

    
    

    
    // getTheValidJumpOptions(player, isKing: Bool)
    func getValidJumpOptions(#player: Player, isKing: Bool) -> [(jump: Tile, previousSteps: [Tile])] {
        
        // our options for jump (not necesarry valid)
        // through is the tile we jump
        var options : [(target: Tile?, through: Tile?)] = []
        
        // two allowed diagonals for jumping for player 1 and king
        if (player == Player.One || isKing == true) {
            options.append(target: manager.getTile(row: self.row + 2, col: self.col + 2), through: manager.getTile(row: self.row + 1, col: self.col + 1))
            options.append(target: manager.getTile(row: self.row + 2, col: self.col - 2), through: manager.getTile(row: self.row + 1, col: self.col - 1))
        }
        if (player == Player.Two ||  player == Player.AI || isKing == true) {
            options.append(target: manager.getTile(row: self.row - 2, col: self.col + 2), through: manager.getTile(row: self.row - 1, col: self.col + 1))
            options.append(target: manager.getTile(row: self.row - 2, col: self.col - 2), through: manager.getTile(row: self.row - 1, col: self.col - 1))
        }
        
        
        // our valid options for the options above
        var validJumpOptions : [(jump: Tile, previousSteps: [Tile])] = []
        
        for (possibleTarget, through) in options {
            // if possible target is not nil
            if var validTarget = possibleTarget {
                
                // if the destination is nil and the through is the other player then can jump
                if validTarget.checker == nil && through!.checker?.player == player.other() {
                    
                    // PREVIOUS STEPS IS GOING TO BE USE IN FOR MULTIJUMP... LOOP BELOW
                    var previousSteps : [Tile] = []
                    
                    // extend: Append the elements of `newElements`(the arguments) to `self`. (add all the validTargets and the emptyarray previoussteps)
                    
                    // an array of TUPLES (validTarget, [] (no previousSteps)
                    validJumpOptions.extend([(validTarget, previousSteps)])
                    // safety
                    if through != nil {
                        
                        // add the valid targets to previous steps (THE SAME ONE)
                        previousSteps.append(validTarget)
                    }
                  
                 
                    // redo the function recusively: if multiple jump will return other (multiJump, otherSteps) until no jumps
                    // add the new previous steps to our previousSteps array and extend our valid Jump options
                    // if confused: the previous steps and valid Jump Options never get reset because we are still in the loop and we just add the new return value to these arrays
                    for (multiJump, otherSteps) in validTarget.getValidJumpOptions(player: player, isKing: isKing){
                        previousSteps.extend(otherSteps)
                        validJumpOptions.extend([(multiJump, previousSteps)])
                    }
                }
            }
        }
        
        return validJumpOptions
    }
    
 
    

    
    // return the number of moveOptions and jumpOptions after setting these tiles to the color of the player
    func colorMoveChoices(color: UIColor) -> Int{
        var moveOptions = getValidMoveOptions()
        
        // the color of these valid options is the color in argument
        for move in moveOptions {
            move.node.fillColor = color
        }
        
        // if we have a checker on our tile, getValidJumpOptions and color them
        // return the number of moveOptions and jumpOptions after setting these tiles to the color of the player
        if var checker = self.checker {
          
            var jumpOptions = getValidJumpOptions(player: checker.player, isKing: checker.king)
            for (jump, _) in jumpOptions {
        
                jump.node.fillColor = color
            }
            return jumpOptions.count + moveOptions.count
        }
        return moveOptions.count
        }

}

enum TileColor{
    
    case Dark, Light
    
    var color : UIColor {
        get{
            switch(self){
            case Dark: return UIColor(hue: 0, saturation: 0, brightness: 0.6, alpha: 1)
            case Light: return UIColor(hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
            }
            
        }
    }
    
}



//
//  TileManager.swift
//  Checkers
//
//  Created by Cal on 11/27/14.
//  Copyright (c) 2014 Cal. All rights reserved.
//

import Foundation
import SpriteKit

var AIGame = false

// TILE MANAGER IS EQUIVALENT TO THE BOARD
class TileManager {
    
    // [:] emtpy dict
    var tiles : [Int : Tile] = [:]
    
    var currentPlayer : Player? = Player.One
    

    var focusedTile : Tile? = nil
    
    
        
    // # makes the first argument appear when we call the method
    
    
    
    

    func getTile(#row: Int, col: Int) -> Tile?{
        if row > 8 || row < 1 || col > 8 || col < 1 { return nil }
        
        // create a tileId to identify the right tile
        let tileID = idFromGrid(row, col)
        return getTileFromID(tileID)
    }
    
    
    
    func getTileFromID(tileID : Int) -> Tile?{
        

        
        return tiles[tileID]?
    }
    
    init(board: SKNode, tileWidth: Int){
        
       
        
        for row in 1...8 {
            for col in 1...8{
                
  
                let tile = Tile(manager: self, row: row, col: col, width: tileWidth)
                
                // the tile is put into a special index (created by idFromGird) of our tiles array
                tiles[idFromGrid(row, col)] = tile
                board.addChild(tile.node)
                var player : Player? = nil
                
                // (1-2-3 is black) (6-7-8 is red)
                if(row <= 3){
                    player = .One
                }
                if(row >= 6){
                    
                    if AIGame == true {
                        player = .AI
                    }
                    
                    else {
                        player = .Two
                    }
                  
                }
                
                
                // if there is a player (between column 3-0 or 6-8) and the tile is dark (that's where the players go): create a checker
                
                // if player is not nil and tileColor is dark (checkers only on dark tiles)
                if(player != nil && tile.tileColor == TileColor.Dark){
                    let checker = Checker(owner: tile, player: player!)
                    
                    // it is the node that is visible (with color etc...)
                    board.addChild(checker.node)
                }
            }
        }
    }
    
    func idFromGrid(row: Int, _ col: Int) -> Int{
        return (row - 1) * 8 + (col - 1)
    }
    
    
    // return the row and column using the tileId
    
    // way to return the right col and row using the tileId
    func gridFromID(tileID : Int) -> (row: Int, col: Int){
        return (Int(tileID / 8) + 1, (tileID % 8) + 1)
    }
    
    // the argument is the tile
    func processTouch(node : SKNode){
        
      
        
        var isCheckerKing = false
        
        // if the node is not a SKShapeNode (our tile is a rectangle)
        if(!(node is SKShapeNode)) { return }
        
        
    
        // take the tileId from the node
        if var tileID = node.name?.toInt() {
            // get the tile from the tileId (that we got from the node)
            var touched = getTileFromID(tileID)!
            
            //player touched checker
            // (TOUCHED IS A TILE)
            if var checker = touched.checker {
                
                
              
                if checker.player == currentPlayer {
                    
                    
                    // IF WE CLICK ANOTHER TILE AFTER HAVING CLICKED A TILE
                    // if there is a tile already clicked (and we clicked on another one) make the movechoices come back to black (always black, in checker the checker is always on black tiles)
                    if var previousFocus = focusedTile {
                        previousFocus.colorMoveChoices(TileColor.Dark.color)
                    }
                    
                    // make the choices to our color and make the focusedTile (selectedTile) correspond to our tile (touched is our tile)
                    touched.colorMoveChoices(checker.player.tileFill())
                    focusedTile = touched
                }
            }
            
            //player touched tinted tile (tile of possible moves)
            
            // if the tile is red when we are red, of the tile is blue when we are blue
            if ("Optional(\(touched.node.fillColor))") == ("\(currentPlayer?.tileFill())") {
                // if there is a checker on our tile (there mus be)
                if var checker = focusedTile?.checker? {
                    
                    
                    
                    // VALIDMOVES AND VALIDJUMPS ARE THE NOT VALIDMOVES FOR ALL OVER THE BOARD BUT FOR OUR CURRENT TILE (CHECKER.OWNER)
                    // get the validmove (method of tile (checker.owner)) and jump options
                    let validMoves = checker.owner.getValidMoveOptions()
                    
                    // get valid jumps also
                    // checker.king may be false
        
                    // return tuples of final and THRUS!
                    let validJumps = checker.owner.getValidJumpOptions(player: checker.player, isKing: checker.king)
                    
                    // put all the validMoves in an array to reset them to their color later
                    var toResetColor = Array(validMoves)
                    
                    // tuples of destination and the tile jumped (not moved)
                    // put all these tiles in the resetColor array too
                    
                    
                    // also append the tile for validJumps (from the tuple)
                    for (tile, _) in validJumps {
                        toResetColor.append(tile)
                    }
                    
                    var animationDuration = NSTimeInterval(0)
                    
                    //check if regular jump
        
                    for move in validMoves {
                        
                        // if where we touch is a valid move then animate the moveToTile
                        if move.col == touched.col && move.row == touched.row {
                            
                            println(move.row)
                            
                            // change the animationDuration (moveToTile returns a duration)
                            animationDuration = checker.moveToTile(touched, animate: true)
                            
                            if move.row == 8 || move.row == 1 {
                                
                                println("KING")
                                
                                isCheckerKing = true
                               
                                //checker.king = true
                            }

                            break;
                        }
                    }
                    
                    //move is a jump
                    // if an animation means that already a move, so no jump
                    if animationDuration == NSTimeInterval(0) {
                        
                        for (final, thru) in validJumps {
                            
             
                            // if the column with touch is a valid jump
                            if final.col == touched.col && final.row == touched.row {
                                
                                // queue will have the final and thru tiles
                                
                                // THE ARRAY ONLY HAS FINAL ELEMENTS (JUST THRU CAPACITY)
                                // crate an array with capacity of thru (which equals (or more?) than the final)
                                var queue = Array(thru)
                                
                                // append the final destinations of jump to array
                                queue.append(final)
                                var jumpPath : [(jump: Tile, over: Tile)] = []
                                for i in 0...(queue.count - 1) {
                                    
                                    
                                    
                                    // if it is the first item in loop, the previous location of the node is our touch!
                                    // else the previous location is the last jump we appended (see below jumpPath.append(jump: moveTo, over: betweenTile)) THE ONE BEFORE i (i -1)
                                    let previous : Tile = (i == 0 ? focusedTile! : queue[i - 1])
                                    let moveTo = queue[i]
                                    
                                    // the thru row and col (THE PREVIOUS DESTINATION (OUR CURRENT DESTINATION)) + THE NEXT /2
                                    let betweenRow = Int((previous.row + moveTo.row) / 2)
                                    let betweenCol = Int((previous.col + moveTo.col) / 2)
                                    
                                    // put the thru and append to jumpPath(both the final and thru)
                                    if let betweenTile = getTile(row: betweenRow, col: betweenCol) {
                                        
                                       
                                        
                                      
                                        jumpPath.append(jump: moveTo, over: betweenTile)
                                        
                                        if moveTo.row == 0 || moveTo.row == 8 {
                                            println("king")
                                            
                                            isCheckerKing = true
                                            
                                           // moveTo.checker!.king = true
                                        }
                                    }
                                }
                                
                                // jump along path return the animation duration
                                animationDuration = checker.jumpAlongPath(jumpPath)
                                break;
                            }
                        }
                    }
                    
                    // that is included in the animation duration
                    for tile in toResetColor {
                        fadeNode(tile.node, toColor: tile.tileColor.color, inDuration: CGFloat(animationDuration))
                    }
                    
                  
                    if AIGame == false {
                        
                     
                        if isCheckerKing == true {
                            checker.king = true
                            checker.player.checkerFill().colorWithAlphaComponent(0.5)
                            checker.player.checkerBorder().colorWithAlphaComponent(0.5)
                  
                        }
                        var nextPlayer = currentPlayer!.other()
                        // execute the jump for hte checker
                        checker.node.runAction(SKAction.waitForDuration(animationDuration), completion: { self.currentPlayer = nextPlayer })
                    }
                 
                    
                    else {
                      
                      
                        if isCheckerKing == true {
                            checker.king = true
                             checker.player.checkerFill().colorWithAlphaComponent(0.5)
                            checker.player.checkerBorder().colorWithAlphaComponent(0.5)
                        }
                        checker.node.runAction(SKAction.waitForDuration(animationDuration), completion: {
                            self.currentPlayer = Player.AI
                            
                             self.AITurn()
                        })
                       
                        
                        
                        }
                   
                    
                 
                }
            }
        }
    }
    
    
    func AITurn() {
        self.currentPlayer = Player.AI
        var animationDuration = NSTimeInterval(0)
        
        
        var allValidMoves: [(moveTo:Tile, from:Tile)] = []
        var allValidJumpPaths : [(jump: Tile, over: Tile, from:Tile)] = []
        
        for (int, tile) in self.tiles {
            
            var  validJumps: [(jump: Tile, previousSteps: [Tile])] = []
            if (tile.checker?.player == Player.AI) {
                
                if tile.checker!.king == true {
                    validJumps = tile.getValidJumpOptions(player: .AI, isKing: true)
                }
                else {
                    validJumps = tile.getValidJumpOptions(player: .AI, isKing: false)

                }
                
                let validMoves = tile.getValidMoveOptions()
                
                if validJumps.count > 0 {
                    
                    for (final, thru) in validJumps {
                        
                        
                        
                        var queue = Array(thru)
                        
                        // append the final destinations of jump to array
                        queue.append(final)
                        var jumpPath : [(jump: Tile, over: Tile)] = []
                     
                        for i in 0...(queue.count - 1) {
                            
                            
                          
                            let moveTo = queue[i]
                            
                            
                            
                            // the thru row and col (THE PREVIOUS DESTINATION (OUR CURRENT DESTINATION)) + THE NEXT /2
                            let betweenRow = Int((tile.row + moveTo.row) / 2)
                            let betweenCol = Int((tile.col + moveTo.col) / 2)
                            
                            // put the thru and append to jumpPath(both the final and thru)
                            if let betweenTile = getTile(row: betweenRow, col: betweenCol) {
                                
                                
                                jumpPath.append(jump: moveTo, over: betweenTile)
                                allValidJumpPaths.append(jump: moveTo, over: betweenTile, from: tile)
                            }
                        }
                        
                
                        
                    }
                    
                }
                
                
                else if validMoves.count > 0 {
                    
                  
                    // AI Logic
                    
                    
                    
                    
                    
                  
                    
                    //check if regular jump
                    
                    for move in validMoves {
                        
                        // change the animationDuration (moveToTile returns a duration)
                        
                        
                        allValidMoves.append(moveTo:move, from:tile)
                        
       
                    }
                    
                    
                }
                
            }

                
            }
            
        
        
        if allValidJumpPaths.count > 0 {
            for (jump: Tile, over: Tile, from:Tile) in allValidJumpPaths {
                
                // jump along path return the animation duration
                
                var jumpPath : [(jump: Tile, over: Tile)] = []
                
                
               
                jumpPath.append(jump: jump, over: over)
                
                animationDuration = from.checker!.jumpAlongPath(jumpPath)
                
              
                
                from.node.runAction(SKAction.waitForDuration(animationDuration), completion: {
                    
                    if jump.row == 1 {
                        println("king")
                        jump.checker!.king = true
                        
                    }
                    self.currentPlayer = Player.One
                } )
                break
                

            }
            
            
        }
        
        else if allValidMoves.count > 0 {
            
            var randomIndex = arc4random() % UInt32(allValidMoves.count);
            
            
            let move = allValidMoves[Int(randomIndex)]
            
            var moveTo = move.moveTo
            var from = move.from
            
            animationDuration = from.checker!.moveToTile(moveTo, animate: true)
            // execute the jump for hte checker
            if moveTo.row == 1 {
                println("king")
                moveTo.checker!.king = true
                
            }
            from.node.runAction(SKAction.waitForDuration(animationDuration), completion: {
                if moveTo.row == 1 {
                    println("king")
                    moveTo.checker!.king = true
                    
                }
                self.currentPlayer = Player.One})
        }
        
            // if no jump or move
        else {
            
            println("Game Over")
            
        }
        
        
        
    }

    
    

    private func fadeNode(node: SKShapeNode, toColor: UIColor, inDuration duration: CGFloat){
        var startColor : [CGFloat] = [0.0, 0.0, 0.0]
        (startColor: 0.0)
        node.fillColor.getHue(&startColor[0], saturation: &startColor[1], brightness: &startColor[2], alpha: nil)
        var endColor : [CGFloat] = [0.0, 0.0, 0.0]
        
        // THE COLOR IN PARAMETER
        toColor.getHue(&endColor[0], saturation: &endColor[1], brightness: &endColor[2], alpha: nil)
        
        // the tile of the node and the elapsed time
        node.runAction(SKAction.customActionWithDuration(NSTimeInterval(duration), actionBlock: { tile, elapsedTime in
            var percentComplete = elapsedTime / duration
            
            // after 100% stay complete
            if(percentComplete > 1){ percentComplete = 1.0 }
            var newColor : [CGFloat] = []
            
            // the diffrence between the color, brightness, and alpha of starcoor and newcolor
            // for every component: append the newColor, change gradually according to the percent complete
            for i in 0...2{
                
                // one if added to the nodeColor and the other to the endColor (the values change when added?)
                let difference = endColor[i] - startColor[i]
                let newComponent = startColor[i] + (difference * percentComplete)
                newColor.append(newComponent)
            }
            (tile as SKShapeNode).fillColor = SKColor(hue: startColor[0], saturation: newColor[1], brightness: newColor[2], alpha: 1)
        }))
    }
    
    


}
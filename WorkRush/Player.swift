//
//  Player.swift
//  WorkRush
//
//  Created by Justin Barros on 5/31/20.
//  Copyright © 2020 Justin Barros. All rights reserved.
//

import Foundation
import SpriteKit

class Player: SKSpriteNode {
    private var pnode: SKSpriteNode?
    private var playerDead = Bool()
    private var playerScore = 0

    func spawn(name: String="Player",
               size: CGSize=CGSize(width: 75.0, height: 150.0),
               pos: CGPoint=CGPoint(x:0.5, y:0.5),
               zPos: Int=1,
               addPhys: Bool=true) -> SKSpriteNode {
        // Wrapper functions for creating sprites using SKSpriteNode() object.
        let node = SKSpriteNode(imageNamed:name)
        node.name = name
        node.size = size
        node.position = pos
        node.zPosition = CGFloat(zPos)
        if addPhys {
            addPhysics(node:node)
        }
        self.pnode = node
        self.playerDead = false
        return node
    }
        
    func addPhysics(node: SKSpriteNode, gravity: Bool=false) {
        // Wrapper for applying default physicsBody effects on given node.
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: node.size.width, height: node.size.height))
        node.physicsBody?.contactTestBitMask = node.physicsBody?.collisionBitMask ?? 0
        node.physicsBody?.affectedByGravity = gravity
    }
    
    // COLLISION DETECTION BETWEEN PLAYER AND OBJECTS //
    
    func collisionBetween(player: SKNode, object: SKNode) {
        if object.name == "Red Car" || object.name == "Yellow Car" {
            self.playerDead = true
            player.removeFromParent()
        }
    }
    
    func isDead() -> Bool {
        return self.playerDead
    }
    
    func getScore() -> Int {
        return self.playerScore
    }
    
    func setScore(score: Int) {
        self.playerScore = score
    }
    
    func getLocation() -> CGPoint {
        return self.pnode!.position
    }
}

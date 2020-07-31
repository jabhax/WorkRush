//
//  Spawner.swift
//  WorkRush
//
//  Created by Justin Barros on 5/31/20.
//  Copyright © 2020 Justin Barros. All rights reserved.
//

import Foundation
import SpriteKit


class Spawner {
    
    // globals
    private let scene_width: CGFloat?
    private let scene_height: CGFloat?
    private let scene_size: CGSize?
    private let DEFAULT_SPRITE_SIZE = CGSize(width: 75.0, height: 150.0)
    private var difficulty = 1.0
    private var carSpawnRate = 1.5
    private var carMoveDuration = 3.0
    
    init(w: CGFloat, h: CGFloat) {
        self.scene_width = w
        self.scene_height = h
        self.scene_size = CGSize(width: w, height: h)
    }
    
    func spawn(spawnType: String, pos: CGPoint=CGPoint(x:0.5, y:0.5)) -> SKSpriteNode {
        var spawn_obj = SKSpriteNode()
        switch spawnType {
        case "BACKGROUND":
            spawn_obj = createSprite(name: "Background", size: self.scene_size!, zPos: -1)
        case "SIDEWALK":
            spawn_obj = createSprite(name: "Sidewalk", size: self.scene_size!, pos: pos)
        case "RED CAR":
            spawn_obj = createSprite(name: "Red Car", size: self.DEFAULT_SPRITE_SIZE, pos: pos, zPos: 1, addPhys: true)
        case "YELLOW CAR":
            spawn_obj = createSprite(name: "Yellow Car", size: self.DEFAULT_SPRITE_SIZE, pos: pos, zPos: 1, addPhys: true)
        case "ITEMS":
           spawn_obj = createSprite(name: "Item", size: self.scene_size!)
        default:
            print("NO DEFAULT!")
        }
        return spawn_obj
    }
    
    func createSprite(name: String, size: CGSize, pos: CGPoint=CGPoint(x:0.5, y:0.5), zPos: Int=0, addPhys: Bool=false) -> SKSpriteNode {
        // Wrapper functions for creating sprites using SKSpriteNode() object.
        let node = SKSpriteNode(imageNamed:name)
        node.name = name
        node.size = size
        node.position = pos
        node.zPosition = CGFloat(zPos)
        if addPhys {
            addPhysics(node:node)
        }
        return node
    }
        
    func addPhysics(node: SKSpriteNode, gravity: Bool=false) {
        // Wrapper for applying default physicsBody effects on given node.
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: node.size.width, height: node.size.height))
        node.physicsBody?.contactTestBitMask = node.physicsBody?.collisionBitMask ?? 0
        node.physicsBody?.affectedByGravity = gravity
    }
    
    func spawnCars(scene: SKScene) -> SKAction {
        let delay = SKAction.wait(forDuration: Double(self.carSpawnRate / self.difficulty))
        var x = returnRandomNum()
        let randomize = SKAction.run { x = self.returnRandomNum() }
        let run = SKAction.run {
            let car = self.spawn(spawnType: ["RED CAR", "YELLOW CAR"].randomElement()!,
                                 pos: CGPoint(x: x, y: 1000))
            scene.addChild(car)
            self.moveCarDownScreen(car: car)
        }
        let seq = SKAction.sequence([delay, randomize, run])
        let repeatForever = SKAction.repeatForever(seq)
        return repeatForever
    }
    
    func despawnCars(parent: SKScene) {
        // Check y position of all car nodes and delete node if off screen.
        parent.enumerateChildNodes(withName: "*Car", using: ({
            (node, error) in
            if node.position.y < -parent.size.height {
                node.removeFromParent()
            }
        }))
    }
    
    func moveCarDownScreen(car: SKSpriteNode) {
        let moveDown = SKAction.move(to: CGPoint(x: car.position.x, y: -self.scene_height!), duration: Double(self.carMoveDuration / self.difficulty))
        //let moveDown = SKAction.moveBy(x: 0, y:-(self.scene?.size.height)!, duration:100.0)
        car.run(moveDown)
    }
    
    func returnRandomNum() -> Int {
        let randomInt = Int.random(in: -300..<300)
        return randomInt - randomInt % 10
    }
    
    func increaseDifficulty() {
        self.difficulty += 0.5
    }

    func setDifficulty(value: Double) {
        self.difficulty = value
    }
    
    func getDifficulty() -> Double {
        return self.difficulty
    }
}

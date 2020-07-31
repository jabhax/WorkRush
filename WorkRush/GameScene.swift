//
//  GameScene.swift
//  Work Rush
//
//  Created by Justin Barros on 5/22/20.
//  Copyright © 2020 Justin Barros. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    private var scoreLabel: SKLabelNode!
    private var playerController = Player()
    private var spawner: Spawner?
    private var player = SKSpriteNode()
    private var score = Int()
    private var playerSwipe = CGFloat(150)
    private var touchLocation = CGPoint()
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        physicsWorld.contactDelegate = self
        let frameWidth = (self.scene?.size.width)!
        let frameHeight = (self.scene?.size.height)!
        let frameSize = CGSize(width: frameWidth, height: frameHeight)
        spawner = Spawner(w: frameWidth, h: frameHeight)

        let swipeRight : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedRight))
        let swipeLeft : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedLeft))
        let swipeUp : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedUp))
        let swipeDown : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedDown))

        swipeRight.direction = .right
        swipeLeft.direction = .left
        swipeUp.direction = .up
        swipeDown.direction = .down

        view.addGestureRecognizer(swipeRight)
        view.addGestureRecognizer(swipeLeft)
        view.addGestureRecognizer(swipeUp)
        view.addGestureRecognizer(swipeDown)

        buildWorld(worldSize: frameSize)
        self.run(spawner!.spawnCars(scene: self))
        createScoreLabel()
        updateScore()
    }
    
    // SWIPE FUNCTIONS
    
    @objc func swipedRight(sender: UISwipeGestureRecognizer) {
      print("Player swiped RIGHT")
        player.run(SKAction.move(to: CGPoint(x: player.position.x + playerSwipe, y: player.position.y), duration: 0.1))
    }
    
    @objc func swipedLeft(sender: UISwipeGestureRecognizer) {
      print(("Player swiped LEFT"))
        player.run(SKAction.move(to: CGPoint(x: player.position.x - playerSwipe, y: player.position.y), duration: 0.1))
    }
    
    @objc func swipedUp(sender: UISwipeGestureRecognizer) {
      print("Player swiped UP")
        player.run(SKAction.move(to: CGPoint(x: player.position.x, y: player.position.y + playerSwipe), duration: 0.1))
    }
    
    @objc func swipedDown(sender: UISwipeGestureRecognizer) {
      print(("Player swiped DOWN"))
        player.run(SKAction.move(to: CGPoint(x: player.position.x, y: player.position.y - playerSwipe), duration: 0.1))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "Player" {
            playerController.collisionBetween(player: contact.bodyA.node!, object: contact.bodyB.node!)
        }
        else if contact.bodyB.node?.name == "Player" {
            playerController.collisionBetween(player: contact.bodyB.node!, object: contact.bodyA.node!)
        }
    }

    // TOUCH FUNCTIONS //
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self) {
            touchLocation = location
            player.position = location
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Uncomment these lines of code in order to use touch and drag
        let touch = touches.first
        let ploc = playerController.getLocation()
        if let location = touch?.location(in: self) {
            player.run(SKAction.move(to: CGPoint(x: ploc.x + location.x - touchLocation.x, y: ploc.y + location.y - touchLocation.y), duration: 0.1))
        }
    }
    
    // UPDATE //
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        scrollSidewalk()
        spawner!.despawnCars(parent: self)
        gameOver()
    }
    
    // WORLD BUILDING FUNCTIONS //
    
    func buildWorld(worldSize: CGSize) {
        // Create Background, Sidewalke, and Player Sprites
        addChild(spawner!.spawn(spawnType: "BACKGROUND"))
        for i in 0...1 {
            let swPos = CGPoint(x: 0, y: ((self.scene?.size.height)! * CGFloat(i)))
            addChild(spawner!.spawn(spawnType: "SIDEWALK", pos: swPos))
        }
        player = playerController.spawn()
        addChild(player)
    }
    
    func scrollSidewalk() {
        // Get Sidewalk node and check its y position. If off screen, reset to top for scroll effect.
        self.enumerateChildNodes(withName: "Sidewalk", using: ({
            (node, error) in
            node.position.y -= 4
            if node.position.y < -(self.scene?.size.height)! {
                node.position.y += (self.scene?.size.height)! * 2
            }
        }))
    }
    
    func createScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 65
        scoreLabel.name = "playerscorelabel"
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint.init(x: self.frame.minX + 40, y: self.frame.maxY - 40)
        scoreLabel.zPosition = 1
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        addChild(scoreLabel)
        print("Created \(String(describing: scoreLabel.text))")
    }
    
    func updateScore() {
        let wait = SKAction.wait(forDuration: 0.1)
        let update = SKAction.run({
            if self.contains(self.player) {
                self.playerController.setScore(score: self.playerController.getScore() + 1)
                self.scoreLabel.text = "Score: \(self.playerController.getScore())"
                if (self.playerController.getScore() % 100 == 0) {
                    self.spawner!.increaseDifficulty()
                    print("Reached \(String(describing: self.scoreLabel.text)). Difficulty increased to \(self.spawner!.getDifficulty()).")
                }
            }
        })
        let seq = SKAction.sequence([wait,update])
        let rep = SKAction.repeatForever(seq)
        run(rep)
    }
    
    func gameOver() {
        if playerController.isDead() {
            print("Player killed....GAME OVER!")
            for child in self.children {
                child.removeAllActions()
            }
            self.removeAllChildren()
            return
        }
    }
}

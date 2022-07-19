//
//  GameScene.swift
//  SpaceRacerPractice
//
//  Created by Nikita  on 7/18/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
  
    var startField: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    let possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer = Timer()
    var isGameOver = false
    var score = 0{
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    
    }
    var isGrabbed = false
    var counter = 0
    var timeInterval: Double = 1
    var counterForTimer = 20
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        startField = SKEmitterNode(fileNamed: "starfield")
        startField.position = CGPoint(x: 1024, y: 384)
        startField.zPosition = -1
        startField.advanceSimulationTime(10)
        addChild(startField)
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        player.name = "player"
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        addChild(scoreLabel)
        scoreLabel.horizontalAlignmentMode = .left
        score = 0
        
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        
    }
    
    @objc func createEnemy(){
        counter += 1
        if counter == counterForTimer{
            gameTimer.invalidate()
            timeInterval -= 0.1
            gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
           counterForTimer += 20
            print(timeInterval)
        }
        guard let enemy = possibleEnemies.randomElement() else {return}
        let spriteEnemy = SKSpriteNode(imageNamed: enemy)
        spriteEnemy.physicsBody = SKPhysicsBody(texture: spriteEnemy.texture!, size: spriteEnemy.size)
        spriteEnemy.physicsBody?.categoryBitMask = 1
        spriteEnemy.position = CGPoint(x: 1200, y: Int.random(in: 20...900))
        spriteEnemy.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        spriteEnemy.physicsBody?.angularVelocity = CGFloat.random(in: 2...9)
        spriteEnemy.physicsBody?.linearDamping = 0
        spriteEnemy.physicsBody?.angularDamping = CGFloat.random(in: 0...1)
        addChild(spriteEnemy)
        
        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        guard let touch = touches.first else {return}
        var location = touch.location(in: self)
        let touchedNode = nodes(at: location)
        guard let myNode = touchedNode.first else {return}
        
        if location.y > 700{
            location.y = 700
        }
        else if location.y < 20{
            location.y = 20
        }
        if let name = myNode.name{
            if name == "player"{
                isGrabbed = true
            }
        }
        
        if isGrabbed{
            player.position = location
        }
        
        
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
       isGrabbed = false
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children{
            if node.position.x < -100{
                node.removeFromParent()
            }
        }
        if !isGameOver{
            score += 1
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let boom = SKEmitterNode(fileNamed: "explosion") else {return}
        boom.position = player.position
        addChild(boom)
        player.removeFromParent()
        isGameOver = true
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.position = CGPoint(x: 512, y: 384)
        addChild(gameOver)
        gameOver.zPosition = 2
        gameTimer.invalidate()
        startField.isHidden = true
    }
}

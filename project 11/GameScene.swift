//
//  GameScene.swift
//  project 11
//
//  Created by Kristoffer Eriksson on 2020-09-28.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel:  SKLabelNode!
    var score = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    var editLabel: SKLabelNode!
    var editMode: Bool = false {
        didSet{
            if editMode{
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    var ballCount: SKLabelNode!
    var count : Int = 5 {
        didSet{
            ballCount.text = "Ballcount: \(count)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        ballCount = SKLabelNode(fontNamed: "Chalkduster")
        ballCount.text = "Ballcount: 5"
        ballCount.horizontalAlignmentMode = .center
        ballCount.position = CGPoint(x: 490, y: 700)
        addChild(ballCount)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        
        if objects.contains(editLabel){
            editMode.toggle()
        } else {
            if editMode {
                //create a box
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location
                box.name = "box"
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                addChild(box)
                
            } else {
                if count > 0 {
                    var ball: SKSpriteNode
                    let ballColor = Int.random(in: 1...7)
                    
                    switch ballColor {
                    case 1:
                        ball = SKSpriteNode(imageNamed: "ballRed")
                    case 2:
                        ball = SKSpriteNode(imageNamed: "ballGreen")
                    case 3:
                        ball = SKSpriteNode(imageNamed: "ballBlue")
                    case 4:
                        ball = SKSpriteNode(imageNamed: "ballYellow")
                    case 5:
                        ball = SKSpriteNode(imageNamed: "ballPurple")
                    case 6:
                        ball = SKSpriteNode(imageNamed: "ballGrey")
                    case 7:
                        ball = SKSpriteNode(imageNamed: "ballCyan")
                    default:
                        ball = SKSpriteNode(imageNamed: "ballRed")
                    }
                    
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                    ball.physicsBody?.restitution = 0.4
                    ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                    ball.position = CGPoint(x: location.x, y: 768)
                    ball.name = "ball"
                    count -= 1
                    addChild(ball)
                } //else add warning end game
            }
        }
    }
    
    func makeBouncer(at position: CGPoint){
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool){
        var slotBase = SKSpriteNode()
        var slotGlow = SKSpriteNode()
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
        
        addChild(slotBase)
        addChild(slotGlow)
    }
    
    func collision(between ball: SKNode, object: SKNode){
        if object.name == "good"{
            destroy(ball: ball)
            score += 1
            count += 1
        } else if object.name == "bad"{
            destroy(ball: ball)
            score -= 1
            
        } else if object.name == "box"{
            destroy(ball: object)
        }
    }
    func destroy(ball: SKNode){
        
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles"){
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}
        
        if nodeA.name == "ball" {
            collision(between: nodeA, object: nodeB)
        } else if nodeB.name == "ball"{
            collision(between: nodeB, object: nodeA)
        }
    }
}

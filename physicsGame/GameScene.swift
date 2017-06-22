//
//  GameScene.swift
//  physicsGame
//
//  Created by Karol Wojtulewicz on 2017-05-25.
//  Copyright (c) 2017 Karol Wojtulewicz. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var stopWatch : Timer!
    private var textField = UITextField()
    private var label : SKLabelNode?
    private var ball : SKSpriteNode!
    private var pointerBall : SKSpriteNode?
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    
    override func didMove(to view: SKView) {
        
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        textField.frame = CGRect(x: 0, y: 0, width: 100, height: 20)
        
        textField.textColor = UIColor.white
        textField.font = UIFont(name: "helvetica", size: 16)
        textField.text = "lol"
        
        self.view?.addSubview(textField)

        addWall()
        spawnBall()
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 50, y: 100)
        scoreLabel.fontName = "AppleColorEmoji"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.white
        score = 0
        
        self.addChild(scoreLabel)
    


//        // Get label node from scene and store it for use later
//        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
//        if let label = self.label {
//            label.alpha = 0.0
//            label.run(SKAction.fadeIn(withDuration: 2.0))
//        }
//
//        // Create shape node to use during mouse interaction
//        let w = (self.size.width + self.size.height) * 0.05
//        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
//
//        if let spinnyNode = self.spinnyNode {
//            spinnyNode.lineWidth = 2.5
//
//            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
//            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
//                                              SKAction.fadeOut(withDuration: 0.5),
//                                              SKAction.removeFromParent()]))
//        }
        /*ksjdbvs
         ksdj csd
         ksjdbc
         sjd ckds vc
                */
    }
    var wall: SKSpriteNode!

    func addWall(){
        let wallSize = CGSize(width: 20, height: 300)
        wall = SKSpriteNode.init(color: UIKit.UIColor.yellow, size: wallSize)
        wall.size = wallSize
        wall.name = "wall"
        wall.position = CGPoint(x: -self.size.width/2 + wall.size.width/2, y: CGFloat(randomMovement(constant: 200)))
        wall.physicsBody = SKPhysicsBody(rectangleOf: wallSize)
        wall.physicsBody?.angularDamping = 100
        wall.physicsBody?.affectedByGravity = false
        wall.physicsBody?.allowsRotation = false
        wall.physicsBody?.isDynamic = false
        wall.physicsBody?.velocity = CGVector(dx: 0, dy: -100)
        self.addChild(wall)
    }

    private var direction = -1

    func wallMovement(){
        var wall: SKSpriteNode = self.childNode(withName: "wall") as! SKSpriteNode

        if (!intersects(wall)){
            direction = direction * (-1)
            wall.position = CGPoint(x: -self.size.width/2, y: wall.position.y+CGFloat(direction*5))
            print("change")
        }
        print(direction)
        wall.position = CGPoint(x: -self.size.width/2, y: wall.position.y+CGFloat(direction*5))
    }

    func spawnBall(){
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)

        let ballSize = CGSize(width: 100, height: 100)
        ball = SKSpriteNode.init(imageNamed: "/Users/karol/Documents/physicsGame/physicsGame/square.png")
        ball.size = ballSize
        ball.name = "ball"
        ball.position = CGPoint(x: 0, y: -100)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ballSize.height/2)
        ball.physicsBody?.angularDamping = 2
        ball.physicsBody?.affectedByGravity = true
        ball.physicsBody?.allowsRotation = true
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 100, y: self.frame.size.height - 60)
        scoreLabel.fontName = "AppleColorEmoji"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.white
        score = 0
        
        self.addChild(scoreLabel)
        

//        ball.fillColor = SKColor(red: 1, green:0, blue:1, alpha: 2.0)
//        ball.strokeColor = SKColor(red: 0.15, green:0.15, blue:0.3, alpha: 1.0)

        self.addChild(ball)
    }


    private var isDown: Bool = false

    
    func addBlow(pos: CGPoint, direction: CGVector){
        let burstPath = Bundle.main.path(forResource: "Blower",
                                         ofType: "sks")
        
        let burstNode = NSKeyedUnarchiver.unarchiveObject(withFile: burstPath!)
            as! SKEmitterNode
        
        burstNode.position = pos
        burstNode.name = "blow"
        burstNode.emissionAngle = CGFloat.pi/2 + atan(-(ball.position.x-pos.x)/(ball.position.y-pos.y))
        burstNode.physicsBody? = SKPhysicsBody()
        burstNode.physicsBody?.isDynamic = true
        burstNode.numParticlesToEmit = 300
        self.addChild(burstNode)
        
    }
    
    func touchDown(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            self.addChild(n)
//        }
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        isDown = true
        let force = 2500000*sqrt(2)/sqrt(pow((pos.x-ball.position.x+1), 2)+pow(pos.y-ball.position.y+1,2))
        
        let random = randomMovement(constant: 50)
        var forceVector = CGVector(dx: -force*(pos.x-ball.position.x)/sqrt(pow((pos.x-ball.position.x), 2)+pow(pos.y-ball.position.y,2)), dy: -force*(pos.y-ball.position.y)/sqrt(pow((pos.x-ball.position.x), 2)+pow(pos.y-ball.position.y,2)))
        forceVector.dx = CGFloat(random) + forceVector.dx
        
        ball.physicsBody?.applyForce(forceVector, at: CGPoint(x: ball.position.x+CGFloat(random),y: ball.position.y))
        addBlow(pos: pos, direction: forceVector)
        
        
        print(self.isDown)




    }
    
    func randomMovement(constant: Int)->Int{
        let randomize:UInt32 = arc4random_uniform(UInt32(constant))
        let randomNumber: Int = Int(randomize)-constant/2
        return randomNumber
    }

    func spawnPointerBall(){

        pointerBall = SKSpriteNode.init(imageNamed: "/Users/karolwojtulewicz/Documents/Physics Game/physicsGame/physicsGame/ball.png")
        pointerBall?.size = CGSize(width: 100, height: 100)
        pointerBall?.alpha = 0.7
        pointerBall?.position = CGPoint(x: ball.position.x, y: self.frame.maxY-(pointerBall?.size.height)!/4)
        self.addChild(pointerBall!)

    }

    func updatePointerBall(){
        pointerBall?.zRotation = ball.zRotation
        pointerBall?.position = CGPoint(x: ball.position.x, y: self.frame.maxY-(pointerBall?.size.height)!/4)
        pointerBall?.setScale(self.size.height/(ball.position.y+self.size.height))
    }


    
    func touchMoved(toPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.blue
//            self.addChild(n)
//        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.red
//            self.addChild(n)
//        }
        
        let wait = SKAction.wait(forDuration: 0.3)
        
        
        let blow = self.childNode(withName: "blow")
        
        let remove = SKAction.run({() in blow?.removeFromParent()})
        
        self.run(SKAction.sequence([wait, remove]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let label = self.label {
//            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }

    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    func moveToGameOverScene(){
        
        let transition = SKTransition.flipHorizontal(withDuration: 1)
        let gameOverScene = GameOver(size: self.size)
        self.view?.presentScene(gameOverScene, transition: transition)
        
    }

    func checkIfOutOfBounds() {
        if let currentBall = self.childNode(withName: "ball") {
            var isInView: Bool = true
            if(!intersects(currentBall)) {
                isInView = false
                print("node is not in the scene")
                if(currentBall.position.y > self.size.height/2){
                    checkStatePointerBall(inView: isInView)
                }else{
                currentBall.removeFromParent()
                //moveToGameOverScene()
                spawnBall()
                }
            }else {
                checkStatePointerBall(inView: isInView)
            }

        }

    }

    func checkStatePointerBall(inView: Bool){
        if(inView == false){
            if let pointer = pointerBall {
                updatePointerBall()
            }else {
                spawnPointerBall()
            }
        }else {
            pointerBall?.removeFromParent()
            pointerBall = nil
        }

    }
    
    
    override func update(_ currentTime: TimeInterval) {
        checkIfOutOfBounds()
        wallMovement()
        // Called before each frame is rendered
    }
}

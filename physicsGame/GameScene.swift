//
//  GameScene.swift
//  physicsGame
//
//  Created by Karol Wojtulewicz on 2017-05-25.
//  Copyright (c) 2017 Karol Wojtulewicz. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene {
    
    private var stopWatch : Timer!
    private var textField = UITextField()
    private var label : SKLabelNode!
    private var ball : SKSpriteNode!
    private var pointerBall : SKSpriteNode?
    private let manager = CMMotionManager()
    private var looserScreen : Bool = false
    var dayCounter = 0
    var dryer: SKSpriteNode! = nil
    var character: SKSpriteNode! = nil
    var panGesture = UIPanGestureRecognizer()
    

    private var score:Int = 0

    override func didMove(to view: SKView) {
        
        createScoreLabel()
        createBackgrounds()
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.view?.addGestureRecognizer(panGesture)
        
//        createChain()
        spawnBall()
//        createDryer()
    
    }

//
//    func startGyroscope(){
//        manager.deviceMotionUpdateInterval = 0.01
//        manager.startDeviceMotionUpdates(to: OperationQueue.current!){
//            [weak self] (data: CMDeviceMotion?, error: Error?) in
//            if let gravity = data?.gravity {
//                self?.dryer.position.x = (self?.dryer.position.x)! + CGFloat(gravity.x*10)
//            
//            }
//        }
//    }
//    
//    func stopGyroscope(){
//        
//        manager.stopGyroUpdates()
//    }

    func spawnBall(){
        
        ball = SKSpriteNode.init(imageNamed: "banana.png")
        let bHeightRatio = CGFloat(100)/ball.size.height
        let ballSize = CGSize(width: ball.size.width * bHeightRatio, height: 100)
        ball.size = ballSize
        ball.name = "ball"
        ball.position = CGPoint(x: 0, y: 0)
        ball.physicsBody = SKPhysicsBody(texture: ball.texture!, size: ballSize)
        ball.physicsBody?.angularDamping = 2
        ball.physicsBody?.affectedByGravity = true
        ball.physicsBody?.allowsRotation = true
        

        self.addChild(ball)
    }
    
    func createScoreLabel(){
        
        label = SKLabelNode(text: "Score: 0")
        label.position = CGPoint(x: 30, y: 580)
        label.fontName = "AppleColorEmoji"
        label.name = "scoreLabel"
        label.fontColor = UIColor.white
        
        self.addChild(label)
    }

    func addBlow(pos: CGPoint, direction: CGVector){
        let burstPath = Bundle.main.path(forResource: "Blower",
                                         ofType: "sks")
        
        let burstNode = NSKeyedUnarchiver.unarchiveObject(withFile: burstPath!)
            as! SKEmitterNode
        
        burstNode.position = pos
        burstNode.zPosition = -1
        burstNode.name = "blow"
        burstNode.emissionAngle = CGFloat.pi/2 + atan(-(ball.position.x-pos.x)/(ball.position.y-pos.y))
        burstNode.physicsBody? = SKPhysicsBody()
        burstNode.physicsBody?.isDynamic = true
        burstNode.numParticlesToEmit = 300
        self.addChild(burstNode)
        
    }
//
    
    
    func createDryer(){
        let y = CGFloat(400)
        let posY = CGFloat(-self.size.height/2 + y)
        dryer = SKSpriteNode.init(imageNamed: "blower.png")
        dryer.scale(to: CGSize(width: dryer.size.width/4, height: dryer.size.height/4))
        dryer.anchorPoint = CGPoint(x: 0.5, y: 0.9)
        dryer.position = CGPoint(x: 0, y: posY)
        dryer.zPosition = 2
        dryer.name = "dryer"
        self.addChild(dryer)
    }

    func updateDryer(atPoint pos : CGPoint){
        let dryer: SKSpriteNode = self.childNode(withName: "dryer") as! SKSpriteNode
        dryer.zRotation =   atan(-(ball.position.x-pos.x)/(ball.position.y-pos.y))
        let moveBottomLeft = SKAction.move(to: pos, duration:0.1)
        dryer.run(moveBottomLeft, completion: {self.applyForceVector(atPos: pos)})
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
        
        dayLabelUpdate()
        removeSprite()
        
        if(looserScreen){
            hideLabels()
        }
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        let limitY = CGFloat(400)
        let posY = CGFloat(-self.size.height/2 + limitY)
        
        var positionBlow: CGPoint! = nil
        if(pos.y <= limitY){
            positionBlow = CGPoint(x: pos.x , y: pos.y)
        }else{
            positionBlow = CGPoint(x: pos.x , y: posY)
        }
        applyForceVector(atPos: positionBlow)
        
        
//        updateDryer(atPoint: positionBlow)
    
    }
    var endNode: SKSpriteNode! = nil
    
    func createChain(){
        
        let startNode = SKSpriteNode.init(imageNamed: "chain")
//        startNode.scale(to: CGSize(width: 10, height: 10))
        startNode.position = CGPoint(x: -self.size.width/2+startNode.size.width/2, y: -self.size.height/2+startNode.size.width/2)
        startNode.physicsBody = SKPhysicsBody(circleOfRadius: startNode.size.height/2)
        startNode.physicsBody?.affectedByGravity = false
        startNode.physicsBody?.isDynamic = false
        
        var tempNode : SKSpriteNode! = nil
        
        for index in 1...5{
            let node = SKSpriteNode.init(imageNamed: "chain")
            node.position = CGPoint(x: 50, y: 30)
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.height/2)
            node.physicsBody?.affectedByGravity = true
            node.physicsBody?.isDynamic = true
            node.physicsBody?.pinned = true
        
            if(index == 1){
                startNode.addChild(node)
                self.addChild(startNode)
            }else{
                tempNode.addChild(node)
            }
            tempNode = node
        }
        
        
        endNode = SKSpriteNode.init(imageNamed: "chain")
//        endNode.scale(to: CGSize(width: 10, height: 10))
        endNode.position = CGPoint(x: 50, y: 30)
        endNode.physicsBody = SKPhysicsBody(circleOfRadius: startNode.size.height/2)
        endNode.physicsBody?.affectedByGravity = false
        endNode.physicsBody?.isDynamic = false
        endNode.physicsBody?.pinned = true
        tempNode.addChild(endNode)
        
    }
    
    func updateChain(){
        endNode.position = dryer.position
    }

    
    func applyForceVector(atPos pos: CGPoint){
        let force = 2500000*sqrt(2)/sqrt(pow((pos.x-ball.position.x+1), 2)+pow(pos.y-ball.position.y+1,2))
        
        let random = randomNumber(constant: 50)
        var forceVector = CGVector(dx: -force*(pos.x-ball.position.x)/sqrt(pow((pos.x-ball.position.x), 2)+pow(pos.y-ball.position.y,2)), dy: -force*(pos.y-ball.position.y)/sqrt(pow((pos.x-ball.position.x), 2)+pow(pos.y-ball.position.y,2)))
        forceVector.dx = CGFloat(random) + forceVector.dx
        
        ball.physicsBody?.applyForce(forceVector, at: CGPoint(x: ball.position.x+CGFloat(random),y: ball.position.y))
        
        
        let myFunction = SKAction.run({()in self.addBlow(pos: pos, direction: forceVector)})
        let wait = SKAction.wait(forDuration: 0.7)
        let remove = SKAction.run({() in self.removeSprite()})
        self.run(SKAction.sequence([myFunction, wait, remove]))

    }
    
    func removeSprite() {
        
        if let blow = self.childNode(withName: "blow"){
            blow.removeFromParent()
        }
        
    }
    
    
    // range of number between -contant/2 and constant/2
    func randomNumber(constant: Int)->Int{
        let randomize:UInt32 = arc4random_uniform(UInt32(constant))
        let randomNumber: Int = Int(randomize)-constant/2
        return randomNumber
    }

    func spawnPointerBall(){

        pointerBall = SKSpriteNode.init(imageNamed: "ball.png")
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

    }
    
    func touchUp(atPoint pos : CGPoint) {

        
//        let wait = SKAction.wait(forDuration: 0.3)
//        
//        
//        let blow = self.childNode(withName: "blow")
//        
//        let remove = SKAction.run({() in blow?.removeFromParent()})
//        
//        self.run(SKAction.sequence([wait, remove]))
    }
    var countSeconds: Bool = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
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
    
    func createBackgrounds(){
        
        let background1 = SKSpriteNode.init(imageNamed: "background1.png")
        let background2 = SKSpriteNode.init(imageNamed: "background2.png")
        let background3 = SKSpriteNode.init(imageNamed: "background3.png")
        let background4 = SKSpriteNode.init(imageNamed: "background4.png")
        background1.scale(to: CGSize(width: self.size.width, height: self.size.height))
        background1.position = CGPoint(x: 0, y: 0)
        background1.zPosition = -2
        background1.name = "background1"
        background1.alpha = 1
        background2.scale(to: CGSize(width: self.size.width, height: self.size.height))
        background2.position = CGPoint(x: 0, y: 0)
        background2.zPosition = -2
        background2.name = "background2"
        background2.alpha = 0
        background3.scale(to: CGSize(width: self.size.width, height: self.size.height))
        background3.position = CGPoint(x: 0, y: 0)
        background3.zPosition = -2
        background3.name = "background3"
        background3.alpha = 0
        background4.scale(to: CGSize(width: self.size.width, height: self.size.height))
        background4.position = CGPoint(x: 0, y: 0)
        background4.zPosition = -2
        background4.name = "background4"
        background4.alpha = 0

        
        self.addChild(background1)
        self.addChild(background2)
        self.addChild(background3)
        self.addChild(background4)
    }


    
//    func rotateBackground(){
//        let background: SKSpriteNode = self.childNode(withName: "background") as! SKSpriteNode
//        if(background.zRotation >= 2*CGFloat.pi){
//            background.zRotation = 0
//        }else {
//            background.zRotation = background.zRotation + 0.001
//        }
//    }

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
                    print("spawn ball")
                    //moveToGameOverScene()
                    self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
                    showLoser()
                    spawnBall()
                }
            }else {
                checkStatePointerBall(inView: isInView)
            }
            
        }
        
    }
    
    func hideLabels(){
        let lolLabel = self.childNode(withName: "loserLabel") as! SKLabelNode
        let tapLabel = self.childNode(withName: "tapToPlay") as! SKLabelNode
        let blackBG = self.childNode(withName: "blackBG") as! SKShapeNode
        
        lolLabel.removeFromParent()
        tapLabel.removeFromParent()
        blackBG.removeFromParent()
        self.looserScreen = false
    }
    
    func showLoser(){
        
        self.looserScreen = true
        
        createRect()
        
        let lolLabel: SKLabelNode = SKLabelNode(text: "You loose m**********r")
        lolLabel.fontName = "BradleyHandITCTT-Bold "
        lolLabel.fontSize = 50
        lolLabel.name = "loserLabel"
        lolLabel.position = CGPoint(x: 0, y: 200)
        lolLabel.zPosition = 5
        
        let tapTopPlayAgain: SKLabelNode = SKLabelNode(text: "Tap to play again")
        tapTopPlayAgain.fontSize = 36
        tapTopPlayAgain.position = CGPoint(x: 0, y: 0)
        tapTopPlayAgain.name = "tapToPlay"
        tapTopPlayAgain.zPosition = 5
        tapTopPlayAgain.fontName = "AvenirNextCondensed-Regular"
        
        self.addChild(lolLabel)
        self.addChild(tapTopPlayAgain)
    }
    
    func createRect(){
        let cgrRect: CGRect = CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height)
        
        let blackBackground: SKShapeNode = SKShapeNode(rect: cgrRect)
        blackBackground.fillColor = UIColor.black
        blackBackground.alpha = 0.5
        blackBackground.zPosition = 4
        blackBackground.name = "blackBG"
        self.addChild(blackBackground)
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

    func secondCounter(_ currentTime: TimeInterval) -> Bool{

        var delta = TimeInterval()
        if let last = lastUpdateTime {
            delta = currentTime - last
        } else {
            delta = currentTime
        }
        if delta > 1.0 {
            //tick tock, a second has passed, update lastUpdateTime
            lastUpdateTime = currentTime
            return true
        }else {
            return false
        }

    }
    

    var lastUpdateTime: TimeInterval?



    func dayLabelUpdate(){

        score = score + 1
        label.text = String("Score: \(score)")
        
    }
    var sunExists = false

    // whole cycle is 140 seconds
    // day = 70 seconds
    // day -> night transition 10 seconds
    // night 50 seconds
    // night -> day transition 10 seconds

    func checkIfDay() -> Bool{

        if(dayCounter >= 0 && dayCounter <= 1){
            return true
        }else{
            return false
        }
    }

    func startBackgroundSwap(fromBackground bgF: String, toBackground bgT: String){

        let currentBG = self.childNode(withName: bgF) as! SKSpriteNode
        let nextBG =    self.childNode(withName: bgT) as! SKSpriteNode

        let disappear = SKAction.fadeAlpha(to: 0, duration: 5)
        let appear =    SKAction.fadeAlpha(to: 1, duration: 5)
        currentBG.run(disappear)
        nextBG.run(appear)

    }

    func checkIfNight() -> Bool{
        // day = 60 seconds
        if(dayCounter >= 80 && dayCounter <= 85){
            return true
        }else{
            return false
        }
    }

    func spawnStars(_ currentTime: TimeInterval){

        var delta = TimeInterval()
        if let last = lastUpdateTime {
            delta = currentTime - last
        } else {
            delta = currentTime
        }
        if delta > 0.5 {
            createStar()
        }

    }

    func dayNightCycle() {
        if (dayCounter == 70) {
            startBackgroundSwap(fromBackground: "background1", toBackground: "background4")
        } else if(dayCounter == 75){
            startBackgroundSwap(fromBackground: "background4", toBackground: "background2")
        }else if(dayCounter == 134){
            startBackgroundSwap(fromBackground: "background2", toBackground: "background3")
        }else if(dayCounter == 139){
            startBackgroundSwap(fromBackground: "background3", toBackground: "background1")
        }
    }
    func createStar(){
        let star: SKSpriteNode = SKSpriteNode.init(imageNamed: "star.png")
        star.position = CGPoint(x: randomNumber(constant: Int(self.size.width)), y: randomNumber(constant: Int(self.size.height)))
        star.scale(to: CGSize(width: 1, height: 1))
        star.zPosition = -1
        let popStar = SKAction.scale(by: 5, duration: 0.5)
        let popBackStar = SKAction.scale(by: 0.80, duration: 0.2)
        let popBackStar2 = SKAction.scale(by: 0.01, duration: 0.3)
        let keepStar = SKAction.move(by: CGVector(dx: 0, dy: 0), duration: 50)
        let removeStar = SKAction.removeFromParent()
        let sequence = SKAction.sequence([popStar,popBackStar, keepStar,popBackStar2, removeStar])
        star.run(sequence)
        self.addChild(star)
    }

    func createSun(){
        let sun: SKSpriteNode = SKSpriteNode.init(imageNamed: "sun.png")
        sun.scale(to: CGSize(width: 1, height: 1))
        sun.position = CGPoint(x: self.size.width/2-sun.size.width/2, y: 150)

        let bezierPath = UIBezierPath(arcCenter: CGPoint(x: 0,y: 150), radius: self.size.width/2-sun.size.width/2 , startAngle: CGFloat(0), endAngle: -CGFloat.pi, clockwise: true)

//        let pathNode = SKShapeNode(path: bezierPath.cgPath)
//        pathNode.strokeColor = UIColor.greenColor()
//        pathNode.lineWidth = 3
//        pathNode.position = CGPoint(x: 0, y: 0)
//        addChild(pathNode)

        let popSun = SKAction.scale(by: 100, duration: 0.5)
        let popBackSun = SKAction.scale(by: 0.95, duration: 0.2)
        let followPath = SKAction.follow(bezierPath.cgPath, asOffset: false, orientToPath: false, duration: 70)
        let popBackSun2 = SKAction.scale(by: 0.01, duration: 0.3)
        let removeSun = SKAction.removeFromParent()

        let sequence = SKAction.sequence([popSun,popBackSun, followPath,popBackSun2, removeSun])
        sun.run(sequence, completion: {self.sunExists = false})

        self.addChild(sun)
    }

    override func update(_ currentTime: TimeInterval) {
        
//        updateChain()
        
        
        checkIfOutOfBounds()
        
        if(!sunExists && checkIfDay()){
            createSun()
//            stopGyroscope()
            sunExists = true
        }
        if(checkIfNight()){
            spawnStars(currentTime)
//            startGyroscope()
        }
    

//        wallMovement()
        dayNightCycle()
        // Called before each frame is rendered
    }
}

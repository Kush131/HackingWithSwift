//
//  GameScene.swift
//  Project17-SwiftyNinja
//
//  Created by Kush, Ryan on 1/22/19.
//  Copyright © 2019 Kush, Ryan. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene {

    var gameEnded = false

    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?

    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!

    var gameScore: SKLabelNode!
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }

    enum SequenceType: CaseIterable {
        case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain
    }

    enum ForceBomb {
        case never, always, random
    }

    var activeSlicePoints = [CGPoint]()
    var activeEnemies = [SKSpriteNode]()

    var livesImages = [SKSpriteNode]()
    var lives = 3

    var isSwooshPlaying = false
    var bombSoundEffect: AVAudioPlayer!

    var popUpTime = 0.9
    var sequence: [SequenceType]!
    var sequencePosition = 0
    var chainDelay = 3.0
    var nextSequenceQueued = true
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)

        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        physicsWorld.speed = 0.85

        createScore()
        createLives()
        createSlices()

        sequence = [.oneNoBomb, .one, .twoWithOneBomb, .two, .three, .four, .chain, .fastChain]

        for _ in 0...1000 {
            let nextSequence = SequenceType.allCases.randomElement()!
            sequence.append(nextSequence)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
            self.tossEnemies()
        }
    }

    func createScore() {
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48

        addChild(gameScore)

        gameScore.position = CGPoint(x: 8, y: 8)
    }

    func createLives() {
        for i in 0 ..< 3 {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
            addChild(spriteNode)
            livesImages.append(spriteNode)
        }
    }

    func createSlices() {
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2

        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 2

        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9

        activeSliceFG.strokeColor = UIColor.white
        activeSliceFG.lineWidth = 5

        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }

    func createEnemy(_ forceBomb: ForceBomb = .random) {
        var enemy = SKSpriteNode()
        var enemyType = Int.random(in: 0...6)

        if forceBomb == .never {
            enemyType = 1
        }
        else if forceBomb == .always {
            enemyType = 0
        }

        if enemyType == 0 {
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"

            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)

            if bombSoundEffect != nil {
                bombSoundEffect.stop()
                bombSoundEffect = nil
            }

            let path = Bundle.main.path(forResource: "sliceBombFuse.caf", ofType: nil)!
            let url = URL(fileURLWithPath: path)
            let sound = try! AVAudioPlayer(contentsOf: url)
            bombSoundEffect = sound
            sound.play()

            let emitter = SKEmitterNode(fileNamed: "sliceFuse")!
            emitter.position = CGPoint(x: 76, y: 64)
            enemy.addChild(emitter)
        }
        else {
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemy"
        }

        // Create a position somewhere on the bottom screen (static y, random x)
        let randomPosition = CGPoint(x: Int.random(in: 64...960), y: -128)
        enemy.position = randomPosition

        // Create an angular velocity for the enemy
        let randomAngularVelocity = CGFloat.random(in: -6...6) / 2.0
        var randomXVelocity = 0

        // Depending on how close we are to the edges of the screen,
        // change the X velocity to accommodate
        if randomPosition.x < 256 {
            randomXVelocity = Int.random(in: 8...15)
        }
        else if randomPosition.x < 512 {
            randomXVelocity = Int.random(in: 3...5)
        }
        else if randomPosition.x < 768 {
            randomXVelocity = -Int.random(in: 3...5)
        }
        else {
            randomXVelocity = -Int.random(in: 8...15)
        }

        let randomYVelocity = Int.random(in: 24...32)

        // Set everything up according to our randomly generated values along with
        // Creating the physics bodies & lack of collisions for enemies
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * 40, dy: randomYVelocity * 40)
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask = 0

        addChild(enemy)
        activeEnemies.append(enemy)
    }

    func tossEnemies() {
        popUpTime *= 0.991
        chainDelay *= 0.991
        physicsWorld.speed *= 1.02

        let sequenceType = sequence[sequencePosition]

        switch sequenceType {
        case .oneNoBomb:
            createEnemy(.never)
        case .one:
            createEnemy()
        case .twoWithOneBomb:
            createEnemy(.never)
            createEnemy(.always)
        case .two:
            createEnemy()
            createEnemy()
        case .three:
            createEnemy()
            createEnemy()
            createEnemy()
        case .four:
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()
        case .chain:
            createEnemy()
            for i in 1...4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0) * Double(i)) { [unowned self] in
                    self.createEnemy()
                }
            }
        case .fastChain:
            createEnemy()
            for i in 1...4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0) * Double(i)) { [unowned self] in
                    self.createEnemy()
                }
            }
        }
        sequencePosition += 1
        nextSequenceQueued = false
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSlicePoints.removeAll(keepingCapacity: true)
        if let touch = touches.first {
            activeSlicePoints.append(touch.location(in: self))

            redrawActiveSlice()

            activeSliceBG.removeAllActions()
            activeSliceFG.removeAllActions()

            activeSliceBG.alpha = 1
            activeSliceFG.alpha = 1
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)

        activeSlicePoints.append(location)
        redrawActiveSlice()

        if !isSwooshPlaying {
            playSwooshSound()
        }
        let nodesAtPoint = nodes(at: location)

        for node in nodesAtPoint {
            if node.name == "enemy" {
                let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy")!
                emitter.position = node.position
                addChild(emitter)

                node.name = ""
                node.physicsBody?.isDynamic = false

                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])

                let seq = SKAction.sequence([group, SKAction.removeFromParent()])
                node.run(seq)

                score += 1

                let index = activeEnemies.index(of: node as! SKSpriteNode)!
                activeEnemies.remove(at: index)

                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            }
            else if node.name == "bomb" {
                let emitter = SKEmitterNode(fileNamed: "sliceHitBomb")!
                emitter.position = node.parent!.position
                addChild(emitter)

                node.name = ""
                node.physicsBody?.isDynamic = false

                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])

                let seq = SKAction.sequence([group, SKAction.removeFromParent()])
                node.run(seq)

                let index = activeEnemies.index(of: node.parent as! SKSpriteNode)!
                activeEnemies.remove(at: index)

                run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                endGame(triggeredByBomb: true)
            }
        }
    }

    func subtractLife() {
        lives -= 1

        run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))

        var life: SKSpriteNode

        if lives == 2 {
            life = livesImages[0]
        }
        else if lives == 1 {
            life = livesImages[1]
        }
        else {
            life = livesImages[2]
            endGame(triggeredByBomb: false)
        }

        life.texture = SKTexture(imageNamed: "sliceLifeGone")

        life.xScale = 1.3
        life.yScale = 1.3
        life.run(SKAction.scale(to: 1, duration: 0.1))
    }

    func endGame(triggeredByBomb: Bool) {
        if gameEnded {
            return
        }

        gameEnded = true
        physicsWorld.speed = 0
        isUserInteractionEnabled = false

        if bombSoundEffect != nil {
            bombSoundEffect.stop()
            bombSoundEffect = nil
        }

        if triggeredByBomb {
            for image in livesImages {
                image.texture = SKTexture(imageNamed: "sliceLifeGone")
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    func redrawActiveSlice() {
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
        }

        while activeSlicePoints.count > 12 {
            activeSlicePoints.remove(at: 0)
        }

        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])

        for i in 1..<activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }

        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
    }

    func playSwooshSound() {
        isSwooshPlaying = true

        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"

        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)

        run(swooshSound) { [unowned self] in
            self.isSwooshPlaying = false
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if activeEnemies.count > 0 {
            for node in activeEnemies {
                if node.position.y < -140 {
                    node.removeAllActions()

                    if node.name == "enemy" {
                        node.name = ""
                        subtractLife()
                        node.removeFromParent()
                    }
                    else if node.name == "bombContainer" {
                        node.name = ""
                        node.removeFromParent()
                    }
                    if let index = activeEnemies.index(of: node) {
                        activeEnemies.remove(at: index)
                    }
                }
            }
        }
        else {
            if !nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popUpTime) { [unowned self] in
                    self.tossEnemies()
                }
                nextSequenceQueued = true
            }
        }

        var bombCount = 0

        for node in activeEnemies {
            if node.name == "bombContainer" {
                bombCount += 1
                break
            }
        }

        if bombCount == 0 {
            // No bombs
            if bombSoundEffect != nil {
                bombSoundEffect.stop()
                bombSoundEffect = nil
            }
        }
    }
}

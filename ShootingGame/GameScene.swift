//
//  GameScene.swift
//  ShootingGame
//
//  Created by Parkdaeho on 2023/10/18.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    var fireTimer = Timer()
    var fireInterval: TimeInterval = 0.3
    
    var meteorTimer = Timer()
    var meteorInterval: TimeInterval = 2.0
    
    var enemyTimer = Timer()
    var enemyInterval: TimeInterval = 1.2
    
    var bossFireTimer1 = Timer()
    var bossFireTimer2 = Timer()
    
    var player: Player!
    var prevLocation: CGPoint!
    
    var cameraNode = SKCameraNode()
    
    var isBossOnScreen = false
    
    let hud = Hud()
    var boss: Boss?
    var bossNumber: Int = 2
    
    override func didMove(to view: SKView) {
        // Set gravity
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        guard let starfield = SKEmitterNode(fileNamed: "starfield") else { return }
        starfield.position = CGPoint(x: size.width / 2, y: size.height)
        starfield.zPosition = 0
        starfield.advanceSimulationTime(30)
        addChild(starfield)
        
        hud.createHud(screenSize: size)
        addChild(hud)
        
        fireTimer = setTimer(interval: fireInterval, function: playerFire)
        meteorTimer = setTimer(interval: meteorInterval, function: addMeteor)
        enemyTimer = setTimer(interval: enemyInterval, function: addEnemy)
        
        player = Player(screenSize: self.size)
        player.position = CGPoint(x: size.width / 2, y: player.size.height * 2)
        addChild(player)
        
        // Add camera
        self.camera = cameraNode
        cameraNode.position.x = size.width / 2
        cameraNode.position.y = size.height / 2
        addChild(cameraNode)
        

    }
    
    func addMeteor() {
        let randomMeteor = arc4random_uniform(UInt32(3)) + 1
        let randomXPos = CGFloat(arc4random_uniform(UInt32(self.size.width)))
        let randomSpeed = TimeInterval(arc4random_uniform(UInt32(5)) + 5)
        
        let texture = Atlas.gameobjects.textureNamed("meteor\(randomMeteor)")
        let meteor = SKSpriteNode(texture: texture)
        meteor.name = "meteor"
        meteor.position = CGPoint(x: randomXPos, y: size.height + meteor.size.height)
        meteor.zPosition = Layer.meteor
        
        // Add physicsBody
        meteor.physicsBody = SKPhysicsBody(texture: texture, size: meteor.size)
        meteor.physicsBody?.categoryBitMask = PhysicsCategory.meteor
        meteor.physicsBody?.contactTestBitMask = 0
        meteor.physicsBody?.collisionBitMask = 0
        
        addChild(meteor)
        
        let moveAct = SKAction.moveTo(y: -meteor.size.height, duration: randomSpeed)
        let rotateAct = SKAction.rotate(toAngle: CGFloat(Double.pi), duration: randomSpeed)
        let moveWithRotateAct = SKAction.group([moveAct, rotateAct])
        let removeAct = SKAction.removeFromParent()
        
        meteor.run(SKAction.sequence([moveWithRotateAct, removeAct]))
    }
    
    func addEnemy() {
        let randEnemy = arc4random_uniform(UInt32(3)) + 1
        let randXPos = player.size.width / 2 + CGFloat(arc4random_uniform(UInt32(size.width - player.size.width / 2)))
        let randSpeed = TimeInterval(arc4random_uniform(UInt32(3)) + 3)
        
        let texture = Atlas.gameobjects.textureNamed("enemy\(randEnemy)")
        let enemy = SKSpriteNode(texture: texture)
        enemy.name = "enemy"
        enemy.position = .init(x: randXPos, y: size.height + enemy.size.height)
        enemy.zPosition = Layer.enemy
        
        addChild(enemy)
        
        // Add physicsBody
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.height / 2)
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        enemy.physicsBody?.contactTestBitMask = 0
        enemy.physicsBody?.collisionBitMask = 0
        
        // add thruster
        guard let thruster = SKEmitterNode(fileNamed: Particle.enemyThruster) else { return }
        thruster.zPosition = Layer.sub
        let thrusterEffectNode = SKEffectNode()
        thrusterEffectNode.addChild(thruster)
        enemy.addChild(thrusterEffectNode)
        
        let moveAct = SKAction.moveTo(y: -enemy.size.height, duration: randSpeed)
        let removeAct = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([moveAct, removeAct]))
    }
    
    func setTimer(interval: TimeInterval, function: @escaping () -> Void ) -> Timer {
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            function()
        }
        return timer
    }
    
    func setTimer(interval: TimeInterval, function: @escaping (CGPoint) -> Void) -> Timer {
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            guard let boss = self.boss else { return }
            function(boss.position)
        }
        timer.tolerance = interval * 0.2
        return timer
    }
    
    func playerFire() {
        let missile = player.createMissile()
        addChild(missile)
        player.fireMissile(missile: missile)
    }
    
    func bossFire() {
        guard let boss = boss else { return }
        let missile = boss.createMissile()
        addChild(missile)
        let action = SKAction.sequence([SKAction.moveTo(y: -missile.size.width, duration: 3.0), SKAction.removeFromParent()])
        missile.run(action)
    }
    
    func bossCircleFire(bPoint: CGPoint) {
        guard let boss = boss else { return }
        
        let separate: Double = 30.0
        let missileSpeed: TimeInterval = 8.0
        
        for i in 0 ..< Int(separate) {
            let r: CGFloat = size.height
            let x: CGFloat = r * CGFloat(cos((Double(i) * 2 * Double.pi / separate)))
            let y: CGFloat = r * CGFloat(sin((Double(i) * 2 * Double.pi / separate)))
            
            let action = SKAction.sequence([SKAction.move(to: CGPoint(x: bPoint.x + x, y: bPoint.y + y), duration: missileSpeed), SKAction.removeFromParent()])
            let missile = boss.createMissile()
            addChild(missile)
            missile.run(action)
        }
    }
    
    func explosion(targetNode: SKSpriteNode, isSmall: Bool) {
        let particle: String!
        if isSmall {
            particle = Particle.hit
        } else {
            particle = Particle.explosion
        }
        guard let explosion = SKEmitterNode(fileNamed: particle) else { return }
        explosion.position = targetNode.position
        explosion.zPosition = targetNode.zPosition
        addChild(explosion)
        run(SKAction.wait(forDuration: 2)) {
            explosion.removeFromParent()
        }
    }
    
    func playerDamageEffect() {
        let flashNode = SKSpriteNode(color: .red, size: size)
        flashNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        flashNode.zPosition = Layer.hud
        addChild(flashNode)
        flashNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.01),
            SKAction.removeFromParent()
        ]))
        
        let moveLeft = SKAction.moveTo(x: size.width / 2 - 5, duration: 0.1)
        let moveRight = SKAction.moveTo(x: size.width / 2 + 5, duration: 0.1)
        let moveCenter = SKAction.moveTo(x: size.width / 2, duration: 0.1)
        let shakeAction = SKAction.sequence([moveLeft, moveRight, moveLeft, moveRight, moveCenter])
        shakeAction.timingMode = .easeInEaseOut
        cameraNode.run(shakeAction)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var location: CGPoint!
        if let touch = touches.first {
            location = touch.location(in: self)
        }
        
        let offsetX = max(min(player.position.x + location.x - prevLocation.x, size.width), 0)
        let offsetY = max(min(player.position.y + location.y - prevLocation.y, size.height), 0)
        let xMover = SKAction.move(to: CGPoint(x: offsetX, y: offsetY), duration: 0)
        self.player.run(SKAction.group([xMover]))
        
        prevLocation = touches.first?.location(in: self)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        prevLocation = touches.first?.location(in: self)
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.player && secondBody.categoryBitMask == PhysicsCategory.meteor {
            print("player and meteor!")
            
            guard let targetNode = secondBody.node as? SKSpriteNode else { return }
            explosion(targetNode: targetNode, isSmall: false)
            targetNode.removeFromParent()
            playerDamageEffect()
        }
        if firstBody.categoryBitMask == PhysicsCategory.player && secondBody.categoryBitMask == PhysicsCategory.enemy {
            print("player and enemy!")
            
            guard let targetNode = secondBody.node as? SKSpriteNode else { return }
            explosion(targetNode: targetNode, isSmall: true)
            targetNode.removeFromParent()
            playerDamageEffect()
            hud.subtractLive()
        }
        if firstBody.categoryBitMask == PhysicsCategory.player && secondBody.categoryBitMask == PhysicsCategory.bossMissile {
            guard let targetNode = secondBody.node as? SKSpriteNode else { return }
            explosion(targetNode: targetNode, isSmall: true)
            targetNode.removeFromParent()
            
            playerDamageEffect()
            hud.subtractLive()
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.missile && secondBody.categoryBitMask == PhysicsCategory.meteor {
            print("missile and meteor!")
            
            guard let targetNode = secondBody.node as? SKSpriteNode else { return }
            explosion(targetNode: targetNode, isSmall: false)
            targetNode.removeFromParent()
            firstBody.node?.removeFromParent()
        }
        if firstBody.categoryBitMask == PhysicsCategory.missile && secondBody.categoryBitMask == PhysicsCategory.enemy {
            print("missile and enemy!")
            
            guard let targetNode = secondBody.node as? SKSpriteNode else { return }
            explosion(targetNode: targetNode, isSmall: true)
            targetNode.removeFromParent()
            firstBody.node?.removeFromParent()
            
            hud.score += 10
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.missile && secondBody.categoryBitMask == PhysicsCategory.boss {
            guard let targetNode = firstBody.node as? SKSpriteNode else { return }
            explosion(targetNode: targetNode, isSmall: true)
            targetNode.removeFromParent()
            
            guard let boss = boss else { return }
            boss.shootCount += 10
            print(boss.shootCount)
            
            if boss.shootCount > boss.maxHp {
                print("boss defeated")
                explosion(targetNode: targetNode, isSmall: false)
                secondBody.node?.removeFromParent()
                self.boss = nil
                self.hud.score += 10
                self.bossNumber -= 1
                isBossOnScreen = false
                
            } else if boss.shootCount >= Int(Double(boss.maxHp) * 0.6) {
                print("boss HP left 40%")
                if boss.bossState == .secondStep {
                    boss.bossState = .thirdStep
                    bossFireTimer2 = setTimer(interval: 3.0, function: bossCircleFire(bPoint:))
                }
            } else if boss.shootCount >= Int(Double(boss.maxHp) * 0.2) {
                print("boss HP left 80%")
                if boss.bossState == .firstStep {
                    boss.bossState = .secondStep
                    bossFireTimer1 = setTimer(interval: 2.0, function: bossFire)
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isBossOnScreen {
            return
        } else if hud.score >= 200 {
            boss = Boss(screenSize: size, level: 2)
            guard let boss = boss else { return }
            addChild(boss)
            boss.appear()
            isBossOnScreen = true
        } else if hud.score >= 20 {
            if bossNumber == 2 {
                boss = Boss(screenSize: size, level: 1)
                guard let boss = boss else { return }
                addChild(boss)
                boss.appear()
                isBossOnScreen = true
            }
        }
    }
}

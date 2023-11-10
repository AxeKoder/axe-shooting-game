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
    
    var player: Player!
    var prevLocation: CGPoint!
    
    override func didMove(to view: SKView) {
        guard let starfield = SKEmitterNode(fileNamed: "starfield") else { return }
        starfield.position = CGPoint(x: size.width / 2, y: size.height)
        starfield.zPosition = 0
        starfield.advanceSimulationTime(30)
        addChild(starfield)
        
        
        fireTimer = setTimer(interval: fireInterval, function: playerFire)
        meteorTimer = setTimer(interval: meteorInterval, function: addMeteor)
        enemyTimer = setTimer(interval: enemyInterval, function: addEnemy)
        
        player = Player(screenSize: self.size)
        player.position = CGPoint(x: size.width / 2, y: player.size.height * 2)
        addChild(player)
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
    
    func playerFire() {
        let missile = self.player.createMissile()
        addChild(missile)
        self.player.fireMissile(missile: missile)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var location: CGPoint!
        if let touch = touches.first {
            location = touch.location(in: self)
        }
        let offsetX = location.x - prevLocation.x
        let offsetY = location.y - prevLocation.y
        if player.position.x + offsetX > size.width || player.position.x + offsetX < 0 || player.position.y + offsetY > size.height || player.position.y + offsetY < 0 {
            print("bypass")
        } else {
            let xMover = SKAction.moveBy(x: offsetX, y: offsetY, duration: 0.02)
            self.player.run(SKAction.group([xMover]))
        }
        
        prevLocation = touches.first?.location(in: self)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        prevLocation = touches.first?.location(in: self)
    }
}

//
//  Player.swift
//  ShootingGame
//
//  Created by Parkdaeho on 2023/10/18.
//

import SpriteKit

final class Player: SKSpriteNode {
    var screenSize: CGSize!
    
    init(screenSize: CGSize) {
        self.screenSize = screenSize
        let playerTexture = Atlas.gameobjects.textureNamed("player")
        super.init(texture: playerTexture, color: SKColor.clear, size: playerTexture.size())
        self.zPosition = Layer.player
        
        // Add Physics body
        self.physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(width: size.width / 3, height: size.height / 3),
            center: CGPoint(x: 0, y: 0)
        )
        self.physicsBody?.categoryBitMask = PhysicsCategory.player
        self.physicsBody?.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.meteor
        self.physicsBody?.collisionBitMask = 0
        
        // Add Thruster
        guard let thruster = SKEmitterNode(fileNamed: Particle.playerThruster) else { return }
        thruster.position.y -= size.height / 2
        thruster.zPosition = Layer.sub
        
        // Fix Alpha blending
        let thrusterEffectNode = SKEffectNode()
        thrusterEffectNode.addChild(thruster)
        addChild(thrusterEffectNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("required init has not been implemented")
    }
    
    func createMissile() -> SKSpriteNode {
        let texture = Atlas.gameobjects.textureNamed("playerMissile")
        let missile = SKSpriteNode(texture: texture)
        missile.position = position
        missile.position.y += size.height
        missile.zPosition = Layer.playerMissile
        
        // Add physicsBody
        missile.physicsBody = SKPhysicsBody(rectangleOf: missile.size)
        missile.physicsBody?.categoryBitMask = PhysicsCategory.missile
        missile.physicsBody?.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.meteor
        missile.physicsBody?.collisionBitMask = 0
        missile.physicsBody?.usesPreciseCollisionDetection = true
        return missile
    }
    
    func fireMissile(missile: SKSpriteNode) {
        var actionArray = [SKAction]()
        actionArray.append(SKAction.moveTo(y: self.screenSize.height + missile.size.height, duration: 0.4))
        actionArray.append(SKAction.removeFromParent())
        missile.run(SKAction.sequence(actionArray))
    }
}

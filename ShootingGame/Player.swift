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
        return missile
    }
    
    func fireMissile(missile: SKSpriteNode) {
        var actionArray = [SKAction]()
        actionArray.append(SKAction.moveTo(y: self.screenSize.height + missile.size.height, duration: 0.4))
        actionArray.append(SKAction.removeFromParent())
        missile.run(SKAction.sequence(actionArray))
    }
}

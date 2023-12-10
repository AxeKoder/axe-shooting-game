//
//  Boss.swift
//  ShootingGame
//
//  Created by Daeho Park on 2023/12/10.
//

import SpriteKit

enum BossState {
    case firstStep
    case secondStep
    case thirdStep
}

final class Boss: SKSpriteNode {
    var screenSize: CGSize!
    var level: Int!
    
    let bossHp: [Int] = [50, 70]
    let maxHp: Int!
    var shootCount: Int = 0
    
    var bossState: BossState! {
        didSet {
            if bossState == .secondStep {
                print(bossState as Any)
            } else if bossState == .thirdStep {
                print(bossState as Any)
            }
        }
    }
    
    init(screenSize: CGSize!, level: Int!) {
        self.screenSize = screenSize
        self.level = level
        self.maxHp = bossHp[level - 1]
        let texture = Atlas.gameobjects.textureNamed(String(format: "boss%d", level))
        
        super.init(texture: texture, color: .clear, size: texture.size())
        
        zPosition = Layer.boss
        physicsBody = SKPhysicsBody(texture: texture, size: size)
        physicsBody?.categoryBitMask = PhysicsCategory.boss
        physicsBody?.contactTestBitMask = 0
        physicsBody?.collisionBitMask = 0
        
        position.x = screenSize.width / 2
        position.y = screenSize.height + texture.size().height
    }
    
    func appear() {
        let duration = 3.0
        let fadeIn = SKAction.moveTo(y: screenSize.height * 0.8, duration: duration)
        run(fadeIn)
    }
    
    func createDamagaTexture() -> SKSpriteNode {
        let texture = Atlas.gameobjects.textureNamed(String(format: "bossdamage%d", level))
        let overlay = SKSpriteNode(texture: texture)
        overlay.position = CGPoint.zero
        overlay.zPosition = Layer.upper
        overlay.colorBlendFactor = 0.0
        return overlay
    }
    
    // TODO: Boss move animation
    func createActions() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

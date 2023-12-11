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
    
    var infiniteMoveRL1 = SKAction()
    var infiniteMoveRL2 = SKAction()
    
    var bossState: BossState! {
        didSet {
            if bossState == .secondStep {
                print(bossState as Any)
                run(infiniteMoveRL1)
            } else if bossState == .thirdStep {
                print(bossState as Any)
                run(infiniteMoveRL2)
                addChild(createDamagaTexture())
            }
        }
    }
    
    init(screenSize: CGSize!, level: Int!) {
        self.screenSize = screenSize
        self.level = level
        self.maxHp = bossHp[level - 1]
        let texture = Atlas.gameobjects.textureNamed(String(format: "boss%d", level))
        bossState = .firstStep
        
        super.init(texture: texture, color: .clear, size: texture.size())
        
        zPosition = Layer.boss
        physicsBody = SKPhysicsBody(texture: texture, size: size)
        physicsBody?.categoryBitMask = PhysicsCategory.boss
        physicsBody?.contactTestBitMask = 0
        physicsBody?.collisionBitMask = 0
        
        position.x = screenSize.width / 2
        position.y = screenSize.height + texture.size().height
        
        createActions()
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
        let duration1 = 3.0
        let moveRight1 = SKAction.moveTo(x: screenSize.width, duration: duration1)
        let moveCenter1 = SKAction.moveTo(x: screenSize.width / 2, duration: duration1)
        let moveLeft1 = SKAction.moveTo(x: 0, duration: duration1)
        let moveRtoL1 = SKAction.sequence([moveRight1, moveCenter1, moveLeft1, moveCenter1])
        infiniteMoveRL1 = SKAction.repeatForever(moveRtoL1)
        
        let duration2 = 0.5
        let moveRight2 = SKAction.moveTo(x: screenSize.width, duration: duration2)
        let moveCenter2 = SKAction.moveTo(x: screenSize.width / 2, duration: duration2)
        let moveLeft2 = SKAction.moveTo(x: 0, duration: duration2)
        let moveRtoL2 = SKAction.sequence([moveRight2, moveCenter2, moveLeft2])
        infiniteMoveRL2 = SKAction.repeatForever(moveRtoL2)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

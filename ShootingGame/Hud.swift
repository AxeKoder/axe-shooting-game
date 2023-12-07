//
//  Hud.swift
//  ShootingGame
//
//  Created by Parkdaeho on 2023/12/07.
//

import SpriteKit

final class Hud: SKNode {
    var screenSize: CGSize!
    var scoreLabel = SKLabelNode()
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var hasTopNotch: Bool {
        UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 24
    }
    
    func createHud(screenSize: CGSize) {
        self.screenSize = screenSize
        addScoreLabel()
        addLives()
    }
    
    var liveArray: [SKSpriteNode] = []
    
    func addScoreLabel() {
        scoreLabel.text = "Score: 0"
        scoreLabel.fontName = "Minercraftory"
        scoreLabel.fontColor = .white
        scoreLabel.fontSize = 20
        scoreLabel.position.x = 20
        if hasTopNotch {
            scoreLabel.position.y = screenSize.height - 84
        } else {
            scoreLabel.position.y = screenSize.height - 40
        }
        
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.zPosition = Layer.hud
        addChild(scoreLabel)
        print("scoreLabel.verticalAlignmentMode = \(scoreLabel.verticalAlignmentMode)")
    }
    
    func addLives() {
        for live in 1...3 {
            let liveNode = SKSpriteNode(texture: Atlas.gameobjects.textureNamed("heart"))
            liveNode.position.x = screenSize.width - 10 - CGFloat(4 - live) * liveNode.size.width
            
            if hasTopNotch {
                liveNode.position.y = screenSize.height - 74
            } else {
                liveNode.position.y = screenSize.height - 30
            }
            
            liveNode.zPosition = Layer.hud
            addChild(liveNode)
            liveArray.append(liveNode)
        }
    }
    
    func subtractLive() {
        guard let liveNode = liveArray.first else { return }
        liveNode.removeFromParent()
        liveArray.removeFirst()
    }
}

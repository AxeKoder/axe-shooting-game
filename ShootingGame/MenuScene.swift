//
//  MenuScene.swift
//  ShootingGame
//
//  Created by Parkdaeho on 2024/01/26.
//

import SpriteKit

final class MenuScene: SKScene {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        guard let starfield = SKEmitterNode(fileNamed: Particle.starfield) else { return }
        starfield.position = CGPoint(x: size.width / 2, y: size.height)
        starfield.zPosition = Layer.starfield
        starfield.advanceSimulationTime(30)
        addChild(starfield)
        
        let titleLabel = SKLabelNode(text: "Space Shooting")
        titleLabel.fontName = "Minercraftory"
        titleLabel.fontSize = 30
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height / 1.3)
        titleLabel.zPosition = Layer.hud
        addChild(titleLabel)
        
        let highscore = UserDefaults.standard.integer(forKey: "highScore")
        let highscoreLabel = SKLabelNode(text: String(format: "High Score: %d", highscore))
        highscoreLabel.fontName = "Minercraftory"
        highscoreLabel.fontSize = 20
        highscoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        highscoreLabel.zPosition = Layer.hud
        addChild(highscoreLabel)
        
        let playBtn = SKSpriteNode(imageNamed: "playBtn")
        playBtn.name = "playBtn"
        playBtn.position = CGPoint(x: size.width / 2, y: size.height / 4)
        playBtn.zPosition = Layer.hud
        addChild(playBtn)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let nodesArray = nodes(at: location)
            if nodesArray.first?.name == "playBtn" {
                let transition = SKTransition.doorsOpenHorizontal(withDuration: 0.5)
                let gameScene = GameScene(size: size)
                gameScene.scaleMode = .aspectFit
                view?.presentScene(gameScene, transition: transition)
            }
        }
    }
    
}

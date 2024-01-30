//
//  ClearScene.swift
//  ShootingGame
//
//  Created by Parkdaeho on 2024/01/26.
//

import SpriteKit

final class ClearScene: SKScene {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        guard let starfield = SKEmitterNode(fileNamed: Particle.starfield) else { return }
        starfield.position = CGPoint(x: size.width / 2, y: size.height)
        starfield.zPosition = Layer.starfield
        starfield.advanceSimulationTime(30)
        addChild(starfield)
        
        let thankLabel = SKLabelNode(text: "Thank you for playing!")
        thankLabel.fontName = "Minercraftory"
        thankLabel.fontSize = 20
        thankLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        thankLabel.zPosition = Layer.hud
        addChild(thankLabel)
        
        let homeLabel = SKLabelNode(text: "Touch to home")
        homeLabel.fontName = "Minercraftory"
        homeLabel.fontSize = 15
        homeLabel.position = CGPoint(x: size.width / 2, y: size.height / 4)
        homeLabel.zPosition = Layer.hud
        addChild(homeLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let menuScene = MenuScene(size: size)
        let transition = SKTransition.doorsCloseHorizontal(withDuration: 0.5)
        menuScene.scaleMode = .aspectFit
        view?.presentScene(menuScene, transition: transition)
    }
}

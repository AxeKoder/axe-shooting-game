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
    
    var meteorTimer = Timer()
    var meteorInterval: TimeInterval = 2.0
    
    var player: Player!
    var prevLocation: CGPoint!
    
    override func didMove(to view: SKView) {
        guard let starfield = SKEmitterNode(fileNamed: "starfield") else { return }
        starfield.position = CGPoint(x: size.width / 2, y: size.height)
        starfield.zPosition = 0
        starfield.advanceSimulationTime(30)
        addChild(starfield)
        
        meteorTimer = setTimer(interval: meteorInterval, function: addMeteor)
        
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
        playerFire()
    }
}

//
//  Constants.swift
//  ShootingGame
//
//  Created by Parkdaeho on 2023/10/18.
//

import SpriteKit

struct Particle {
    static let starfield = "starfield"
    static let playerThruster = "playerThruster"
    static let enemyThruster = "enemyThruster"
}

struct Layer {
    static let sub: CGFloat = -0.1
    static let starfield: CGFloat = 0
    static let meteor: CGFloat = 1
    static let playerMissile: CGFloat = 10
    static let player: CGFloat = 11
    static let enemy: CGFloat = 12
}

struct Atlas {
    static let gameobjects = SKTextureAtlas(named: "Gameobjects")
}

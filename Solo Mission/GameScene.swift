//
//  GameScene.swift
//  Solo Mission
//
//  Created by Romain ROCHE on 23/06/2016.
//  Copyright © 2016 Romain ROCHE. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    static let scale: CGFloat = 1.0 - (1.0 / UIScreen.main().scale)
    
    let space: SpaceNode = SpaceNode()
    let player: SpaceShip = SpaceShip()
    let bulletSound: SKAction = SKAction.playSoundFileNamed("laser.wav", waitForCompletion: false)
    var lastUpdate: TimeInterval = 0.0
    
    // MARK: implementation
    
    override func didMove(to view: SKView) {
        
        // create the life the universe and everything (42)
        space.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        space.zPosition = 0
        self.addChild(space)
        
        // create the player ship
        player.setScale(GameScene.scale)
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)
        self.addChild(player)
        
        // spawn enemies
        startSpawningEnemies()

    }
    
    // MARK: shooting management
    
    func fireBullet() {
        self.addChild(player.fireBullet(destinationY: self.size.height))
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdate != 0 {
            let deltaT = currentTime - lastUpdate
            space.update(deltaT: deltaT)
        }
        lastUpdate = currentTime
    }
    
    // MARK: spawn enemies
    
    func spawnEnemy() {
        
        func random() -> CGFloat {
            return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        }
        
        func random(min: CGFloat, max: CGFloat) -> CGFloat {
            return random() * (max - min) + min
        }
        
        let randomXStart = random(min: -40, max: self.size.width + 40)
        let yStart = self.size.height + 200.0
        
        let randomXEnd = random(min: -40, max: self.size.width + 40)
        let yEnd: CGFloat = -100.0
        
        let enemy = EnemyNode()
        enemy.setScale(GameScene.scale)
        self.addChild(enemy)
        
        enemy.move(from: CGPoint(x: randomXStart, y: yStart),
                   to: CGPoint(x: randomXEnd, y: yEnd))
        
    }
    
    func startSpawningEnemies() {
        let waitAction = SKAction.wait(forDuration: 4)
        let spawnAction = SKAction.run {
            self.spawnEnemy()
        }
        let sequence = SKAction.sequence([waitAction, spawnAction])
        self.run(SKAction.repeatForever(sequence))
    }
    
    // MARK: handle touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBullet()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self)
            let previous = touch.previousLocation(in: self)
            let amountDragged = pointOfTouch.x - previous.x
            
            var x = player.position.x + amountDragged
            x = max(player.size.width / 2, x)
            x = min(self.size.width - player.size.width / 2, x)
            player.position.x = x
            
        }
        
    }
    
}

//
//  EnemyNode.swift
//  Solo Mission
//
//  Created by Romain ROCHE on 24/06/2016.
//  Copyright © 2016 Romain ROCHE. All rights reserved.
//

import SpriteKit
import GameplayKit

enum EnemyShipMove {
    case Straight
    case Curvy
}

class EnemyNode: SKSpriteNode {
    
    let enemySpeed: CGFloat = 1250.0 // (speed is x px per second)
    var move: EnemyShipMove = .Straight
    
    // MARK: init
    
    init() {
        let texture = SKTexture(image: #imageLiteral(resourceName: "enemyShip"))
        let size = CGSize(width: 88, height: 204)
        super.init(texture: texture, color: UIColor.clear, size: size)
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody!.affectedByGravity = false
        self.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        self.physicsBody!.collisionBitMask = PhysicsCategories.None
        self.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        
        // create the fire particles
        if let fire = SKEmitterNode(fileNamed: "ship-fire") {
            fire.position = CGPoint(x: 0.0, y: -(self.size.height/2) + 50.0)
            fire.targetNode = self
            self.addChild(fire)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: move management
    
    private func straightMove(from: CGPoint, to: CGPoint) -> SKAction {
        
        let deltaX = to.x - from.x
        let deltaY = to.y - from.y
        
        let distance = sqrt(pow(deltaX, 2.0) + pow(deltaY, 2.0))
        let duration = distance / enemySpeed
        
        return SKAction.move(to: to, duration: TimeInterval(duration))
    }
    
    private func curvyMove(from: CGPoint, to: CGPoint) -> SKAction {
        
        var deltaX = to.x - from.x
        var deltaY = to.y - from.y
        if arc4random() % 2 == 1 {
            deltaX = -deltaX
            deltaY = -deltaY
        }
        
        let controlPoint0 = CGPoint(x: from.x + deltaX * 0.5, y: from.y)
        let controlPoint1 = CGPoint(x: to.x, y: to.y - deltaY  * 0.5)
        
        let bezierPath: UIBezierPath = UIBezierPath()
        bezierPath.move(to: from)
        bezierPath.addCurve(to: to, controlPoint1: controlPoint0, controlPoint2: controlPoint1)
        
        return SKAction.follow(bezierPath.cgPath, asOffset: false, orientToPath: true, speed: enemySpeed)
    }
    
    func move(from: CGPoint, to: CGPoint, run: @escaping () -> Void = {}) {
        
        // set position
        self.position = from
        
        var moveAction: SKAction? = nil;
        
        switch move {
        case .Straight:
            moveAction = self.straightMove(from: from, to: to)
            // rotate depending on the angle
            let deltaX = to.x - from.x
            let deltaY = to.y - from.y
            let angle =  atan(deltaX/deltaY)
            self.zRotation = CGFloat(M_PI) - angle
            break
        case .Curvy:
            moveAction = self.curvyMove(from: from, to: to)
            break
        }
        
        //let
        let removeAction = SKAction.removeFromParent()
        let runAction = SKAction.run(run)
        let sequence = SKAction.sequence([moveAction!, removeAction, runAction])
        self.run(sequence)
        
    }
    
    func test(closure: (_ anInt: Int, _ aFloat: Float) -> Bool = {_,_ in return false}) {
        if (closure(3, 5.2)) {
            
        } else {
            
        }
    }
    
    func test2() {
        self.test { (anInt, aFloat) -> Bool in
            let value: Float = Float(anInt) * aFloat
            print("value: \(value)")
            return true
        }
    }
    
}

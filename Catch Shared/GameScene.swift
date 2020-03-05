//
//  GameScene.swift
//  Catch Shared
//
//  Created by Paul Jacobs on 3/4/20.
//

import SpriteKit

class GameScene: SKScene {
    
    
    fileprivate var label : SKLabelNode?
    fileprivate var box : SKShapeNode?
    fileprivate var theFallGuy : SKShapeNode?
    fileprivate var spinnyNode : SKShapeNode?

    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    func setUpScene() {
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        self.box = self.childNode(withName: "//box") as? SKShapeNode
        if let label = self.label {
            label.alpha = 1.0
            label.run(SKAction.fadeOut(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.theFallGuy = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)

        if let theFallGuy = self.theFallGuy {
            theFallGuy.fillColor = SKColor.orange
            theFallGuy.strokeColor = SKColor.black
            theFallGuy.position = CGPoint(x: 0, y: 5)
            theFallGuy.physicsBody = SKPhysicsBody(rectangleOf: CGSize.init(width: w, height: w))
            theFallGuy.physicsBody?.mass = 1.0
            theFallGuy.physicsBody?.affectedByGravity = true
            self.addChild(theFallGuy)
        }
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 4.0
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
            
            #if os(watchOS)
                // For watch we just periodically create one of these and let it spin
                // For other platforms we let user touch/mouse events create these
                spinnyNode.position = CGPoint(x: 0.0, y: 0.0)
                spinnyNode.strokeColor = SKColor.red
                self.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 2.0),
                                                                   SKAction.run({
                                                                       let n = spinnyNode.copy() as! SKShapeNode
                                                                       self.addChild(n)
                                                                   })])))
            #endif
        }
    }
    
    #if os(watchOS)
    override func sceneDidLoad() {
        self.setUpScene()
    }
    #else
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    #endif

    func makeSpinny(at pos: CGPoint, color: SKColor) {
        if let spinny = self.spinnyNode?.copy() as! SKShapeNode? {
            spinny.position = pos
            spinny.strokeColor = color
            self.addChild(spinny)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        if let box = self.box {
            box.fillColor = SKColor.green
        }
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.green)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.blue)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let box = self.box {
            box.fillColor = SKColor.white
            
            
        }
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
        
        if let theFallGuy = self.theFallGuy {
            let w = (self.size.width + self.size.height) * 0.05
            theFallGuy.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            theFallGuy.position = CGPoint(x: Int(Float.random(in: -240...240)), y: 350)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let box = self.box {
            box.fillColor = SKColor.red
        }
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
    }
    
   
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {

    override func mouseDown(with event: NSEvent) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        self.makeSpinny(at: event.location(in: self), color: SKColor.green)
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.makeSpinny(at: event.location(in: self), color: SKColor.blue)
    }
    
    override func mouseUp(with event: NSEvent) {
        self.makeSpinny(at: event.location(in: self), color: SKColor.red)
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
    }

}
#endif


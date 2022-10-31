//
//  UserWebAnimationLogin.swift
//  test-app2
//
//  Created by Yonatan Mamo on 30.10.22.
//

import SwiftUI
import SpriteKit

struct UserWebAnimationLoginView: View {
    @StateObject var scene = MyScene(size: UIScreen.main.bounds.size.applying(CGAffineTransform(scaleX: 1, y: 1)),
                                     numOfPoints: 10,
                                     circleRadius: 20,
                                     fieldSourcePositions: [CGPoint(x: 0.1, y: 0.4), CGPoint(x: 0.4, y: 0.4), CGPoint(x: 0.6, y: 0.4), CGPoint(x: 0.8, y: 0.4)])
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .opacity(0)
            // .background
//            ForEach(Array(scene.fieldSourcePositionsNormalized.enumerated()), id: \.offset) { _, position in
//
//                AngularGradient(colors: [
//                    Color(.sRGB,
//                          red: Double(20) / 255,
//                          green: Double(20) / 255,
//                          blue: Double(20) / 255,
//                          opacity: 0.6),
//                        .clear,
//                    Color(.sRGB,
//                          red: Double(10) / 255,
//                          green: Double(10) / 255,
//                          blue: Double(10) / 255,
//                          opacity: 0.5),
//                    Color(.sRGB,
//                          red: Double(20) / 255,
//                          green: Double(20) / 255,
//                          blue: Double(20) / 255,
//                          opacity: 0.6)
//                ], center: .init(x: position.x, y: position.y))
//                    .frame(width: UIScreen.main.bounds.size.applying(CGAffineTransform(scaleX: 1, y: 1)).width,
//                           height: UIScreen.main.bounds.size.applying(CGAffineTransform(scaleX: 1, y: 1)).height)
//                    // .edgesIgnoringSafeArea(.all)
//            }
 
            // simulated points
            ForEach(Array(scene.circlePositions.enumerated()), id: \.offset) { index, position in
                
                scene.links[index]
                    .stroke(lineWidth: 0.6)
                    .foregroundColor(.white.opacity(2.0 / scene.links[index].boundingRect.height))
                    // .foregroundColor(.white.opacity(1.0 - scene.linkLength[index]))
                // Circle()
                Image("image\(index + 1)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: scene.circleRadius)
                    .clipShape(Circle())
                    .position(x: position.x,
                              y: position.y)
                    .foregroundColor(.blue.opacity(0.5))
                    .shadow(radius: 5)
 
                
               // stroke(lineWidth: 0.3)
                    // .shadow(color: .white.opacity(Double.random(in: (0...0.5))), radius: Double.random(in: (0...10)))
     
                
                

            }
   
            // fields
            ForEach(Array(scene.fieldSourcePositions.enumerated()), id: \.offset) { _, position in
                Circle()
                    .frame(width: scene.circleRadius + 5,
                           height: scene.circleRadius + 5)
                    .position(x: position.x,
                              y: position.y)
                    .foregroundColor(.clear)
            }
                   
        }
    }
    
}


class MyScene: SKScene, ObservableObject {
    
    @Published var circlePositions: [CGPoint]
    var fieldSourcePositions: [CGPoint]
    var fieldSourcePositionsNormalized: [CGPoint]
    @Published var links: [Path]
    // @Published var linkLength: [CGFloat]
    
    
    var numOfPoints: Int
    var circleRadius: CGFloat
    
    var shouldSimulate = true
    
    
    init(size: CGSize, numOfPoints: Int, circleRadius: CGFloat, fieldSourcePositions: [CGPoint]) {
        self.numOfPoints = numOfPoints
        self.circleRadius = circleRadius
        self.links =  [Path](repeating: .init(), count: numOfPoints)
        // self.linkLength = [CGFloat](repeating: .leastNonzeroMagnitude, count: numOfPoints)
        self.circlePositions = [CGPoint](repeating: CGPoint(x: 0.5  * size.width, y: 0.5 * size.height), count: numOfPoints)
        self.fieldSourcePositions = fieldSourcePositions.map { $0.applying(CGAffineTransform(scaleX: size.width, y: size.height))}
        self.fieldSourcePositionsNormalized = fieldSourcePositions
      
        super.init(size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func sceneDidLoad() {
        
        guard let scene = self.scene else { return }
        
//        Timer.scheduledTimer(withTimeInterval: 15, repeats: false) {_ in
//             self.shouldSimulate = false
//         }
        // physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        // 4 fields

        fieldSourcePositions.enumerated().forEach { index, position in
            let field = SKFieldNode.radialGravityField()
            field.strength = 0.7
            field.falloff = 0.1
            field.smoothness = 1.0
            let bitmask = UInt32(pow(2.0, Double(index)))
            // print(bitmask)
            field.categoryBitMask = bitmask
            field.position = CGPoint(x: position.x, y: position.y)
            // field.isEnabled = false
            field.name = "field_\(bitmask)"
            addChild(field)
        }
        
        for i in 0..<numOfPoints {
            
            let node = SKShapeNode(circleOfRadius: circleRadius)
            node.position =  CGPoint(x: 0.5  * scene.size.width, y: 0.5 * scene.size.height) // center
            // node.position =  CGPoint(x: CGFloat(i) / CGFloat(numOfPoints)  * scene.size.width, y: scene.size.height - 30) // center
            let physicsBody = SKPhysicsBody(circleOfRadius: circleRadius)
            physicsBody.fieldBitMask = [UInt32]([1, 2, 4, 8]).randomElement()!
           // physicsBody.collisionBitMask =  physicsBody.fieldBitMask
            physicsBody.affectedByGravity = false
            physicsBody.linearDamping = 0.5
            physicsBody.angularDamping = 0.5
           // physicsBody.node?.run(SKAction.speed(to: 0, duration: 1))
            // physicsBody.restitution = 0
            
            node.physicsBody = physicsBody
            node.name = "\(i)"
            // print(node.name)
            
            addChild(node)
        }
        
    }
    
    
    override func didSimulatePhysics() {
        guard shouldSimulate else { return }
        for i in 0..<numOfPoints {
            DispatchQueue.main.async {
                // update positions and links
                if let newPosition = self.childNode(withName: "\(i)")?.position,
                   let fieldBitMask = self.childNode(withName: "\(i)")?.physicsBody?.fieldBitMask,
                   let fieldPos = self.childNode(withName: "field_\(fieldBitMask)")?.position {
                    self.circlePositions[i] = newPosition
                    
                    self.links[i] = Path { path in
                        
                        path.move(to: self.circlePositions[i])
                       //
                        
                        // path.addLine(to: fieldPos)
                        // get the midpoint and wiggle it
                        let controlPoint = CGPoint(x: (fieldPos.x + self.circlePositions[i].x) / 2 + Double(Int.random(in: (-5...5))),
                                                   y: (fieldPos.y + self.circlePositions[i].y) / 2 + Double(Int.random(in: (-5...5))))
                       
                       path.addQuadCurve(to: fieldPos, control: controlPoint)
                    }
                    // self.linkLength[i] = hypot(self.circlePositions[i].x - fieldPos.x,  self.circlePositions[i].y - fieldPos.y)
                    // let initialPoint = CGPoint(x: 0.5  * scene.size.width, y: 0.5 * scene.size.height)
                    // let initialDistance = hypot(initialPoint.x - fieldPos.x,  initialPoint.y - fieldPos.y)
                    // self.linkLength[i] = hypot(self.circlePositions[i].x - fieldPos.x,  self.circlePositions[i].y - fieldPos.y) / initialDistance
                    // print(self.linkLength[i])
                }
            }
        }
    }
    
}


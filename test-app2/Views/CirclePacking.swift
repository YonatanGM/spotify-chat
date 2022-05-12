//
//  CirclePacking.swift
//  test-app2
//
//  Created by Yonatan Mamo on 12.05.22.
//

import SwiftUI

import SwiftUI
import SpriteKit



struct CPCircle: Identifiable {
    var id = UUID()
    var position: CGPoint
    var diameter = Double.random(in: 5...70)
    
    var radius: Double {
        diameter / 2
    }
}



class SKCirclePacking: SKScene, ObservableObject {
    
    var numOfCircles: Int
    @Published var circles: [CPCircle]
    @Published var stopSimulation = false
    

    init(size: CGSize, numOfCircles: Int) {
        self.numOfCircles = numOfCircles
        self.circles = []
        super.init(size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
       
        // physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(origin: self.frame.origin, size: size))

    }
    
    
    override func sceneDidLoad() {
        print("scene did load")
        let points = Array.init(repeating: 1, count: numOfCircles).map { _ in
            CGPoint(x: Double.random(in: 0.01..<1) * size.width,
                    y: Double.random(in: 0.01..<1) * size.height)
            }

        self.circles = points.map { CPCircle(position: $0) }
    
       
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) {_ in
            self.stopSimulation = true
        }
        circles.forEach {
            let box  = SKShapeNode(circleOfRadius: $0.radius)
            box.position = $0.position
            box.physicsBody = SKPhysicsBody(circleOfRadius: $0.radius)
            box.physicsBody?.isResting = true
//            box.physicsBody?.affectedByGravity = false
            box.name = $0.id.uuidString
            // box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
            addChild(box)
        }
        

        
    }
    override func didSimulatePhysics() {

        if !stopSimulation {
            for i in 0..<circles.count {
                if let pos = childNode(withName: circles[i].id.uuidString)?.position {
                    DispatchQueue.main.async {
                        self.circles[i].position = pos
                    }
                    
     
                    // print("smlkd")
                }
            }
        }
        
    }

}

// A sample SwiftUI creating a GameScene and sizing it
// at 300x400 points
struct CPCirclePackingView
: View {
    @StateObject var skScene = SKCirclePacking(size: CGSize(width: 320, height: 532), numOfCircles: 50)
    
    
    @State private var frame: CGSize = .zero
    @State private var shouldLoadSpriteView = false

    var body: some View {

        VStack(spacing: 0) {
            Text("AlbumArtsGoHere")
                .font(.headline)
            NavigationView {
            
                
                GeometryReader { mainReader in
                    
                    if shouldLoadSpriteView {
                        SpriteView(scene: createScene(with: mainReader.size))
                            .opacity(0)
                            .onAppear {
                
                            }
                    }
                    
                    ForEach(0..<skScene.circles.count, id: \.self) { id in

                        let x = skScene.circles[id].position.x
                        let y = skScene.circles[id].position.y
                        let r = skScene.circles[id].radius
                        NavigationLink(destination: {
                            Text("s")
                                
                        }, label: {
                     
                            Image(systemName: "circle.fill")
                                .resizable()
                                .clipShape(Circle())
                                
                                .redacted(reason: .placeholder)
                            
                                .frame(width: r * 1.9,
                                       height: r * 1.9,
                                       alignment: .center)
                            
                                
                                
                               //
                        })
                        .position(x: x,
                                  y: y)
                        .rotation3DEffect(Angle.degrees(180), axis: (0, 0, 1))
                        
                        .border(.blue)

                    }
                    .onAppear {
                        shouldLoadSpriteView = true
                    }
                }
                .border(.green)
                .navigationBarTitle("msjkdc")
                
            }

            
        
        }
        .border(.red)
        .onAppear {
            print("app")
        }
       
        
    }
    
    private func createScene(with size: CGSize) -> SKScene {
        skScene.scaleMode = .aspectFit
        skScene.size = size
        return skScene
    }
}

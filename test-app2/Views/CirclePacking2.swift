//
//  ContentView.swift
//  circle-packing-4
//
//  Created by Yonatan Mamo on 01.06.22.
//

import SwiftUI
import CoreGraphics
import Foundation
import UIKit

struct CircleInGrid: Identifiable {
    let id = UUID()
    let intialCenter: CGPoint
    var center: CGPoint
    var dragTranslation: CGPoint? = .zero
    var alternateCenter: CGPoint {
        CGPoint(x: (center.x + (dragTranslation?.x ?? 0)) * 2 - 1, y: (center.y + (dragTranslation?.y ?? 0)) * 2 - 1) // -1, -1 to 1, 1 range
    }
    var diplayCenter: CGPoint {
        let isTranslatedPointInsideFrame = CGRect(origin: .zero, size: CGSize(width: 1, height: 1)).insetBy(dx: 0.01, dy: 0.01).contains(CGPoint(x: center.x + (dragTranslation?.x ?? 0), y: center.y + (dragTranslation?.y ?? 0)))
        
        return CGPoint(x: isTranslatedPointInsideFrame ?  center.x + (dragTranslation?.x ?? 0) : center.x,
                       y: isTranslatedPointInsideFrame ?  center.y + (dragTranslation?.y ?? 0) : center.y)
        
    }
    
    var radius: Double {
        sqrt(pow(alternateCenter.x, 2) + pow(alternateCenter.y, 2))
        
    }
    var scaleFactor: Double?
    
    var circleWidth: Double {
        Double(UIScreen.main.bounds.width) / 5
        
    }
}

class Grid: ObservableObject {
    @Published var circles: [CircleInGrid] = []
    
    let numOfCircles: Int
    
    var circlesAlongSides: Int {
        Int(ceil(sqrt(Double(numOfCircles))))
        
    }
    
    var sizeMultiplier: Double {
        Double(circlesAlongSides) / 6
    }
    
    
    
    init(numOfCircles: Int) {
        self.numOfCircles = numOfCircles
        makeCircles()
        // circles.removeAll(where: { $0.radius > 1.15 } )
    }
    
    private func makeGrid() -> [CGPoint] {
        var grid: [CGPoint] = []
        
        for i in 0..<circlesAlongSides {
            for j in 0..<circlesAlongSides {
                let gapBetweenCols = 1.0 / Double(circlesAlongSides)
        
                let x = Double(i) / Double(circlesAlongSides - 1)
                let y = (Double(j) / Double(circlesAlongSides - 1)) + (i % 2 == 0 ? gapBetweenCols / 2 : 0) + gapBetweenCols / 2

                var point = CGPoint(x: x * sizeMultiplier,
                                    y: y * sizeMultiplier)
                

                    
                    
                grid.append(point)

            }
        }
        return grid
    }
    
    
    private func makeCircles() {
        circles = makeGrid().map {
            var circle = CircleInGrid(intialCenter: $0, center: $0)
            /*
            if CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
                .contains(CGPoint(x: circle.center.x, y: circle.center.y)) {
                
                circle.center.x = (easeOutSine(circle.alternateCenter.x) + 1.0) / 2.0
                circle.center.y = (easeOutSine(circle.alternateCenter.y) + 1.0) / 2.0
            }
            print(circle.center)
            */
            return circle
        }
        // update scale
        for (index, _) in circles.enumerated() {
            updateScaleOfCircle(with: index)
        }
    }
    
    private func updateScaleOfCircle(with index: Int) {
        let x = circles[index].center.x + (circles[index].dragTranslation?.x ?? 0)
        let y = circles[index].center.y + (circles[index].dragTranslation?.y ?? 0)

        let isNearBorder = !CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
            .inset(by: UIEdgeInsets(top: 0.2 , left: 0.2, bottom: 0.2, right: 0.2))
            .contains(CGPoint(x: x, y: y))
        
        let isAlmostAtBorder =  !CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
            .inset(by: UIEdgeInsets(top: 0.05, left: 0.05, bottom: 0.05, right: 0.05))
            .contains(CGPoint(x: x, y: y))
        
        let isOutsideBorder = !CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
            .contains(CGPoint(x: x, y: y))
        
        if isOutsideBorder {
            circles[index].scaleFactor = 0
        } else if isAlmostAtBorder {
            circles[index].scaleFactor = 0.05
        } else if isNearBorder {
            circles[index].scaleFactor = max(1 - circles[index].radius, 0)
        } else {
            circles[index].scaleFactor = max(1 - circles[index].radius, 0)
        }
    }
    
    func processDragChange(_ value: DragGesture.Value, containerSize: CGSize) {
        // 0...1
        let xTranslation = value.translation.width / containerSize.width
        let yTranslation = value.translation.height / containerSize.width
        
        // update the centers
        for (index, _) in circles.enumerated() {
            circles[index].dragTranslation = CGPoint(x: xTranslation, y: yTranslation)
            updateScaleOfCircle(with: index)
        }
    }
    
    func processDragFinished(_ value: DragGesture.Value, containerSize: CGSize) {

        
        if (circles.filter { $0.alternateCenter.x < -0.25 }).count  == circles.count ||
            (circles.filter { $0.alternateCenter.x > 0.25 }).count  == circles.count ||
            (circles.filter { $0.alternateCenter.y < -0.25 }).count  == circles.count ||
            (circles.filter { $0.alternateCenter.y > 0.25 }).count  == circles.count  {

            for (index, _) in circles.enumerated() {
                circles[index].center = CGPoint(x: circles[index].center.x,
                                                y: circles[index].center.y)
                circles[index].dragTranslation = .zero
                updateScaleOfCircle(with: index)
            }
            
        } else {
            for (index, _) in circles.enumerated() {
               // setCircleSize()
     
                circles[index].center = CGPoint(x: circles[index].center.x + (circles[index].dragTranslation?.x ?? 0),
                                                y: circles[index].center.y + (circles[index].dragTranslation?.y ?? 0))
                circles[index].dragTranslation = .zero
                updateScaleOfCircle(with: index)
            }
        }
       // setCircleSize()
    }
    
    func recenter() {
        for (index, _) in circles.enumerated() {
            circles[index].center = circles[index].intialCenter
            circles[index].dragTranslation = .zero
            updateScaleOfCircle(with: index)
            
        }
        
    }
    /// 0 <= x <= 1
    private func easeOutSine(_ x: Double) -> Double {
        
        return sin(x * Double.pi / 2)
        
    }
    
}


struct ContentView: View {
    @StateObject var grid = Grid(numOfCircles: 50)
    @State var gridSize: CGSize?
    @State var isDragging = false
   
    var body: some View {
        


            
            NavigationView {
                
                VStack {
                    Divider()

                    TopArtistsGrid()

                    Divider()
 
                    ZStack {
                        GeometryReader { geometry in
                            ForEach(grid.circles, id: \.id) { circle in

                                NavigationLink(destination: {
                                    
                                    Text("\(circle.center.y)")
                                        .navigationTitle(circle.id.uuidString.prefix(5))
                              
                            
                                }, label: {
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(.blue, lineWidth: 1)
                                        )
                                        .onAppear {
                                            // print("App0000")
                                        }
                        
                                    
                                        
                                        //.border(.red)

                                    
                                })

                                .frame(width: circle.circleWidth * (circle.scaleFactor ?? 1),
                                       height: circle.circleWidth * (circle.scaleFactor ?? 1) ,
                                       alignment: .center)
                                .position(x: circle.diplayCenter.x * geometry.size.width,
                                          y: circle.diplayCenter.y * geometry.size.width)
                                .animation(.easeIn)
                        
                            }
            
                            .onAppear {
                                // print("width", geometry.size)
                                gridSize = geometry.size
            
                            }
                    }
                
                }
                .frame(width: UIScreen.main.bounds.width - 30, height: UIScreen.main.bounds.width - 30)
                .contentShape(Rectangle())
         
                // .padding()
                .highPriorityGesture(DragGesture()
                .onChanged { value in
                    // print("onchange", value.translation)
                    isDragging = true
                    guard let containerSize = gridSize else { return }
                    grid.processDragChange(value, containerSize: containerSize)
                }
                .onEnded { value in
                   //  print("onend", value.translation)
                    isDragging = false
                    guard let containerSize = gridSize else { return }
                    grid.processDragFinished(value, containerSize: containerSize)
                })

                .overlay(alignment: .bottomTrailing) {
                    Button(action: {
                        grid.recenter()
                    }) {
                    Image(systemName: "scope")
                        .imageScale(.small)
                        .padding(3)
                    }
                }

                Spacer()
            }

            .navigationBarTitle("MUSIQ", displayMode: .inline)
//            .navigationBarHidden(true)
        }
    }


}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


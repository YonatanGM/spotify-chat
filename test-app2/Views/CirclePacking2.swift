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
    var center: CGPoint
    var dragTranslation: CGPoint? = .zero
    var alternateCenter: CGPoint {
        CGPoint(x: (center.x + (dragTranslation?.x ?? 0)) * 2 - 1, y: (center.y + (dragTranslation?.y ?? 0)) * 2 - 1) // -1, -1 to 1, 1 range
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

                grid.append(CGPoint(x: x * sizeMultiplier,
                                    y: y * sizeMultiplier))

            }
        }
        return grid
    }
    
    
    private func makeCircles() {
        circles = makeGrid().map {
            CircleInGrid(center: $0)
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
            .inset(by: UIEdgeInsets(top: 0.1, left: 0.1, bottom: 0.1, right: 0.1))
            .contains(CGPoint(x: x, y: y))
        
        let isOutsideBorder = !CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
            .contains(CGPoint(x: x, y: y))
        
        if isOutsideBorder {
            circles[index].scaleFactor = 0
        } else if isAlmostAtBorder {
            circles[index].scaleFactor = 0.1
        } else if isNearBorder {
            circles[index].scaleFactor = 0.3
        } else {
            circles[index].scaleFactor = max(1 - (1 - exp(-1 * circles[index].radius)), 0)
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
    
}


struct CircleGridView: View {
    @StateObject var grid = Grid(numOfCircles: 81)
    @State var gridSize: CGSize?
    @State var isDragging = false
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    GeometryReader { geometry in
                        ForEach(grid.circles, id: \.id) { circle in
                            let tx = circle.dragTranslation?.x ?? 0
                            let ty = circle.dragTranslation?.y ?? 0
                            let x =  (circle.center.x + tx) * geometry.size.width
                            let y =  (circle.center.y + ty) * geometry.size.width
        //                    Text("\(circle.alternateCenter.y ?? 0, specifier: "%.2f")")
        //                        .font(.footnote)
                            let isPointInsideFrame = !geometry.frame(in: .local).insetBy(dx: 1, dy: 1).contains(CGPoint(x: x, y: y))
                            NavigationLink(destination: {
                                Text("S")
                            }, label: {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(.blue, lineWidth: 1)
                                    )
                    
                                
                                    
                                    //.border(.red)

                                
                            })
                      
                            .frame(width: circle.circleWidth * (circle.scaleFactor ?? 1), height: circle.circleWidth * (circle.scaleFactor ?? 1) , alignment: .center)
                            .position(x: x - (isPointInsideFrame ? (tx * geometry.size.width) : 0),
                                      y: y - (isPointInsideFrame ? (ty * geometry.size.width) : 0))
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

                .border(.red)
                
                Spacer()
            }
        }
    }


}

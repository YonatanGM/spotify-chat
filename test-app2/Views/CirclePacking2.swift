//
//  ContentView.swift
//  circle-packing-4
//
//  Created by Yonatan Mamo on 01.06.22.
//

import SwiftUI
import CoreGraphics
import Foundation

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
    
    

}

class Grid: ObservableObject {
    @Published var circles: [CircleInGrid] = []
    var size: CGSize?
    init(rows: Int, cols: Int) {
        circles = makeGrid(rows: rows, cols: cols).map {
            CircleInGrid(center: $0)
        }
        circles.removeAll(where: { $0.radius > 1.15 } )
        setCircleSize()
        
    }
    
    
    
    private func makeGrid(rows: Int, cols: Int) -> [CGPoint] {
        var grid: [CGPoint] = []
        for i in 0..<rows {
            for j in 0..<cols {
                let gapBetweenCols = 1.0 / Double(cols)
         
                print(Double(i) / Double(rows - 1),
                      (Double(j) / Double(cols - 1)) + (i % 2 == 0 ? gapBetweenCols / 2 : 0) )
                
                let x = Double(i) / Double(rows - 1)
                let y = (Double(j) / Double(cols - 1)) + (i % 2 == 0 ? gapBetweenCols / 2 : 0) + gapBetweenCols / 2

                if y <= 1 {
                    grid.append(CGPoint(x: x,
                                        y: y))
                }

            }
        }
        return grid
    }
    
    func setCircleSize() {
        
        for (index, _) in circles.enumerated() {
            if   circles[index].radius > 0.5 && circles[index].radius < 1  {
                
                circles[index].scaleFactor = 0.25
            }
            else if  circles[index].radius > 1 {
                circles[index].scaleFactor = 0
            } else {
                circles[index].scaleFactor = max(1 - (1 - exp(-1 * circles[index].radius)), 0)
                
            }
            
        }
        
    }
    
    func processDragChange(_ value: DragGesture.Value, containerSize: CGSize) {
        // 0...1
        let xTranslation = value.translation.width / containerSize.width
        let yTranslation = value.translation.height / containerSize.width
        
        // update the centers
        
        for (index, _) in circles.enumerated() {
            // setCircleSize()
            
            circles[index].dragTranslation = CGPoint(x: xTranslation, y: yTranslation)
            if  circles[index].radius > 0.6 && circles[index].radius < 1  {
                circles[index].scaleFactor = 0.25
            } else if  circles[index].radius > 1 {
                circles[index].scaleFactor = 0
            } else {
                circles[index].scaleFactor = max(1 - (1 - exp(-1 * circles[index].radius)), 0)
            }
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
                if circles[index].radius > 0.6 && circles[index].radius < 1 {
                    circles[index].scaleFactor = 0.25
                } else if  circles[index].radius > 1 {
                    circles[index].scaleFactor = 0
                } else {
                    circles[index].scaleFactor = max(1 - (1 - exp(-1 * circles[index].radius)), 0)
                }
                
            }
            
        } else {
            for (index, _) in circles.enumerated() {
               // setCircleSize()

                           
                circles[index].center = CGPoint(x: circles[index].center.x + (circles[index].dragTranslation?.x ?? 0),
                                                y: circles[index].center.y + (circles[index].dragTranslation?.y ?? 0))

                circles[index].dragTranslation = .zero
                if circles[index].radius > 0.6 && circles[index].radius < 1 {
                    circles[index].scaleFactor = 0.25
                } else if  circles[index].radius > 1 {
                    circles[index].scaleFactor = 0
                } else {
                    circles[index].scaleFactor = max(1 - (1 - exp(-1 * circles[index].radius)), 0)
                }
            }
            
            
            
        }
        
       // setCircleSize()
    }
    
    
}


struct ContentView: View {
    @StateObject var grid = Grid(rows: 6, cols: 6)
    @State var gridSize: CGSize?
    @State var isDragging = false
    var body: some View {
        NavigationView {
            ZStack {
                GeometryReader { geometry in
                    ForEach(grid.circles, id: \.id) { circle in
                        let x = (circle.center.x + (circle.dragTranslation?.x ?? 0)) * geometry.size.width
                        let y =  (circle.center.y + (circle.dragTranslation?.y ?? 0)) * geometry.size.width
    //                    Text("\(circle.alternateCenter.y ?? 0, specifier: "%.2f")")
    //                        .font(.footnote)
                        NavigationLink(destination: {
                            Text("S")
                        }, label: {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .clipShape(Circle())
                                
                                //.border(.red)

                            
                        })
                  
                        .frame(width: 70 * (circle.scaleFactor ?? 1), height: 70 * (circle.scaleFactor ?? 1) , alignment: .center)
                        .position(x: x,
                                  y: y)
                        .animation(.easeIn)
                
                    }
        
                    .onAppear {
                        // print("width", geometry.size)
                        gridSize = geometry.size
                        
                    }
                }
            }
            .frame(width: 300, height: 300)
            .contentShape(Rectangle())
     
            // .padding()
            .simultaneousGesture(DragGesture()
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
        }
    }


}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  ContentView.swift
//  circle-packing-4
//
//  Created by Yonatan Mamo on 01.06.22.
//

import SwiftUI
import CoreGraphics
import Foundation

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
    
    

}

class Grid: ObservableObject {
    @Published var circles: [CircleInGrid] = []
    var size: CGSize?
    init(rows: Int, cols: Int) {
        circles = makeGrid(rows: rows, cols: cols).map {
            CircleInGrid(center: $0)
        }
        circles.removeAll(where: { $0.radius > 1.15 } )
        setCircleSize()
        
    }
    
    
    
    private func makeGrid(rows: Int, cols: Int) -> [CGPoint] {
        var grid: [CGPoint] = []
        for i in 0..<rows {
            for j in 0..<cols {
                let gapBetweenCols = 1.0 / Double(cols)
         
                print(Double(i) / Double(rows - 1),
                      (Double(j) / Double(cols - 1)) + (i % 2 == 0 ? gapBetweenCols / 2 : 0) )
                
                let x = Double(i) / Double(rows - 1)
                let y = (Double(j) / Double(cols - 1)) + (i % 2 == 0 ? gapBetweenCols / 2 : 0) + gapBetweenCols / 2

                if y <= 1 {
                    grid.append(CGPoint(x: x,
                                        y: y))
                }

            }
        }
        return grid
    }
    
    func setCircleSize() {
        
        for (index, _) in circles.enumerated() {
            if   circles[index].radius > 0.5 && circles[index].radius < 1  {
                
                circles[index].scaleFactor = 0.25
            }
            else if  circles[index].radius > 1 {
                circles[index].scaleFactor = 0
            } else {
                circles[index].scaleFactor = max(1 - (1 - exp(-1 * circles[index].radius)), 0)
                
            }
            
        }
        
    }
    
    func processDragChange(_ value: DragGesture.Value, containerSize: CGSize) {
        // 0...1
        let xTranslation = value.translation.width / containerSize.width
        let yTranslation = value.translation.height / containerSize.width
        
        // update the centers
        
        for (index, _) in circles.enumerated() {
            // setCircleSize()
            
            circles[index].dragTranslation = CGPoint(x: xTranslation, y: yTranslation)
            if  circles[index].radius > 0.6 && circles[index].radius < 1  {
                circles[index].scaleFactor = 0.25
            } else if  circles[index].radius > 1 {
                circles[index].scaleFactor = 0
            } else {
                circles[index].scaleFactor = max(1 - (1 - exp(-1 * circles[index].radius)), 0)
            }
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
                if circles[index].radius > 0.6 && circles[index].radius < 1 {
                    circles[index].scaleFactor = 0.25
                } else if  circles[index].radius > 1 {
                    circles[index].scaleFactor = 0
                } else {
                    circles[index].scaleFactor = max(1 - (1 - exp(-1 * circles[index].radius)), 0)
                }
                
            }
            
        } else {
            for (index, _) in circles.enumerated() {
               // setCircleSize()

                           
                circles[index].center = CGPoint(x: circles[index].center.x + (circles[index].dragTranslation?.x ?? 0),
                                                y: circles[index].center.y + (circles[index].dragTranslation?.y ?? 0))

                circles[index].dragTranslation = .zero
                if circles[index].radius > 0.6 && circles[index].radius < 1 {
                    circles[index].scaleFactor = 0.25
                } else if  circles[index].radius > 1 {
                    circles[index].scaleFactor = 0
                } else {
                    circles[index].scaleFactor = max(1 - (1 - exp(-1 * circles[index].radius)), 0)
                }
            }
            
            
            
        }
        
       // setCircleSize()
    }
    
    
}


struct ContentView: View {
    @StateObject var grid = Grid(rows: 6, cols: 6)
    @State var gridSize: CGSize?
    @State var isDragging = false
    var body: some View {
        NavigationView {
            ZStack {
                GeometryReader { geometry in
                    ForEach(grid.circles, id: \.id) { circle in
                        let x = (circle.center.x + (circle.dragTranslation?.x ?? 0)) * geometry.size.width
                        let y =  (circle.center.y + (circle.dragTranslation?.y ?? 0)) * geometry.size.width
    //                    Text("\(circle.alternateCenter.y ?? 0, specifier: "%.2f")")
    //                        .font(.footnote)
                        NavigationLink(destination: {
                            Text("S")
                        }, label: {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .clipShape(Circle())
                                
                                //.border(.red)

                            
                        })
                  
                        .frame(width: 70 * (circle.scaleFactor ?? 1), height: 70 * (circle.scaleFactor ?? 1) , alignment: .center)
                        .position(x: x,
                                  y: y)
                        .animation(.easeIn)
                
                    }
        
                    .onAppear {
                        // print("width", geometry.size)
                        gridSize = geometry.size
                        
                    }
                }
            }
            .frame(width: 300, height: 300)
            .contentShape(Rectangle())
     
            // .padding()
            .simultaneousGesture(DragGesture()
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
        }
    }


}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


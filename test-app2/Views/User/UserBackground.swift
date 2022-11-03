//
//  UserBackground.swift
//  test-app2
//
//  Created by Yonatan Mamo on 03.11.22.
//

import SwiftUI
import SDWebImage
import UIImageColors

struct UserBackground: View {
    
    @StateObject var cover = CoverGenerator((3, Int(UIScreen.main.bounds.width / 50)))
    let urls: [String]
    var body: some View {
    
        VStack(spacing: 0) {
            ForEach(Array(cover.grid.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 0) {
                    ForEach(row) { cell in
                        if let image = cell.image {
                            image.resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                // .shadow(radius: 5)
                        } else {
                            Rectangle()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.clear)
                                .background(cell.gradient)
                                .animation(.spring(response: Double(cell.numOfConnectedCells)), value: cell.gradient != nil)
                                
                        }
                    }
                }
            }
        }
        // .border(.red )
        .onAppear {
            cover.drawGrid(with: urls)
        }
    }
}


struct GridCell: Identifiable {
    enum Axis {
        case horizontal
        case vertical
    }
    let id = UUID()
    var url: String? = nil
    let position: (Int, Int)
    var willProcessCell: Bool = false
    let direction: Axis = .horizontal
    var image: Image?
    var gradient: LinearGradient?
    var gradientToAnimate: LinearGradient = LinearGradient(colors: [.clear], startPoint: .center, endPoint: .center)
    var numOfConnectedCells = 0
    var positionInConnectedCells = 0
}

class CoverGenerator: ObservableObject {
    @Published var grid = [[GridCell]]()
    let colors: [Color] = [.blue, .cyan, .green, .indigo, .mint, .orange, .red, .pink, .purple]
                
    let dimension: (Int, Int)
    init(_ dimension: (Int, Int)) {
        self.dimension = dimension
        for i in (0..<dimension.0) {
            var row = [GridCell]()
            for j in (0..<dimension.1) {
                row.append(GridCell(position: (i, j)))
            }
            grid.append(row)
        }
    }
    
    func drawGrid(with urls: [String]) {
        guard !urls.isEmpty else { return }
        // randomly pick the non-empty cells
        var imageCells = [GridCell]()
        var imageCellsCount = 0
        for row in grid {
            for cell in row.shuffled().prefix(3) {
                
                grid[cell.position.0][cell.position.1].willProcessCell = true
                grid[cell.position.0][cell.position.1].url = urls[imageCellsCount % urls.count]
                imageCells.append(grid[cell.position.0][cell.position.1])
                imageCellsCount += 1
                
               
            }
        }
        
        let imageCellsColumnSorted = imageCells.sorted { $0.position.1 < $1.position.1 }
        let imageCellsRowSorted = imageCells.sorted { $0.position.0 < $1.position.0 }
        for i in (0..<dimension.0) {
            for j in (0..<dimension.1) {
                let cell = grid[i][j]
                if !cell.willProcessCell {
                    // decide direction
                    let closestRightCell = imageCellsColumnSorted
                                                .filter { $0.position.0 == cell.position.0 }
                                                .first { $0.position.1 > cell.position.1 }
                    let closestBottomCell = imageCellsRowSorted
                                                .filter { $0.position.1 == cell.position.1 }
                                                .first { $0.position.0 > cell.position.0 }
            

                    if let chosenCell = [closestRightCell, closestBottomCell].compactMap({ $0 }).randomElement() {
                        if let url = chosenCell.url {
                            let directionToSpan: GridCell.Axis = chosenCell.position.0 == cell.position.0 ? .horizontal : .vertical
                            let connectedCells = directionToSpan == .horizontal ? Array(grid[chosenCell.position.0][cell.position.1..<chosenCell.position.1]) :        grid[cell.position.0..<chosenCell.position.0].map { $0[chosenCell.position.1] }
                                
                            for (i, connectedCell) in connectedCells.enumerated() {
                                grid[connectedCell.position.0][connectedCell.position.1].willProcessCell = true
                                grid[connectedCell.position.0][connectedCell.position.1].numOfConnectedCells = connectedCells.count
                                grid[connectedCell.position.0][connectedCell.position.1].positionInConnectedCells = i
                            }
                            SDWebImageManager().loadImage(with: URL(string: url), progress: nil) { [weak self] uiImage, _, _, cacheType, _, _ in
                                guard let uiImage = uiImage else { return }
                                DispatchQueue.main.async {
                                    self?.grid[chosenCell.position.0][chosenCell.position.1].image = Image(uiImage: uiImage)
                                }
        
                                uiImage.getColors(quality: .low) { colors in
                                    guard let uiColor = colors?.background else { return }
                                    let color = Color(uiColor: uiColor)
                                    for (i, connectedCell) in connectedCells.enumerated() {
                                        let gradient = LinearGradient(
                                            colors: [
                                                color.opacity(Double(i) / Double(connectedCells.count)),
                                                color.opacity(Double(i + 1) / Double(connectedCells.count))
                                            ],
                                            startPoint: directionToSpan == .horizontal ? .leading : .top,
                                            endPoint: directionToSpan == .horizontal ? .trailing : .bottom)
                                        DispatchQueue.main.async {
                                            self?.grid[connectedCell.position.0][connectedCell.position.1].gradient = gradient
                                        }
                                    }
                                    
                                }
                                
                            }
                        }
                    }
                    
                }
            }
        }
    }
}


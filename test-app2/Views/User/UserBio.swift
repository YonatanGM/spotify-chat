//
//  UserBio.swift
//  test-app2
//
//  Created by Yonatan Mamo on 29.06.23.
//

import SwiftUI

struct UserBio: View {
    @EnvironmentObject var model: AppStateModel
    let bioText: String?
    var body: some View {
        HStack {
            if let bioText = bioText {
                Text(bioText.trimmingCharacters(in: .punctuationCharacters))
                    .font(.custom("ChristmasWishCalligraphy-Calligraphy", size: 45))
//                    .italic()
                    // .fontWeight(.light)
                    .multilineTextAlignment(.center)
            }
            // .font(.custom("GreatVibes-Regular", size: 30))
            
        }
        .frame(width: 250)
        .foregroundColor(.white)
        .animation(.spring(), value: model.bioCompletions)
    }

}


//
//struct TagCloudView: View {
//    var tags: [String]
//
//    @State private var totalHeight
//          = CGFloat.zero       // << variant for ScrollView/List
//    //    = CGFloat.infinity   // << variant for VStack
//
//    var body: some View {
//        VStack {
//            GeometryReader { geometry in
//                self.generateContent(in: geometry)
//            }
//        }
//        .frame(height: totalHeight)// << variant for ScrollView/List
//        //.frame(maxHeight: totalHeight) // << variant for VStack
//    }
//
//    private func generateContent(in g: GeometryProxy) -> some View {
//        var width = CGFloat.zero
//        var height = CGFloat.zero
//
//        return ZStack(alignment: .topLeading) {
//            ForEach(self.tags, id: \.self) { tag in
//                self.item(for: tag)
//                    .padding([.horizontal, .vertical], 4)
//                    .alignmentGuide(.leading, computeValue: { d in
//                        if (abs(width - d.width) > g.size.width)
//                        {
//                            width = 0
//                            height -= d.height
//                        }
//                        let result = width
//                        if tag == self.tags.last! {
//                            width = 0 //last item
//                        } else {
//                            width -= d.width
//                        }
//                        return result
//                    })
//                    .alignmentGuide(.top, computeValue: {d in
//                        let result = height
//                        if tag == self.tags.last! {
//                            height = 0 // last item
//                        }
//                        return result
//                    })
//            }
//        }.background(viewHeightReader($totalHeight))
//    }
//
//    private func item(for text: String) -> some View {
//        Text(text)
//            .italic()
//            .fontWeight(.light)
//            .foregroundColor(.white)
//    }
//
//    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
//        return GeometryReader { geometry -> Color in
//            let rect = geometry.frame(in: .local)
//            DispatchQueue.main.async {
//                binding.wrappedValue = rect.size.height
//            }
//            return .clear
//        }
//    }
//}

//
//  ViewExtractor.swift
//  Bottom Bar Interactive Navigation
//
//  Created by Abbas on 27/11/2024.
//

import SwiftUI 

extension View {
     
    @ViewBuilder
    func  ViewExtractor (result:@escaping (UIView)-> ())-> some View {
        self
        .background(ViewExtractorHelper(result: result))
        .compositingGroup()
    }
}

fileprivate  struct ViewExtractorHelper : UIViewRepresentable {
    var result : (UIView)-> ()
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
         view.backgroundColor = .clear
         DispatchQueue.main.async {
             if let superview = view.superview?.superview?.subviews.last?.subviews.first{
                 result(superview)
                 
             }
        }
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
   
}

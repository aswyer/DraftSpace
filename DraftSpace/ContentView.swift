//
//  ContentView.swift
//  DraftSpace
//
//  Created by Andrew Sawyer on 2/11/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var arDelegate: ARDelegate
    
    var body: some View {
        ARViewContainer(arDelegate: arDelegate).edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(arDelegate: ARDelegate())
    }
}

//
//  ContentView.swift
//  DraftSpace
//
//  Created by Andrew Sawyer on 2/11/23.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    @ObservedObject var arDelegate: ARDelegate
    
    var body: some View {
        ARViewContainer(arDelegate: arDelegate).edgesIgnoringSafeArea(.all)
            .onTapGesture { location in
                
                //move somewhere else
                
                //anchor
                guard let raycastQuery = arDelegate.sceneView?
                    .raycastQuery(from: location, allowing: .existingPlaneGeometry, alignment: .horizontal)
                else { return }
                
                let raycastResult = arDelegate.sceneView?.session.raycast(raycastQuery)

                guard let worldTransform = raycastResult?.first?.worldTransform else { return }

                //publish
                let modelObject = ModelObject(worldPosition: worldTransform, modelType: .cube, size: 0.05)
                arDelegate.sendItem(modelObject)
                arDelegate.addModelObject(modelObject)
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(arDelegate: ARDelegate())
    }
}

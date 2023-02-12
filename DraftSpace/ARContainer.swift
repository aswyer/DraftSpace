//
//  ARContainer.swift
//  DraftSpace
//
//  Created by Andrew Sawyer on 2/11/23.
//

import Foundation
import ARKit
import SwiftUI
import RealityKit

struct ARViewContainer: UIViewRepresentable {
    
    let model: MainModel
    
    func makeUIView(context: Context) -> some UIView {
        
        let sceneView = ARSCNView(frame: .zero)

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)

        sceneView.delegate = model
        sceneView.session.delegate = model
        model.sceneView = sceneView

        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Prevent the screen from being dimmed after a while as users will likely
        // have long periods of interaction without touching the screen or buttons.
        UIApplication.shared.isIdleTimerDisabled = true
        
        return sceneView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

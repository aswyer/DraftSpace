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
        
        let sceneView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        sceneView.session.run(config)
        
        sceneView.debugOptions = [.showAnchorOrigins]
        
        model.sceneView = sceneView

        UIApplication.shared.isIdleTimerDisabled = true
        
        return sceneView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

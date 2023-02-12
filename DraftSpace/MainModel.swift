//
//  ARDelegate.swift
//  DraftSpace
//
//  Created by Andrew Sawyer on 2/11/23.
//

import Foundation
import SwiftUI
import RealityKit

enum ToolType: String, CaseIterable, Codable {
    
    case sphere, cube, prism, pencil, highlighter, mouse

    var imageName: String {
        switch(self) {
        case .sphere:
            return "circle"
        case .cube:
            return "square"
        case .prism:
            return "triangle"
        case .pencil:
            return  "pencil"
        case .highlighter:
            return "highlighter"
        case .mouse:
            return "hand.point.up.left"
        }
    }
}

enum ViewType {
    case AR, ThreeD
}

@MainActor
class MainModel: NSObject, ObservableObject {
    @Published var buttonSelected : ToolType = .mouse
    @Published var objectColor : Color = .white
    @Published var moveSelected: Bool = false
    @Published var viewType: ViewType = .AR
    @Published var canChangeTool: Bool = true
    @Published var baseColor: Color = .blue
    @Published var objectsPlaced: Int = 0
    @Published var collborators: Int = 0
    @Published var depth: Float = 1
    
    var arModel = ARModel()
    
    func confirmPlacement() {
        
        //anchor
        guard
            let center = arModel.sceneView?.center,
            let raycastQuery = arModel.sceneView?
                .makeRaycastQuery(from: center, allowing: .estimatedPlane, alignment: .any)
        else { return }
        
        let raycastResult = arModel.sceneView?.session.raycast(raycastQuery)
        
        
        //raycast intersection point
        guard let intersectionTransform = raycastResult?.first?.worldTransform else { return }
        let intersectionPosition = SIMD3(
            x: intersectionTransform.columns.3.x,
            y: intersectionTransform.columns.3.y,
            z: intersectionTransform.columns.3.z
        )

        //camera point
        guard let cameraPosition = arModel.sceneView?.cameraTransform.translation else { return }

        //interpolate
        let midpoint = mix(cameraPosition, intersectionPosition, t: depth)

        //convert to 4x4
        let finalTransform = simd_float4x4(
            SIMD4(1, 0, 0, 0),
            SIMD4(0, 1, 0, 0),
            SIMD4(0, 0, 1, 0),
            SIMD4(midpoint.x, midpoint.y, midpoint.z, 1)
        )
        
        //publish
        let modelObject = ModelObject(modelType: .cube, worldTransform: finalTransform, size: 0.2)
        arModel.sendItem(modelObject)
        arModel.addModelObject(modelObject)
    }
}



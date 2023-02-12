//
//  ARDelegate.swift
//  DraftSpace
//
//  Created by Andrew Sawyer on 2/11/23.
//

import Foundation
import SwiftUI

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
        //move somewhere else
        
        //anchor
        guard
            let center = arModel.sceneView?.center,
            let raycastQuery = arModel.sceneView?
            .makeRaycastQuery(from: center, allowing: .estimatedPlane, alignment: .any)
        else { return }
        
        let raycastResult = arModel.sceneView?.session.raycast(raycastQuery)
        
//        guard let intersectionTransform = raycastResult?.first?.worldTransform else { return }
//        let intersectionPosition = SIMD3(
//            x: intersectionTransform.columns.3.x,
//            y: intersectionTransform.columns.3.y,
//            z: intersectionTransform.columns.3.z
//        )
//
//        guard let cameraPosition = model.sceneView?.cameraTransform.translation else { return }
//
//        let midpoint = mix(cameraPosition, intersectionPosition, t: model.depth)
//
//
//        let finalTransform = simd_float4x4(
//            SIMD4(1, 0, 0, 0),
//            SIMD4(0, 1, 0, 0),
//            SIMD4(0, 0, 1, 0),
//            SIMD4(intersectionPosition.x, intersectionPosition.y, intersectionPosition.z, 1)
//        )
//
//        let anchor = ARAnchor(transform: finalTransform)

        guard let anchorWorldTransform = raycastResult?.first?.worldTransform else { return }
        
        //publish
        let modelObject = ModelObject(modelType: .cube, worldTransform: anchorWorldTransform, size: 0.2)
        //ARAnchorContainer(anchor: newAnchor)
        //                        let modelObject = ModelObject(modelType: .cube, position: midpoint, size: 0.05)
        arModel.sendItem(modelObject)
        arModel.addModelObject(modelObject)
    }
}



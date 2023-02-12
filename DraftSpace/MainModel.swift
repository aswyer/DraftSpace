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
    
    case mouse, cube, sphere, text, pencil, highlighter

    var imageName: String {
        switch(self) {
        case .sphere:
            return "circle"
        case .cube:
            return "square"
        case .text:
            return "textformat.size.larger"
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
    @Published var baseColor: Color = .white
    @Published var objectsPlaced: Int = 0
    @Published var collborators: Int = 0
    @Published var depth: Float = 1
    @Published var text: String = "Hello World"
    @Published var size: Float = 0.05
    
//    private var points: []
    
    var arModel = ARModel()
    
    func startDrawing() {
        print("start drawing")
        let modelObject = ModelObject(modelType: .pencil, color: objectColor, size: size, text: text)
        arModel.startRecording(modelObject: modelObject, depth: depth)
    }
    
    func stopDrawing() {
        print("stop drawing")
        arModel.stopRecording()
        arModel.resetDrawing()
        
//        let modelObject = ModelObject(modelType: .pencil, color: objectColor, size: size, text: text)
//        arModel.confirmPlacement(of: modelObject, at: depth)
    }
    
    func confirmPlacement() {
        let modelObject = ModelObject(modelType: buttonSelected, color: objectColor, size: size, text: text)
        arModel.confirmPlacement(of: modelObject, at: depth)
    }
    
    
    
    func reset() {
        arModel.sceneView?.scene.anchors.removeAll()
    }
}



//
//  ModelObject.swift
//  DraftSpace
//
//  Created by Andrew Sawyer on 2/11/23.
//

import Foundation
import RealityKit
import ARKit
import SwiftUI

class ModelObject: Codable {
    
    init(modelType: ToolType, color: Color, size: Float, text: String) {
        self.modelType = modelType
        self.color = color
        self.size = size
        
        self.text = text
    }
    
    var modelType: ToolType
    var worldTransform: simd_float4x4?
    
    var size: Float
    var text: String
    var color: Color
    
    func copy(with zone: NSZone? = nil) -> ModelObject {
        let copy = ModelObject(modelType: modelType, color: color, size: size, text: text)
        return copy
    }
    
    var anchorEntity: AnchorEntity? {
        
        guard let worldTransform = worldTransform else { return nil }
        
        var mesh: MeshResource
        
        switch modelType {
        case .text:
            mesh = MeshResource.generateText(text, extrusionDepth: size/4, font: .systemFont(ofSize: CGFloat(size)), alignment: .center)
        case .sphere:
            mesh = MeshResource.generateSphere(radius: size/2)
        case .cube:
            mesh = MeshResource.generateBox(size: size, cornerRadius: size/8)
        case .pencil:
            mesh = MeshResource.generateSphere(radius: size/8)
            
//            let thickness = size/10
//
//            var positions: [SIMD3<Float>] = []
//            var indices: [UInt32] = []
//
//            func offset(_ point: SIMD3<Float>, x: Float, y: Float) -> SIMD3<Float> {
//                var offsetPoint = point
//                offsetPoint.x += x
//                offsetPoint.y += y
//                return offsetPoint
//            }
//
//            for point in points {
//                let p0 = point
//                let p1 = offset(point, x: <#T##Float#>, y: <#T##Float#>)
//                let p2 = p0 + [0, thickness, 01]
//                let p3 = p1 + [0, thickness, 0]
//
//                let i0 = positions.count
//                let i1 = i0 + 1
//                let 12 = 10 + 2
//                let i3 = i0 + 3
//
//                positions.append(contentsOf: [p0, p1, p2, p3])
//                indices.append(contentsOf: [i0, i2, il, i1, i2, i31)
//            }
            
        default:
            return nil
        }
        
        var material = PhysicallyBasedMaterial()
        material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: UIColor(color))
        material.roughness = PhysicallyBasedMaterial.Roughness(0.1)
        material.metallic = PhysicallyBasedMaterial.Metallic(0.8)
        
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        
        let anchorEntity = AnchorEntity(world: worldTransform)
        anchorEntity.addChild(modelEntity)
        
        return anchorEntity
    }
}

class ARAnchorContainer: Codable {
    
    let anchor: ARAnchor
    
    init(anchor: ARAnchor) {
        self.anchor = anchor
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(anchor.transform)
    }
    
    required convenience init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.init(anchor: try ARAnchor(transform: container.decode(simd_float4x4.self)))
    }
    
}

//extension Transform: Codable {
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        try container.encode(matrix)
//    }
//
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        try self.init(matrix: container.decode(float4x4.self))
//    }
//}
//
//extension float4x4: Codable {
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        try self.init(container.decode([SIMD4<Float>].self))
//    }
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        try container.encode([columns.0, columns.1, columns.2, columns.3])
//    }
//}





///// https://stackoverflow.com/questions/63661474/how-can-i-encode-an-array-of-simd-float4x4-elements-in-swift-convert-simd-float
extension simd_float4x4: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        try self.init(container.decode([SIMD4<Float>].self))
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode([columns.0, columns.1, columns.2, columns.3])
    }
}


//@propertyWrapper
//struct CodableViaNSCoding<T: NSObject & NSCoding>: Codable {
//    struct FailedToUnarchive: Error { }
//
//    let wrappedValue: T
//
//    init(wrappedValue: T) { self.wrappedValue = wrappedValue }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        let data = try container.decode(Data.self)
//
//        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
//        unarchiver.requiresSecureCoding = Self.wrappedValueSupportsSecureCoding
//
//        guard let wrappedValue = T(coder: unarchiver) else {
//            throw FailedToUnarchive()
//        }
//
//        unarchiver.finishDecoding()
//
//        self.init(wrappedValue: wrappedValue)
//    }
//
//    func encode(to encoder: Encoder) throws {
//        let archiver = NSKeyedArchiver(requiringSecureCoding: Self.wrappedValueSupportsSecureCoding)
//        wrappedValue.encode(with: archiver)
//        archiver.finishEncoding()
//        let data = archiver.encodedData
//
//        var container = encoder.singleValueContainer()
//        try container.encode(data)
//    }
//
//    private static var wrappedValueSupportsSecureCoding: Bool {
//        (T.self as? NSSecureCoding.Type)?.supportsSecureCoding ?? false
//    }
//}

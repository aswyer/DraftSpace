//
//  ModelObject.swift
//  DraftSpace
//
//  Created by Andrew Sawyer on 2/11/23.
//

import Foundation
import RealityKit
import ARKit

struct ModelObject: Codable {
    
    var modelType: ToolType
//    var anchorContainer: ARAnchorContainer
    var worldTransform: simd_float4x4
    
    var size: Float?
    var radius: Float?
    
    var anchorEntity: AnchorEntity? {
        
        var mesh: MeshResource
        
        switch modelType {
        case .cube:
            guard let size = size else { return nil }
            mesh = MeshResource.generateBox(size: size, cornerRadius: size/8)
            
        default:
            return nil
        }
        
        var material = PhysicallyBasedMaterial()
        material.baseColor = PhysicallyBasedMaterial.BaseColor(tint:.blue)
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

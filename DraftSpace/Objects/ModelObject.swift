//
//  ModelObject.swift
//  DraftSpace
//
//  Created by Andrew Sawyer on 2/11/23.
//

import Foundation
import RealityKit
import ARKit


//class ModelObject: NSObject, NSCoding {
//
//    var anchor: ARAnchor
//    var modelEntity: ModelEntity
//
//    enum CodingKeys: String, CodingKey {
//        case anchor
//        case model
//    }
//
//    func encode(with coder: NSCoder) {
//        coder.encode(anchor, forKey: CodingKeys.anchor.rawValue)
//        coder.encode(modelEntity, forKey: CodingKeys.model.rawValue)
//    }
//
//    init(anchor: ARAnchor, modelEntity: ModelEntity) {
//        self.anchor = anchor
//        self.modelEntity = modelEntity
//        super.init()
//    }
//
//    required init?(coder: NSCoder) {
//        guard
//            let anchor = coder.decodeObject(forKey: CodingKeys.anchor.rawValue) as? ARAnchor,
//            let model = coder.decodeObject(forKey: CodingKeys.model.rawValue) as? ModelEntity
//        else { return nil }
//
//        self.anchor = anchor
//        self.modelEntity = model
//    }
//}


//class ModelObject: NSObject, NSCoding {
//
//    var anchor: ARAnchor
//    var geometry: SCNGeometry
//
//    enum CodingKeys: String, CodingKey {
//        case anchor
//        case geometry
//    }
//
//    func encode(with coder: NSCoder) {
//        coder.encode(anchor, forKey: CodingKeys.anchor.rawValue)
//        coder.encode(geometry, forKey: CodingKeys.geometry.rawValue)
//    }
//
//    init(anchor: ARAnchor, geometry: SCNGeometry) {
//        self.anchor = anchor
//        self.geometry = geometry
//        super.init()
//    }
//
//    required init?(coder: NSCoder) {
//        guard
//            let anchor = coder.decodeObject(forKey: CodingKeys.anchor.rawValue) as? ARAnchor,
//            let geometry = coder.decodeObject(forKey: CodingKeys.geometry.rawValue) as? SCNGeometry
//        else { return nil }
//
//        self.anchor = anchor
//        self.geometry = geometry
//    }
//}
//

//class ModelObject: NSObject, NSSecureCoding {
//
//    static var supportsSecureCoding: Bool = true
//
//    var worldTransform: simd_float4x4
//    var geometry: SCNGeometry
//
//    enum CodingKeys: String, CodingKey {
//        case worldTransform
//        case geometry
//    }
//
//    func encode(with coder: NSCoder) {
//        coder.encode(worldTransform, forKey: CodingKeys.worldTransform.rawValue)
//        coder.encode(geometry, forKey: CodingKeys.geometry.rawValue)
//    }
//
//    init(worldTransform: simd_float4x4, geometry: SCNGeometry) {
//        self.worldTransform = worldTransform
//        self.geometry = geometry
//        super.init()
//    }
//
//    required init?(coder: NSCoder) {
//        guard
//            let worldTransform = coder.decodeObject(forKey: CodingKeys.worldTransform.rawValue) as? simd_float4x4,
//            let geometry = coder.decodeObject(forKey: CodingKeys.geometry.rawValue) as? SCNGeometry
//        else { return nil }
//
//        self.worldTransform = worldTransform
//        self.geometry = geometry
//    }
//}



//struct test: Codable {
//    @CodableViaNSCoding var pos: simd_float4x4
//    @CodableViaNSCoding var geo: SCNGeometry
//
////    enum CodingKeys: String, CodingKey {
////           case pos
////           case geo
////       }
////
////    func encode(to encoder: Encoder) throws {
////        var container = encoder.container(keyedBy: CodingKeys.self)
//////        try container.encode(pos, forKey: CodingKeys.pos) doable
//////        try container.encode(geo, forKey: CodingKeys.geo)
////    }
////
////    init(from decoder: Decoder) throws {
////        pos = simd_float4x4()
////    }
//}


struct ModelObject: Codable {
    var worldPosition: simd_float4x4
    var modelType: ToolType
    var size: CGFloat?
    var radius: CGFloat?
    
    var node: SCNNode? {
        
        let node = SCNNode()
        
        switch modelType {
        case .cube:
            guard let size = size else { return nil }
            let geo = SCNBox(width: size, height: size, length: size, chamferRadius: size / 6)
            node.geometry = geo
            
        default:
            return nil
        }
        
        //set world pos
        node.setWorldTransform(SCNMatrix4(worldPosition))
        
        //set material
        
        return node
    }
}

/// https://stackoverflow.com/questions/63661474/how-can-i-encode-an-array-of-simd-float4x4-elements-in-swift-convert-simd-float
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

//
//  ARDelegate.swift
//  DraftSpace
//
//  Created by Andrew Sawyer on 2/11/23.
//

import Foundation
import ARKit
import MultipeerConnectivity
import RealityKit
import SwiftUI

enum ToolType: String, CaseIterable, Codable {
    
    case sphere, cube, prism, pencil, highlighter, mouse
  //  static let allValues = [sphere,cube,prism,pencil,highlighter,mouse]

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
class MainModel: NSObject, ObservableObject, ARSCNViewDelegate, ARSessionDelegate {
    
    var sceneView: ARView?
    var multipeerSession: MultipeerSession!
    
    @Published var buttonSelected : ToolType = .mouse
    @Published var objectColor : Color = .white
    @Published var moveSelected: Bool = false
    @Published var viewType: ViewType = .AR
    @Published var canChangeTool: Bool = true
    @Published var baseColor: Color = .blue
    @Published var objectsPlaced: Int = 0
    @Published var collborators: Int = 0
    @Published var depth: Float = 1
    
    init(sceneView: ARView? = nil) {
        super.init()
        self.sceneView = sceneView
        self.multipeerSession = MultipeerSession(receivedDataHandler: receivedData)
    }
    
    //MARK: - Send Data
    var hasSentWorld = false
    func sendWorld() {
        guard hasSentWorld == false else { return }
        guard let sceneView = sceneView else { return }
        
        sceneView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true) else {
                fatalError("can't encode map")
            }
            
            print("sent world")
            self.hasSentWorld = true
            self.multipeerSession.sendToAllPeers(data)
        }
    }
    
    func sendItem(_ item: ModelObject) {
        //        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: item, requiringSecureCoding: true) else {
        //            return
        //        }
        //        do {
        //            let data = try NSKeyedArchiver.archivedData(withRootObject: item, requiringSecureCoding: true)
        //            multipeerSession.sendToAllPeers(data)
        //        } catch {
        //            print(error)
        //        }
        
        do {
            let json = try JSONEncoder().encode(item)
            let data = Data(json)
            multipeerSession.sendToAllPeers(data)
        } catch {
            print("error")
        }
    }
    
    //MARK: - Receive Data
    func receivedData(_ data: Data, from peer: MCPeerID) {
        guard let sceneView = sceneView else { return }
        
        if let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            configuration.initialWorldMap = worldMap
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            
            print("got world data")
            
        } else {
            guard let modelObject = try? JSONDecoder().decode(ModelObject.self, from: data) else { return }
            addModelObject(modelObject)
        }
    }
    
    //    var tempNextGeometry: SCNGeometry?
    //    var tempNextAnchor: ARAnchor?
    
//    private var mainAnchor: AnchorEntity?
    
    func addModelObject(_ modelObject: ModelObject) {
        guard let anchorEntity = modelObject.anchorEntity else { return }
        sceneView?.scene.addAnchor(anchorEntity)
        
    }
    
    //    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    //        guard
    //            let tempNextGeometry = tempNextGeometry,
    //            let tempNextAnchor = tempNextAnchor,
    //            tempNextAnchor == anchor
    //        else { return }
    //
    //        let node = SCNNode(geometry: tempNextGeometry)
    //        node.addChildNode(node)
    //
    //        self.tempNextAnchor = nil
    //        self.tempNextGeometry = nil
    //    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        switch frame.worldMappingStatus {
        case .extending, .mapped:
            if !multipeerSession.connectedPeers.isEmpty {
                sendWorld()
            }
        default:
            break
        }
    }
}



//
//  ARDelegate.swift
//  DraftSpace
//
//  Created by Andrew Sawyer on 2/11/23.
//

import Foundation
import ARKit
import MultipeerConnectivity

@MainActor
class ARDelegate: NSObject, ARSCNViewDelegate, ARSessionDelegate, ObservableObject {
    
    var sceneView: ARSCNView?
    var multipeerSession: MultipeerSession!
    
    init(sceneView: ARSCNView? = nil) {
        super.init()
        self.sceneView = sceneView
        self.multipeerSession = MultipeerSession(receivedDataHandler: receivedData)
    }
    
    //MARK: - Send Data
    func sendWorld() {
        guard let sceneView = sceneView else { return }
        
        sceneView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
            else {
                fatalError("can't encode map")
            }
            
            print("sent world")
            self.multipeerSession.sendToAllPeers(data)
        }
    }
    
    func sendItem() {
        print("send item")
    }
    
    //MARK: - Receive Data
    func receivedData(_ data: Data, from peer: MCPeerID) {
        guard let sceneView = sceneView else { return }
        
        do {
            if let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) {
                
                let configuration = ARWorldTrackingConfiguration()
                configuration.planeDetection = .horizontal
                configuration.initialWorldMap = worldMap
                sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
                
                print("got world data")
                
            } else if let anchor = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARAnchor.self, from: data) {
                
                // add content
                print("got anchor data")
                
            }
            else {
                print("unknown data recieved from \(peer)")
            }
        } catch {
            print("can't decode data recieved from \(peer)")
        }
    }
    
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

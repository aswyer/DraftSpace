//
//  DraftSpaceApp.swift
//  DraftSpace
//
//  Created by Andrew Sawyer on 2/11/23.
//

import SwiftUI

@main
struct DraftSpaceApp: App {
    
    @StateObject var arDelegate = ARDelegate()
    
    var body: some Scene {
        WindowGroup {
            ContentView(arDelegate: arDelegate)
        }
    }
}

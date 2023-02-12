//
//  DraftSpaceApp.swift
//  DraftSpace
//
//  Created by Andrew Sawyer on 2/11/23.
//

import SwiftUI

@main
struct DraftSpaceApp: App {
    
    @StateObject var model = MainModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
    }
}

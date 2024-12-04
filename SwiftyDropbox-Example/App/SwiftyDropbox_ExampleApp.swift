//
//  SwiftyDropbox_ExampleApp.swift
//  SwiftyDropbox-Example
//
//  Created by Monica Auriemma on 10/24/24.
//

import SwiftUI
import SwiftyDropbox

@main
struct SwiftyDropbox_ExampleApp: App {
    init() {
        // Instantiate DBX client
        DropboxClientsManager.setupWithAppKey("APP_KEY")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

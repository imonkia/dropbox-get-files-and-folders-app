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
        DropboxClientsManager.setupWithAppKey(Environment.appKey)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

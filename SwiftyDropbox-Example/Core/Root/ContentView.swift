//
//  ContentView.swift
//  SwiftyDropbox-Example
//
//  Created by Monica Auriemma on 10/24/24.
//

import SwiftUI
import SwiftyDropbox

struct ContentView: View {
    @State var isAuthenticated: Bool = false
    
    var body: some View {
        if(isAuthenticated) {
            FilesFoldersView()
        } else {
            VStack {
                Button("Dropbox Login") {
                    dbxLogin()
                }
                .frame(minWidth: 150)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .font(.system(size: 16))
                .fontWeight(.semibold)
                .cornerRadius(10)
            }
            .padding()
            .onOpenURL {
                url in
                print("url: \(url)")
                let oauthCompletion: DropboxOAuthCompletion = {
                    if let authResult = $0 {
                        switch authResult {
                        case .success:
                            isAuthenticated = true
                        case .cancel:
                            print("Client cancelled")
                        case .error(_, let description):
                            print("Error authorizing: \(String(describing: description))")
                        }
                    }
                }
                DropboxClientsManager.handleRedirectURL(url, includeBackgroundClient: false, completion: oauthCompletion)
            }
        }
    }
    
    func dbxLogin() {
        let scopeRequest = ScopeRequest(scopeType: .user, scopes: [], includeGrantedScopes: false)
        DropboxClientsManager.authorizeFromControllerV2(
            UIApplication.shared,
            controller: nil,
            loadingStatusDelegate: nil,
            openURL: {(url: URL) -> Void in UIApplication.shared.open(url, options: [:], completionHandler: nil)},
            scopeRequest: scopeRequest
        )
    }
}

#Preview {
    ContentView()
}

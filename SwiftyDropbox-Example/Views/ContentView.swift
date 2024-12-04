//
//  ContentView.swift
//  SwiftyDropbox-Example
//
//  Created by Monica Auriemma on 10/24/24.
//

import SwiftUI
import SwiftyDropbox
import AlertToast

struct ContentView: View {
    // State variables
    @State var isAuthenticated: Bool = false
    @State var showAlert: Bool = false
    @State var authErrorMessage: String = ""
    
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
            .toast(
                isPresenting: $showAlert,
                duration: 2,
                tapToDismiss: true,
                alert: {
                    AlertToast(
                        displayMode: .hud,
                        type: .error(Color.red),
                        title: "Authorization Error",
                        subTitle: authErrorMessage
                    )
                }
            )
            .onOpenURL {
                url in
                let oauthCompletion: DropboxOAuthCompletion = {
                    if let authResult = $0 {
                        switch authResult {
                        case .success:
                            isAuthenticated = true
                        case .cancel:
                            showAlert = true
                            authErrorMessage = "Client cancelled."
                        case .error(_, let description):
                            showAlert = true
                            authErrorMessage = "\(String(describing: description))."
                        }
                    }
                }
                DropboxClientsManager.handleRedirectURL(url, includeBackgroundClient: false, completion: oauthCompletion)
            }
        }
    }
    // Function to handle authorization flow
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

//
//  OAuthView.swift
//  SwiftyDropbox-Example
//
//  Created by reta on 10/24/24.
//

import SwiftUI
import SwiftyDropbox

struct OAuthView: UIViewControllerRepresentable {
    typealias UIViewControllerType = AuthViewController

    func makeUIViewController(context: Context) -> AuthViewController {
        let vc = AuthViewController()
        return vc
    }
    
    func updateUIViewController(_ uiViewController: AuthViewController, context: Context) {
        
    }
    
    
}

#Preview {
    OAuthView()
}

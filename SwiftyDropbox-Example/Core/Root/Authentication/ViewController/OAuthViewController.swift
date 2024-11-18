//
//  OAuthViewModel.swift
//  SwiftyDropbox-Example
//
//  Created by reta on 10/24/24.
//

import Foundation
import SwiftyDropbox
import SwiftUI

class AuthViewController: UIViewController {
    
    private let button: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = .systemBlue
        button.setTitle("Authorize", for: .normal)
        button.layer.cornerRadius = 10
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        self.button.addTarget(self, action: #selector(onAuthButtonClick), for: .touchUpInside)
    }
    
    private func setupUI() {
        self.view.addSubview(button)
        self.button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // Handle OAuth flow
    @objc func onAuthButtonClick() {
        print("clicked")
        let scopeRequest = ScopeRequest(scopeType: .user, scopes: [], includeGrantedScopes: false)
        DropboxClientsManager.authorizeFromControllerV2(
            UIApplication.shared,
            controller: self,
            loadingStatusDelegate: nil,
            openURL: {(url: URL) -> Void in UIApplication.shared.open(url, options: [:], completionHandler: nil)},
            scopeRequest: scopeRequest
        )
    }
}


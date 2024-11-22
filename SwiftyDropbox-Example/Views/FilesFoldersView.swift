//
//  FilesFoldersView.swift
//  SwiftyDropbox-Example
//
//  Created by Monica Auriemma on 10/24/24.
//

import SwiftUI
import SwiftyDropbox

struct FilesFoldersView: View {
    // State variables
    @State private var isDisabled: Bool = false
    
    // State object instance of FilesFolders ViewModel class
    @StateObject private var filesFoldersViewModel = FilesFoldersViewModel()
    
    
    var body: some View {
        VStack {
            List(Array(Set(filesFoldersViewModel.metadataItems)), id: \.id) {
                metadataItem in
                VStack(alignment: .leading) {
                    Text(metadataItem.pathLower)
                        .font(.system(size: 14))
                }
            }
            .padding(.top)
            Button(action: {
                Task {
                    do {
                        // Function to handle the API request using the SDK
                        try filesFoldersViewModel.getFoldersAndFiles()
                        isDisabled = true
                    } catch {
                        print("An error occurred")
                        isDisabled = true
                    }
                }
            }) {
                Text("List Files and Folders")
                    .frame(minWidth: 100)
                    .padding()
                    .background(isDisabled ? Color.gray : Color.blue)
                    .foregroundColor(.white)
            }
            .cornerRadius(10)
            .disabled(isDisabled)
        }
    }
}

#Preview {
    FilesFoldersView()
}

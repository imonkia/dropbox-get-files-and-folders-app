//
//  FilesFoldersView.swift
//  SwiftyDropbox-Example
//
//  Created by Monica Auriemma on 10/24/24.
//

import SwiftUI
import SwiftyDropbox

struct FilesFoldersView: View {
    // State object instance of FilesFolders ViewModel class
    @StateObject private var filesFoldersViewModel = FilesFoldersViewModel()
    
    var body: some View {
        VStack {
            // Create a list of returned files and folders' paths
            List(filesFoldersViewModel.foldersMetadata) {
                folderMetadata in
                VStack(alignment: .leading) {
                    Text(folderMetadata.pathLower)
                        .font(.system(size: 14))
                }
            }
            Button(action: {
                Task {
                    do {
                        // Function to handle the API request using the SDK
                        try filesFoldersViewModel.getFoldersAndFiles()
                    } catch {
                        print("An error occurred")
                    }
                }
            }) {
                Text("Fetch")
                    .frame(minWidth: 100)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
            }
            .cornerRadius(10)
        }
    }
}

#Preview {
    FilesFoldersView()
}

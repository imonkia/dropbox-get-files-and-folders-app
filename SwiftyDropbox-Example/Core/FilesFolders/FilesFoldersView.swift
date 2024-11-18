//
//  FilesFoldersView.swift
//  SwiftyDropbox-Example
//
//  Created by Monica Auriemma on 10/24/24.
//

import SwiftUI
import SwiftyDropbox

struct FilesFoldersView: View {
    @StateObject private var viewModel = FilesFoldersViewModel()
    
    var body: some View {
        VStack {
            List(viewModel.foldersMetadata) {
                folderMetadata in
                VStack(alignment: .leading) {
                    Text(folderMetadata.pathLower)
                        .font(.system(size: 14))
                }
            }
            Button(action: {
                Task {
                    do {
                        try viewModel.getFoldersAndFiles()
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

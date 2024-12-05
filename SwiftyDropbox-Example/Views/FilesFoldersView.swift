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
    @State private var isButtonDisabled: Bool = false
    
    // State object, instance of FilesFoldersViewModel class
    @StateObject private var filesFoldersViewModel = FilesFoldersViewModel()
    
    var body: some View {
        VStack {
            List(Array(Set(filesFoldersViewModel.metadataItems)), id: \.id) {
                metadataItem in
                VStack(alignment: .leading) {
                    Text(metadataItem.pathDisplay)
                        .strikethrough(metadataItem.isDeleted ?? false)
                        .foregroundStyle(metadataItem.isDeleted! ? Color.gray : Color.black)
                        .font(.system(size: 14))
                }
            }
            .padding(.top)
            Button(action: {
                isButtonDisabled = true
                Task {
                    do {
                        // Function to handle the API request using the SDK
                        try await filesFoldersViewModel.getFoldersAndFiles()
                        
                        // Catching some of the most common errors, but more are available
                    } catch FilesFoldersViewModel.PathErrors.malformedPath(let errorMessage) {
                        print(errorMessage)
                    } catch FilesFoldersViewModel.PathErrors.notFound(let errorMessage) {
                        print(errorMessage)
                    } catch FilesFoldersViewModel.PathErrors.notFile(let errorMessage) {
                        print(errorMessage)
                    } catch FilesFoldersViewModel.PathErrors.notFolder(let errorMessage) {
                        print(errorMessage)
                    } catch FilesFoldersViewModel.PathErrors.restrictedContent(let errorMessage) {
                        print(errorMessage)
                    } catch FilesFoldersViewModel.PathErrors.unsupportedContentType(let errorMessage) {
                        print(errorMessage)
                    } catch FilesFoldersViewModel.PathErrors.locked(let errorMessage) {
                        print(errorMessage)
                    } catch FilesFoldersViewModel.OtherErrors.other(let errorMessage) {
                        print(errorMessage)
                    }
                }
            }) {
                Text("List Files and Folders")
                    .frame(minWidth: 100)
                    .padding()
                    .background(isButtonDisabled ? Color.gray : Color.blue)
                    .foregroundColor(.white)
            }
            .cornerRadius(10)
            .disabled(isButtonDisabled)
        }
    }
}

#Preview {
    FilesFoldersView()
}

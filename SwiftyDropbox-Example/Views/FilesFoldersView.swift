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
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var alertTitle: String = ""
    
    // State object, instance of FilesFoldersViewModel class
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
                isButtonDisabled = true
                Task {
                    do {
                        // Function to handle the API request using the SDK
                        try await filesFoldersViewModel.getFoldersAndFiles()
                        
                        // Catching some of the most common errors, but more are available
                    } catch FilesFoldersViewModel.PathErrors.malformedPath(let errorMessage) {
                        populateAlertContent(title: "Malformed Path", message: "The given path does not satisfy the required path format.")
                        showAlert = true
                        print(errorMessage)
                    } catch FilesFoldersViewModel.PathErrors.notFound(let errorMessage) {
                        populateAlertContent(title: "Not Found", message: "There is nothing at the given path.")
                        showAlert = true
                        print(errorMessage)
                    } catch FilesFoldersViewModel.PathErrors.notFile(let errorMessage) {
                        populateAlertContent(title: "Not a File", message: "The file cannot be transferred because the content is restricted. For example, we might restrict a file due to legal requirements.")
                        showAlert = true
                        print(errorMessage)
                    } catch FilesFoldersViewModel.PathErrors.notFolder(let errorMessage) {
                        populateAlertContent(title: "Not a Folder", message: "We were expecting a folder, but the given path refers to something that isn't a folder.")
                        showAlert = true
                        print(errorMessage)
                    } catch FilesFoldersViewModel.PathErrors.restrictedContent(let errorMessage) {
                        populateAlertContent(title: "Restricted Content", message: "The file content is restricted.")
                        showAlert = true
                        print(errorMessage)
                    } catch FilesFoldersViewModel.PathErrors.unsupportedContentType(let errorMessage) {
                        populateAlertContent(title: "Unsupported Content Type", message: "This operation is not supported for this content type.")
                        showAlert = true
                        print(errorMessage)
                    } catch FilesFoldersViewModel.PathErrors.locked(let errorMessage) {
                        populateAlertContent(title: "Locked", message: "The given path is locked.")
                        showAlert = true
                        print(errorMessage)
                    } catch FilesFoldersViewModel.OtherErrors.other(let errorMessage) {
                        populateAlertContent(title: "Error", message: "Unknonw error occurred")
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
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // Function to populate alert content
    func populateAlertContent(title: String, message: String) {
        alertTitle = title
        alertMessage = message
    }
}

#Preview {
    FilesFoldersView()
}

//
//  FilesFoldersViewModel.swift
//  SwiftyDropbox-Example
//
//  Created by Monica Auriemma on 11/15/24.
//

import SwiftUI
import SwiftyDropbox

// Custom struct to store the UID and "pathDisplay" properties of each entry
struct MetadataItem: Identifiable, Hashable {
    let id: String
    let pathDisplay: String
    var isDeleted: Bool? = false
}


@MainActor
class FilesFoldersViewModel: ObservableObject {
    // Obersvable property
    @Published var metadataItems: [MetadataItem] = []
    
    // DBX client instance
    private var dbxClient = DropboxClientsManager.authorizedClient
    
    private var hasMore: Bool = false
    private var cursor: String = ""
    private var metadataItemsTemp: [MetadataItem] = []

    // Function to loop through received entries from the API
    private func loopThroughEntries(response: Files.ListFolderResult) -> [MetadataItem] {
        hasMore = response.hasMore ? true : false
        cursor = !response.cursor.isEmpty ? response.cursor : ""
        metadataItemsTemp = response.entries.map { entry -> MetadataItem in
            if let folderMetadata = entry as? Files.FolderMetadata {
                return MetadataItem(id: folderMetadata.id, pathDisplay: folderMetadata.pathDisplay ?? "")
            } else if let fileMetadata = entry as? Files.FileMetadata {
                return MetadataItem(id: fileMetadata.id, pathDisplay: fileMetadata.pathDisplay ?? "")
            } else if let deletedMetadata = entry as? Files.DeletedMetadata {
                // if "includeDeleted" is set to true
                return MetadataItem(id: "unknown", pathDisplay: deletedMetadata.pathDisplay ?? "", isDeleted: true)
            } else {
                return MetadataItem(id: "unknown", pathDisplay: entry.pathDisplay ?? "")
            }
        }
        
        return metadataItemsTemp
    }
    
    // Function to call /files/list_folder and /files/list_folder/continue
    func getFoldersAndFiles() async throws {
        do {
            // Get the current user's account info
            let accountInfo = try await dbxClient?.users.getCurrentAccount().response()
            // Retrieving the user's rootNameSpaceId
            let rootNameSpaceId = accountInfo!.rootInfo.rootNamespaceId
            if !rootNameSpaceId.isEmpty {
                // Update the DBX client instance to use .withPathRoot with the user's rootNameSpaceId
                self.dbxClient = DropboxClientsManager.authorizedClient?.withPathRoot(.root(rootNameSpaceId))
            }
            let response = try await dbxClient?.files.listFolder(path: "", recursive: true, includeDeleted: false).response()
            self.metadataItems = self.loopThroughEntries(response: response!)
            while (self.hasMore) {
                let response = try await dbxClient?.files.listFolderContinue(cursor: self.cursor).response()
                
                self.metadataItems.append(contentsOf: self.loopThroughEntries(response: response!))
            }
        } catch {
            switch error as? CallError<Any> {
            case .routeError(let boxed, _, _, let requestId):
                print("RouteError:[\(String(describing: requestId))]:")
                
                switch boxed.unboxed as! Files.ListFolderError {
                case .path(let lookupError):
                    switch lookupError {
                    case .malformedPath:
                        throw PathErrors.malformedPath(lookupError.description)
                    case .notFound:
                        throw PathErrors.notFound(lookupError.description)
                    case .notFile:
                        throw PathErrors.notFile(lookupError.description)
                    case .notFolder:
                        throw PathErrors.notFolder(lookupError.description)
                    case .other:
                        throw OtherErrors.other(lookupError.description)
                    case .restrictedContent:
                        throw PathErrors.restrictedContent(lookupError.description)
                    case .unsupportedContentType:
                        throw PathErrors.unsupportedContentType(lookupError.description)
                    case .locked:
                        throw PathErrors.locked(lookupError.description)
                    }
                case .templateError:
                    throw FolderErrors.templateError
                case .other:
                    throw OtherErrors.other("Unknown route error.")
                }
            case .internalServerError(let code, let message, let requestId):
                throw ServerErrors.internalServerError("Internal Server Error: \(String(describing: code)): \(String(describing: message))\nDropbox Request ID: \(String(describing: requestId))")
            case .badInputError:
                throw ServerErrors.badInputError
            case .rateLimitError:
                throw ServerErrors.rateLimitError
            case .httpError(let code, let message, let requestId):
                throw ServerErrors.httpError("HTTP Error \(String(describing: code)): \(String(describing: message))\nDropbox Request ID: \(String(describing: requestId))")
            case .authError:
                throw ServerErrors.authError
            case .accessError:
                throw ServerErrors.accessError
            case .serializationError:
                throw ServerErrors.serializationError
            case .reconnectionError:
                throw ServerErrors.reconnectionError
            case .clientError:
                throw ServerErrors.clientError
            case .none:
                throw OtherErrors.other("\(String(describing: error))")
            
            }
        }
    }
    
    // Throwable errors
    enum OtherErrors: Error {
        case other(String)
    }
    
    enum PathErrors: Error {
        case malformedPath(String)
        case notFound(String)
        case notFile(String)
        case notFolder(String)
        case restrictedContent(String)
        case unsupportedContentType(String)
        case locked(String)
    }
    
    enum FolderErrors: Error {
        case templateError
    }
    
    enum ServerErrors: Error {
        case internalServerError(String)
        case badInputError
        case rateLimitError
        case httpError(String)
        case authError
        case accessError
        case serializationError
        case reconnectionError
        case clientError
    }
}

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

// DBX client instance
let client = DropboxClientsManager.authorizedClient


@MainActor
class FilesFoldersViewModel: ObservableObject {
    // Obersvable property
    @Published var metadataItems: [MetadataItem] = []
    
    private var hasMore: Bool = false
    private var cursor: String = ""
    private var counter: Int = 0
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
            let response = try await client?.files.listFolder(path: "", recursive: true, includeDeleted: false).response()
            self.metadataItems = self.loopThroughEntries(response: response!)
            // For testing: the while loop is set to stop when counter reaches < 5
            // This condition (counter < 5) can be removed to retrieve ALL files and folders
            while (self.hasMore && self.counter < 5) {
                self.counter += 1
                let response = try await client?.files.listFolderContinue(cursor: self.cursor).response()
                
                self.metadataItems.append(contentsOf: self.loopThroughEntries(response: response!))
            }
        } catch {
            switch error as? CallError<Files.ListFolderError> {
            case .routeError(let boxed, _, _, let requestId):
                print("RouteError:[\(String(describing: requestId))]:")
                
                switch boxed.unboxed as Files.ListFolderError {
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
                    throw OtherErrors.other("Unknown error")
                }
            case .internalServerError:
                throw ServerErrors.internalServerError
            case .badInputError:
                throw ServerErrors.badInputError
            case .rateLimitError:
                throw ServerErrors.rateLimitError
            case .httpError:
                throw ServerErrors.httpError
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
                throw OtherErrors.other("Unknown error")
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
        case internalServerError
        case badInputError
        case rateLimitError
        case httpError
        case authError
        case accessError
        case serializationError
        case reconnectionError
        case clientError
    }
}

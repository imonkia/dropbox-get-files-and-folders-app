//
//  FilesFoldersViewModel.swift
//  SwiftyDropbox-Example
//
//  Created by Monica Auriemma on 11/15/24.
//

import SwiftUI
import SwiftyDropbox

struct FolderMetadataItem: Codable, Identifiable {
    let id: String
    let pathLower: String
}

let client = DropboxClientsManager.authorizedClient

@MainActor
class FilesFoldersViewModel: ObservableObject {
    @Published var foldersMetadata: [FolderMetadataItem] = []
    
    private var hasMore: Bool = false
    private var cursor: String = ""
    private var counter: Int = 0

    private func loopThroughEntries(response: Files.ListFolderResult) -> [FolderMetadataItem] {
        hasMore = response.hasMore ? true : false
        cursor = !response.cursor.isEmpty ? response.cursor : ""
        foldersMetadata = response.entries.map { entry -> FolderMetadataItem in
            if let folderMetadata = entry as? Files.FolderMetadata {
                return FolderMetadataItem(id: folderMetadata.id, pathLower: folderMetadata.pathLower ?? "")
            } else if let fileMetadata = entry as? Files.FileMetadata {
                return FolderMetadataItem(id: fileMetadata.id, pathLower: fileMetadata.pathLower ?? "")
            } else {
                return FolderMetadataItem(id: "unknown", pathLower: entry.pathLower ?? "")
            }
        }
        return foldersMetadata
    }

    func getFoldersAndFiles() throws {
        client?.files.listFolder(path: "", recursive: true, includeDeleted: false).response {
            response, error in
            if let response = response {
                _ = self.loopThroughEntries(response: response)
                while (self.hasMore && self.counter < 5) {
                    self.counter += 1
                    client?.files.listFolderContinue(cursor: self.cursor).response {
                        response, error in
                        if let response = response {
                            _ = self.loopThroughEntries(response: response)
                        }
                    }
                }
            } else if let error = error {
                switch error as CallError {
                case .routeError(let boxed, _, _, let requestId):
                    print("RouteError:[\(String(describing: requestId))]:")
                    
                    switch boxed.unboxed as Files.ListFolderError {
                    case .path(let lookupError):
                        switch lookupError {
                        case .malformedPath:
                            print("Malformed path")
                        case .notFound:
                            print("There is nothing at the given path")
                        case .notFile:
                            print("Not a file")
                        case .notFolder:
                            print("Not a folder")
                        case .other:
                            print("Unknown")
                        case .restrictedContent:
                            print("Restricted content")
                        case .unsupportedContentType:
                            print("Unsupported content type")
                        case .locked:
                            print("Locked")
                        }
                    case .templateError:
                        print("Template error")
                    case .other:
                        print("Unknown")
                    }
                case .internalServerError:
                    print("Internal server error")
                case .badInputError:
                    print("Bad input")
                case .rateLimitError:
                    print("Rate limit")
                case .httpError:
                    print("HTTP error")
                case .authError:
                    print("Authorization error")
                case .accessError:
                    print("Access error")
                case .serializationError:
                    print("Serialization error")
                case .reconnectionError:
                    print("Reconnection error")
                case .clientError:
                    print("Client error")
                }
            }
        }
    }
}

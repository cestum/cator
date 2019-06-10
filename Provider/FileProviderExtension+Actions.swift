//
//  extension for FileProviderExtension
//  Cator
//
//  Created by Cestum on 6/10/19.
//

import FileProvider

extension FileProviderExtension {
    #warning("NOT IMPLMENENTED YET")
    override func importDocument(at fileURL: URL, toParentItemIdentifier parentItemIdentifier: NSFileProviderItemIdentifier, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        if fileURL.startAccessingSecurityScopedResource() == false {
            completionHandler(nil, NSFileProviderError(.noSuchItem))
            return
        }
        
        completionHandler(nil, CatorError.notImplementedYetError)
        
    }
    
    #warning("NOT IMPLMENENTED YET")
    override func createDirectory(withName directoryName: String, inParentItemIdentifier parentItemIdentifier: NSFileProviderItemIdentifier, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        
        completionHandler(nil, CatorError.notImplementedYetError)
    }
    
    override func trashItem(withIdentifier itemIdentifier: NSFileProviderItemIdentifier, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
        completionHandler(nil, CatorError.notImplementedYetError)
    }
    
    // MARK: - Helpers
    
    private func handleCompletedRequest(with error: Error?, for identifier: NSFileProviderItemIdentifier) {
        if let e = error {
            print("Error uploading file: \(e.localizedDescription)")
        } else {
            NSFileProviderManager.default.signalEnumerator(for: identifier) { error in
                guard let e = error else {
                    return
                }
                print("Error signaling file enumerator: \(e.localizedDescription)")
            }
        }
    }
}

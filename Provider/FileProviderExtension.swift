//
//  FileProviderExtension.swift
//  Cator
//
//  Created by Cestum on 6/3/19.
//
import FileProvider

class FileProviderExtension: NSFileProviderExtension {
    private lazy var fileManager = FileManager()
    
    override func item(for identifier: NSFileProviderItemIdentifier) throws -> NSFileProviderItem {
        if identifier == .rootContainer {
            return FileProviderItem.rootItem
        }
        
        guard let item = FileProviderItem(identifier: identifier) else {
            throw NSFileProviderError(.noSuchItem)
        }
        
        return item
    }
    
    override func urlForItem(withPersistentIdentifier identifier: NSFileProviderItemIdentifier) -> URL? {
        do {
            guard let item = try item(for: identifier) as? FileProviderItem else {
                return nil
            }
            
            //      let tmp = FileManager.default.createTemporaryDirectory()
            
            let manager = NSFileProviderManager.default
            
            // in this implementation, all paths are structured as <base storage directory>/<item identifier>/<item file name>
            let perItemDirectory = manager.documentStorageURL.appendingPathComponent(identifier.rawValue, isDirectory: true)
            let allDir = perItemDirectory.appendingPathComponent(item.fileInfo.name, isDirectory:item.isDirectory)
            return allDir
        } catch {
            return nil
        }
    }
    
    override func persistentIdentifierForItem(at url: URL) -> NSFileProviderItemIdentifier? {
        let pathComponents = url.pathComponents
        
        // exploit the fact that the path structure has been defined as
        // <base storage directory>/<item identifier>/<item file name> above
        assert(pathComponents.count > 2)
        
        return NSFileProviderItemIdentifier(pathComponents[pathComponents.count - 2])
    }
    
    override func providePlaceholder(at url: URL, completionHandler: @escaping (Error?) -> Void) {
        guard let identifier = persistentIdentifierForItem(at: url), identifier != .rootContainer else {
            completionHandler(NSFileProviderError(.noSuchItem))
            return
        }
        
        do {
            let urlParent = url.deletingLastPathComponent()
            if !fileManager.fileExists(atPath: urlParent.path) { // this was tricky, https://forums.developer.apple.com/thread/89113
                try fileManager.createDirectory(at: urlParent, withIntermediateDirectories: true, attributes: nil)
            }
            
            guard  let fileProviderItem = FileProviderItem(identifier: identifier) else {
                completionHandler(nil)
                return
            }
            let placeholderURL = NSFileProviderManager.placeholderURL(for: url)
            
            try NSFileProviderManager.writePlaceholder(at: placeholderURL, withMetadata: fileProviderItem)
            completionHandler(nil)
        } catch let error {
            completionHandler(error)
        }
    }
    
    override func startProvidingItem(at url: URL, completionHandler: @escaping ((_ error: Error?) -> Void)) {
        guard !fileManager.fileExists(atPath: url.path) else {
            completionHandler(nil)
            return
        }
        
        guard let identifier = persistentIdentifierForItem(at: url) else {
            completionHandler(NSFileProviderError(.noSuchItem))
            return
        }
        
        guard  let fileProviderItem = FileProviderItem(identifier: identifier) else {
            completionHandler(NSFileProviderError(.noSuchItem))
            return
        }
        
        CatorWrapper.shared.downloadFile(at: fileProviderItem.fileInfo, to: url) { error in
            completionHandler(error)
        }
    }
    
    override func stopProvidingItem(at url: URL) {
        try? fileManager.removeItem(at: url)
        
        providePlaceholder(at: url) { error in
            guard let e = error else {
                return
            }
            
            print("Error providing placeholder: \(e.localizedDescription)")
        }
    }
    
    // MARK: - Enumeration
    
    override func enumerator(for containerItemIdentifier: NSFileProviderItemIdentifier) throws -> NSFileProviderEnumerator {
        guard containerItemIdentifier != .rootContainer else {
            return FileProviderEnumerator(identifier: FileProviderItem.rootItem)
        }
        
        do {
            if let providerItem = try item(for: containerItemIdentifier) as? FileProviderItem, providerItem.isDirectory {
                return FileProviderEnumerator(identifier: providerItem)
            }
        } catch {
            print("Item parse error: \(error.localizedDescription).")
        }
        
        throw NSFileProviderError(.noSuchItem)
    }
    
    #warning("Not implemented")
    override func fetchThumbnails(for itemIdentifiers: [NSFileProviderItemIdentifier], requestedSize size: CGSize, perThumbnailCompletionHandler: @escaping (NSFileProviderItemIdentifier, Data?, Error?) -> Void, completionHandler: @escaping (Error?) -> Void) -> Progress {
        let urlSession = URLSession(configuration: .default)
        let progress = Progress(totalUnitCount: Int64(itemIdentifiers.count))
        
        DispatchQueue.main.async {
            completionHandler(nil)
        }
        return progress

    }
}

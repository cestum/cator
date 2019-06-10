//
//  extension for FileProviderExtension
//  Cator
//
//  Created by Cestum on 6/10/19.
//
import FileProvider


class FileProviderEnumerator: NSObject, NSFileProviderEnumerator {
    private let fileItem: FileProviderItem
    
    init(identifier: FileProviderItem) {
        self.fileItem = identifier
        
        super.init()
    }
    
    func invalidate() {
        // nothing to clean up.
    }
    
    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
        let path: String?
        
        if fileItem == FileProviderItem.rootItem {
            path = nil
        } else {
            
            if let parent = fileItem.fileInfo.parent  {
                var f = parent.components(separatedBy: "+")
                f.append(fileItem.fileInfo.name)
                path = NSString.path(withComponents: f)
            } else {
                path = fileItem.fileInfo.name
            }
        }
        
        CatorWrapper.shared.getMedia(at: path) { items, error in
            if let error = error {
                print("Error retrieving files \(error)")
                observer.finishEnumeratingWithError(error)
                return
            }
            
            guard !items.isEmpty else {
                observer.finishEnumerating(upTo: nil)
                return
            }
            
            let providerItems = items.map({ FileProviderItem(info: $0)})
            observer.didEnumerate(providerItems)
            
            observer.finishEnumerating(upTo: nil)
        }
    }
}

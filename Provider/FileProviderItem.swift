//
//  FileProviderItem
//  Cator
//
//  Created by Cestum on 6/10/19.
//
import FileProvider
import MobileCoreServices

class FileProviderItem: NSObject, NSFileProviderItem {
    
    var fileInfo: FileInfo
    
    static var rootFileInfo:FileInfo {
        return FileInfo(name: "", parent: nil, size: 0, type:CiphertextFileType.DIRECTORY)
    }
    
    static var rootItem: FileProviderItem {
        return FileProviderItem(info: rootFileInfo)
    }
    
    var isDirectory: Bool {
        return fileInfo.type == CiphertextFileType.DIRECTORY
    }
    
    init(info: FileInfo) {
        self.fileInfo = info
        if let keyIdentifier = FileProviderItem.getIdentifier(fileInfo: info) {
            DirectoryIDCache.shared.setA(key: keyIdentifier as NSString, val: info)
        }
        
    }
    
    convenience init?(identifier: NSFileProviderItemIdentifier) {
        let decodedIdentifier = identifier.rawValue.base64Decoded
        var fileInfo = DirectoryIDCache.shared.getA(key: decodedIdentifier as NSString)
        
        if fileInfo == nil {
            fileInfo = DirectoryIDCache.shared.getA(key: identifier.rawValue as NSString)
        }
        
        guard let fileInfo1 = fileInfo else {
            return nil
        }
        //
        //        var comps = decodedIdentifier.components(separatedBy: "+")
        //
        //        guard let name = comps.popLast() else {
        //            return nil
        //        }
        //
        //        let parent = comps.isEmpty ? nil : comps.joined(separator: "+")
        //        self.init(info: FileInfo(name: name, parent: parent, size: 0, type:CiphertextFileType.DIRECTORY))
        
        self.init(info: fileInfo1)
    }
    
    static func getIdentifier(fileInfo: FileInfo) -> String? {
        guard !fileInfo.name.isEmpty else {
            return nil
        }
        var comps = [String]()
        if let encodedParent = fileInfo.parent {
            comps.append(encodedParent)
        }
        comps.append(fileInfo.name)
        let key = comps.joined(separator: "+")
        return key
    }
}

//extension to above FileProviderItem
extension FileProviderItem {
    var itemIdentifier: NSFileProviderItemIdentifier {
        guard let keyIdentifer = FileProviderItem.getIdentifier(fileInfo: fileInfo) else {
            return .rootContainer
        }
        return NSFileProviderItemIdentifier(keyIdentifer.base64Encoded)
    }
    
    var parentItemIdentifier: NSFileProviderItemIdentifier {
        guard let parent = fileInfo.parent else {
            return .rootContainer
        }
        
        return NSFileProviderItemIdentifier(parent.base64Encoded)
    }
    
    var filename: String {
        return fileInfo.name
    }
    
    var typeIdentifier: String {
        if fileInfo.type == CiphertextFileType.DIRECTORY {
            return "public.folder"
        }
        else if fileInfo.type == CiphertextFileType.SYMLINK {
            return "public.symlink"
        }
        let comps = fileInfo.name.components(separatedBy: ".")
        
        guard let fileType = comps.last, !fileType.isEmpty else {
            return "unknown"
        }
        
        return CatorUtility.getUTI(fileType)
    }
    
    var capabilities: NSFileProviderItemCapabilities {
        let baseCapabilities: NSFileProviderItemCapabilities = [
            .allowsReading,
            .allowsTrashing,
        ]
        
        if fileInfo.type == CiphertextFileType.DIRECTORY {
            return baseCapabilities.union(
                [.allowsContentEnumerating, .allowsAddingSubItems]
            )
        } else {
            return baseCapabilities
        }
    }
    
    var documentSize: NSNumber? {
        guard let size = fileInfo.size, size > 0 else {
            return nil
        }
        return NSNumber(value: size)
    }
    
    var versionIdentifier: Data? {
        var version = fileInfo.lastUsedDate?.timeIntervalSince1970 ?? 1
        return Data(bytes: &version, count: MemoryLayout.size(ofValue: version))
    }
    
    static func ==(lhs: FileProviderItem, rhs: FileProviderItem) -> Bool {
        return lhs.fileInfo.name == rhs.fileInfo.name && lhs.fileInfo.parent == rhs.fileInfo.parent
    }
}

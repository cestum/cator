//
//  FileInfo.swift // basic fileinfo
//  Cator
//
//  Created by Cestum on 6/3/19.
//


import Foundation


class FileInfo: Codable {
    var name: String
    var parent: String?
    //directoryid
    var id: String?
    var internalPath: String?
    var size: Int64?
    var type: CiphertextFileType
    var lastUsedDate: Date?
    var isTrashed: Bool = false
    
    init (name: String,
          parent: String?,
          size: Int64?,
          type: CiphertextFileType = CiphertextFileType.UNKNOWN,
          id: String? = "",
          internalPath: String? = "") {
        self.name = name
        if let parent = parent {
            self.parent = parent.replacingOccurrences(of: "/", with: "+")
        }
        
        self.id = id
        self.internalPath = internalPath
        self.size = size
        self.type = type
        self.lastUsedDate = Date()
        
    }
    
    
    init?(url: URL) {
        do {
            let values = try url.resourceValues(
                forKeys: [.nameKey, .fileSizeKey]
            )
            
            guard let fileName = values.name, let size = values.fileSize, let type = fileName.components(separatedBy: ".").last else {
                return nil
            }
            self.parent = nil
            self.id = nil
            self.type =  CiphertextFileType.UNKNOWN
            self.size = Int64(size)
            self.name = [UUID().uuidString, type].joined(separator: ".")
        } catch {
            return nil
        }
    }
    
}

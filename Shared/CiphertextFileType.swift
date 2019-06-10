//
//  CiphertextFileType.swift
//  Cator
//
//  Created by Cestum on 6/4/19.
//

import Foundation

enum CiphertextFileType: String, Codable {
    case FILE = ""
    case DIRECTORY = "0"
    case SYMLINK = "1S"
    case UNKNOWN = "-"
    
    func type() ->String { return self.rawValue }
    func isTypeOfFile(filename: String) -> Bool {
        return filename.hasPrefix(self.rawValue)
    }

}

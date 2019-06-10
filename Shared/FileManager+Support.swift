//
//  extension to FileManager
//  Cator
//
//  Created by Cestum on 6/3/19.
//

import Foundation


extension FileManager{
    
    func createTemporaryDirectory() -> URL {
        do {
            let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
            
            try createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            return url
        } catch {
                return  URL(fileURLWithPath: NSTemporaryDirectory())
        }
    }
}

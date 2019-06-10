//
//  FileProviderEnumeratorUpdator.swift
//  Cator
//
//  Created by cestum on 6/5/19.
//

import Foundation

class FileProviderEnumeratorUpdator: NSObject {
    //total number of files for this session
    var size: Int
    //enumerator callback reference
    var completionBlock: CatorWrapper.MediaCompletionBlock
    //file items
    var items:[FileInfo]
    
    init?(_size: Int, _completionBlock: @escaping CatorWrapper.MediaCompletionBlock, _items: [FileInfo]){
        self.size = _size
        self.completionBlock = _completionBlock
        self.items = _items
    }
    
    func addItem(item:FileInfo) {
        self.items.append(item)
        if self.items.count == size {
            self.completionBlock(self.items, nil)
            //cleanup?
        }
    }
    
    func addError(err: Error?) {
        if err != nil {
            self.completionBlock([], err)
        }
    }
}

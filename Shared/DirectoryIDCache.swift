//
//  DirectoryIDCache.swift
//  Cator
//
//  Created by Cestum on 6/5/19.
//

import Foundation


final class DirectoryIDCache {
    static let shared = DirectoryIDCache()
    
    private let cache = NSCache<NSString, NSString>()
    private let anotherCache = NSCache<NSString, FileInfo>()
    
    func set(key: NSString, val: NSString) {
        
        guard cache.object(forKey: key) != nil else {
            // create it from scratch then store in the cache
            cache.setObject(val, forKey: key)
            return
        }
    }
    
    func get(key: NSString?) -> NSString? {
        guard let key = key, let cachedVersion = cache.object(forKey: key), cachedVersion.length > 0 else {
            // create it from scratch then store in the cache
            return nil
        }
        return cachedVersion;
    }
    
    func setA(key: NSString, val: FileInfo) {
        
        guard anotherCache.object(forKey: key) != nil else {
            // create it from scratch then store in the cache
            anotherCache.setObject(val, forKey: key)
            return
        }
    }
    
    func getA(key: NSString?) -> FileInfo? {
        guard let key = key, let cachedVersion = anotherCache.object(forKey: key) else {
            // create it from scratch then store in the cache
            return nil
        }
        return cachedVersion;
    }
    
    
}

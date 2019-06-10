//
//  CatorWrapper.swift
//  Cator
//
//  Created by Cestum on 6/3/19.
//
import Foundation
import FilesProvider

//Wrapper (more of an utility) for cryptomator filesystem
final class CatorWrapper {
    static let shared = CatorWrapper()
    
    typealias BasicCompletionBlock = (Error?) -> Void
    typealias MediaCompletionBlock = ([FileInfo], Error?) -> Void
    
    private var catorClient:CatorClient? = nil
    private var currentFileProvider:FileProvider?
    private var cryptomatorRoot:String?
    private var rootDirectoryHash:String?
    private var enumeratorUpdator:FileProviderEnumeratorUpdator? = nil
    private var tempDir:URL
    
    //init
    private init() {
        self.tempDir = FileManager.default.createTemporaryDirectory()
        //For local folders use this
        self.currentFileProvider = LocalFileProvider(for: .documentDirectory, in: .userDomainMask)
        //#error("CHANGE PASSWORD here")
//        let credential = URLCredential(user: "iamuser", password: "NOTAPASSWORD", persistence: .permanent)
//        self.currentFileProvider = WebDAVFileProvider(baseURL: URL(string: "https://example.com/dav")!, credential: credential)
    }
    

    func getMedia(at path: String?, completion: @escaping MediaCompletionBlock) {
        //    let fm = FileManager.default
        //    let path1 = Bundle.main.resourcePath!
        //
        //    do {
        //        let items = try fm.contentsOfDirectory(atPath: path1)
        //
        //        for item in items {
        //            print("Found \(item)")
        //        }
        //    } catch {
        //        // failed to read directory – bad permissions, perhaps?
        //    }
        
        var items = [FileInfo]()
        //    items.append(FileInfo(name: "Brand", size: 1000))
        //    completion(items, nil)
        var isCryptomatorDir = false
        
        //if there is a root hash already
        self.enumeratorUpdator = nil
        if let x = path, let cRoot = self.cryptomatorRoot, x.hasPrefix(cRoot) {
            if let dirId = DirectoryIDCache.shared.get(key: x as NSString) {
                self.decryptAndGetDirContents(currentCryptPath: x, parentDirectoryId: dirId as String, items: [FileInfo](), complete: {
                    decryptedItems,err  in
                    DispatchQueue.main.async {
                        self.enumeratorUpdator = nil
                        completion(decryptedItems, err)
                    }
                })
                return
            }
            
        }
        
        
        currentFileProvider!.contentsOfDirectory(path: path ?? "", completionHandler: {
            contents, error in
            for file in contents {
                print("Name: \(file.name)")
                print("Path: \(file.path)")
                print("Size: \(file.size)")
                //print("Creation Date: \(file.creationDate)")
                //print("Modification Date: \(file.modifiedDate)")
                if file.name.hasSuffix(".cryptomator") {
                    isCryptomatorDir = true
                    print("Found master key")
                    self.currentFileProvider!.contents(path: file.path, completionHandler: {
                        contents, error in
                        //#error("CHANGE PASSWORD here")
                        #warning("retrieve password from keychain?")
                        self.catorClient = CatorClient(pass:"test", masterKey: contents)
                        //get root directory
                        self.cryptomatorRoot = path ?? ""
                        self.decryptAndGetDirContents(currentCryptPath: self.cryptomatorRoot!, parentDirectoryId: "", items: [FileInfo](), complete: {
                            decryptedItems,err  in
                            DispatchQueue.main.async {
                                self.enumeratorUpdator = nil
                                completion(decryptedItems, err)
                            }
                        })
                    })
                } else {
                    items.append(FileInfo(name: file.name, parent: path, size: file.size, type: self.getCipherType(type: file.type)))
                }
            }
            if !isCryptomatorDir {
                DispatchQueue.main.async {
                    completion(items, error)
                }
            }
        })
    }
    //cryptomator func - scans all files inside a given dir and returns list of decrypted fileobject
    private func decryptAndGetDirContents(currentCryptPath: String, parentDirectoryId:String,  items: [FileInfo], complete: @escaping MediaCompletionBlock) {
        
        guard let parentDirectoryIdHash = self.catorClient?.setoCryptor?.encryptDirectoryId(parentDirectoryId) else {
            complete([], CatorError.unexpectedError)
            return
        }
        
        if parentDirectoryId.count == 0 {
            self.rootDirectoryHash = parentDirectoryIdHash
        }
        let firstTwo = parentDirectoryIdHash.prefix(2)
        let afterTwo = parentDirectoryIdHash.suffix(from: parentDirectoryIdHash.index(parentDirectoryIdHash.startIndex, offsetBy: 2))
        
        let pathToDig = NSString.path(withComponents: [self.cryptomatorRoot!, "d" ,String(firstTwo), String(afterTwo)])
        
        currentFileProvider!.contentsOfDirectory(path: pathToDig, completionHandler: {
            contents, error in
            let newItems = [FileInfo]()
            if self.enumeratorUpdator == nil {
                self.enumeratorUpdator = FileProviderEnumeratorUpdator.init(_size: contents.count , _completionBlock: complete, _items: newItems)
            }
            for file in contents {
                print("Name: \(file.name)")
                print("Path: \(file.path)")
                print("Size: \(file.size)")
                //print("Creation Date: \(file.creationDate)")
                //print("Modification Date: \(file.modifiedDate)")
                if CiphertextFileType.DIRECTORY.isTypeOfFile(filename: file.name) { //a directory
                    let actualFilename = file.name.suffix(from: file.name.index(file.name.startIndex, offsetBy: 1))
                    
                    guard let directoryName = self.catorClient?.setoCryptor?.decryptFilename(String(actualFilename), insideDirectoryWithId: parentDirectoryId)  else {
                        //invalid directory
                        continue;
                    }
                    print("found dir \(directoryName) inside \(parentDirectoryId)")
                    //get directory id of this file
                    self.currentFileProvider!.contents(path: file.path, completionHandler: { (d: Data?, e:Error?) in
                        //get the directoryid, cache it
                        //hash the directory id and get the directory structure
                        //newItems.append(FileInfo(name: directoryName, size: -1, id:  String(data: d!, encoding: String.Encoding.utf8) as String!))
                        let dirId = String(data: d!, encoding: String.Encoding.utf8)
                        let dKey = NSString.path(withComponents: [currentCryptPath, directoryName]) as NSString
                        DirectoryIDCache.shared.set(key: dKey, val: dirId! as NSString)
                        self.enumeratorUpdator?.addItem(item: FileInfo(name: directoryName, parent: currentCryptPath, size: file.size, type: CiphertextFileType.DIRECTORY,id:  dirId))
                        
                    })
                } else if CiphertextFileType.FILE.isTypeOfFile(filename: file.name) {
                    if let fileName = self.catorClient?.setoCryptor?.decryptFilename(file.name, insideDirectoryWithId: parentDirectoryId) {
                        print("found file \(fileName) inside \(parentDirectoryId)")
                        self.enumeratorUpdator?.addItem(item: FileInfo(name: fileName, parent: currentCryptPath, size: file.size,type: CiphertextFileType.FILE, internalPath: file.path))
                    }
                }
            }
        })
    }
    
    
    func downloadFile(at fileInfo: FileInfo, to destinationURL: URL, completion: BasicCompletionBlock?) {
        
        guard let encrypt = URL(string: destinationURL.absoluteString + ".encrypt") else {
            completion?(CatorError.unexpectedError)
            return
        }
        guard let internalPath = fileInfo.internalPath else {
            completion?(CatorError.unexpectedError)
            return
        }
        currentFileProvider?.copyItem(path: internalPath, toLocalURL: encrypt) { (eer: Error?) in
            self.catorClient?.setoCryptor?.decryptFile(atPath: encrypt.path, toPath: destinationURL.path, callback: { (decryptErr: Error?) in
                //self.enumeratorUpdator?.addError(err:decryptErr)
                self.currentFileProvider?.removeItem(path: encrypt.path, completionHandler: { (removeError: Error?) in
                    completion?(decryptErr)
                })
            }, progress: { (c:CGFloat) in
                #warning("Unused")
            })
        }
        
    }
    
    func getCipherType(type:URLFileResourceType) -> CiphertextFileType{
        switch type {
        case URLFileResourceType.directory:
            return CiphertextFileType.DIRECTORY
        case URLFileResourceType.regular:
            return CiphertextFileType.FILE
        case URLFileResourceType.symbolicLink:
            return CiphertextFileType.SYMLINK
        default:
            return CiphertextFileType.UNKNOWN
        }
    }
}

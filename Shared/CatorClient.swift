//
//  CatorClient.swift
//  Cator
//
//  Created by Cestum on 6/3/19.
//

import Foundation

    
class CatorClient {
    //static let shared = CatorClient("test")
    var setoCryptor:SETOCryptor?
    init?(pass: String, masterKey: Data?) {
        do {
            let setoMasterKey = SETOMasterKey.init()
            setoMasterKey.update(fromJSONData: masterKey!)
            self.setoCryptor = try SETOCryptorProvider.cryptor(from: setoMasterKey, withPassword: pass)
        } catch {
            return nil
        }
    }
    
}

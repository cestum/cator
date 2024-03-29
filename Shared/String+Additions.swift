//
//  extension to String
//  Cator
//
//  Created by Cestum on 6/3/19.
//

import Foundation

extension String {
    
  var base64Decoded: String {
    guard let data = Data(base64Encoded: self) else {
      return self
    }
    
    return String(data: data, encoding: .utf8) ?? self
  }
  
  var base64Encoded: String {
    return data(using: .utf8)?.base64EncodedString() ?? self
  }
}

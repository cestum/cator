//
//  CatorUtility
//  Cator
//
//  Created by Cestum on 6/10/19.
//

#import "CatorUtility.h"

#import <netinet/in.h>
#import <openssl/x509.h>
#import <openssl/bio.h>
#import <openssl/err.h>
#import <openssl/pem.h>


@implementation CatorUtility

+ (NSString *)getUTI:(NSString *)extension
{
    CFStringRef fileUTI = nil;
    NSString *returnFileUTI = nil;
    
        
    CFStringRef fileExtension = (__bridge CFStringRef) extension;
    NSString *ext = (__bridge NSString *)fileExtension;
    ext = ext.uppercaseString;
    fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    
    if (fileUTI != nil) {
        returnFileUTI = (__bridge NSString *)fileUTI;
        CFRelease(fileUTI);
    }
    
    return returnFileUTI;
}
@end

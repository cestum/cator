//
//  CatorUtility
//  Cator
//
//  Created by Cestum on 6/10/19.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <sys/utsname.h>
#import <sys/sysctl.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MessageUI/MessageUI.h>
#import <UICKeyChainStore/UICKeyChainStore.h>

@interface CatorUtility : NSObject


+ (NSString *)getUTI:(NSString *)extension;


@end

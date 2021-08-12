//
//  CameraAccess.m
//

#import "CameraAccess.h"

@implementation CameraAccess

@synthesize callbackId;

- (void) checkAccess:(CDVInvokedUrlCommand *)command {
    NSString* mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    CDVPluginResult* result = nil;
    
    if (authStatus == AVAuthorizationStatusAuthorized) {
        // Access Granted
        NSLog(@"Access to camera granted");
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Access granted"];
        [self invokeCallback:command withResult:result];
    } else if (authStatus == AVAuthorizationStatusNotDetermined){
        // Request Access
        NSLog(@"Access to camera not yet determined. Will ask user.");
        __block CDVPluginResult* result = nil;
        
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if(granted){
                NSLog(@"Access to camera granted by user");
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Access granted"];
                [self invokeCallback:command withResult:result];
            } else {
                NSLog(@"Access to camera denied by user");
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Access denied"];
                [self invokeCallback:command withResult:result];
            }
        } failureBlock:^(NSError* error) {
            NSLog(@"Other error code: %i", error.code);
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Access denied"];
            [self invokeCallback:command withResult:result];
        }];
    } else {
        // Unknown Access Status
        NSLog(@"Access to camera denied");
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Access denied"];
        [self invokeCallback:command withResult:result];
    }
}

- (void) invokeCallback:(CDVInvokedUrlCommand *)command withResult:(CDVPluginResult *)result {
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end

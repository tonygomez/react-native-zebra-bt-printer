//
//  RCTZebraBTPrinter.m
//  RCTZebraBTPrinter
//
//  Created by Jakub Martyčák on 17.04.16.
//  Copyright © 2016 Jakub Martyčák. All rights reserved.
//

#import "RCTZebraBTPrinter.h"

//ZEBRA
#import "ZebraPrinterConnection.h"
#import "ZebraPrinter.h"
#import "ZebraPrinterFactory.h"
#import "MfiBtPrinterConnection.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import "SGD.h"

@interface RCTZebraBTPrinter ()
@end

@implementation RCTZebraBTPrinter

RCT_EXPORT_MODULE();

- (dispatch_queue_t)methodQueue
{
    // run all module methods in main thread
    // if we don't no timer callbacks got called
    return dispatch_get_main_queue();
}

#pragma mark - Methods available form Javascript

RCT_EXPORT_METHOD(printers: (NSString *)type
                   resolve: (RCTPromiseResolveBlock)resolve
                   rejecter: (RCTPromiseRejectBlock)reject) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        NSMutableArray *printers = [[NSMutableArray alloc] init];
        
        EAAccessoryManager *sam = [EAAccessoryManager sharedAccessoryManager];
        NSArray *connectedAccessories = [sam connectedAccessories];
        for (EAAccessory *accessory in connectedAccessories) {
            if([accessory.protocolStrings indexOfObject:@"com.zebra.rawport"] != NSNotFound){
                NSString *printerData = [NSString stringWithFormat: @"%@,%@,%@,%@",
                    accessory.serialNumber,
                    accessory.manufacturer,
                    accessory.modelNumber,
                    accessory.name];

                [printers addObject: printerData];
            }
        }

        resolve((id)printers);
    });
}

-(BOOL)printContent:(NSString *) content onConnection:(id<ZebraPrinterConnection, NSObject>)connection withError:(NSError**)error {
    NSData *data = [NSData dataWithBytes:[content UTF8String] length:[content length]];
    [connection write:data error:error];

    if(*error == nil){
        return YES;
    } else {
        return NO;
    }
}

RCT_EXPORT_METHOD(print: (NSString *)printer
                  content:(NSString *)content
                  resolve: (RCTPromiseResolveBlock)resolve
                  rejector:(RCTPromiseRejectBlock)reject){
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        id<ZebraPrinterConnection, NSObject> connection = nil;
        connection = [[MfiBtPrinterConnection alloc] initWithSerialNumber:printer];
        
        BOOL success = [connection open];
        if(success == YES){
            NSError *error = nil;
            id<ZebraPrinter,NSObject> printer = [ZebraPrinterFactory getInstance:connection error:&error];

            if(printer != nil) {
                BOOL sent = [self printContent:content onConnection:connection withError:&error];
                if (sent != YES) {
                    reject(@"error", @"Print failed", error);
                }
            } else {
                reject(@"error", @"Could not detect Language", error);
            }

            [connection close];
            resolve((id)kCFBooleanTrue);
        } else {
            resolve((id)kCFBooleanFalse);
        }
    });
}

RCT_EXPORT_METHOD(testConnection: (NSString *)printer
                  resolve: (RCTPromiseResolveBlock)resolve
                  rejector:(RCTPromiseRejectBlock)reject){
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        id<ZebraPrinterConnection, NSObject> connection = nil;
        connection = [[MfiBtPrinterConnection alloc] initWithSerialNumber:printer];

        BOOL success = [connection open];
        if(success == YES){
            [connection close];
            resolve((id)kCFBooleanTrue);
        } else {
            resolve((id)kCFBooleanFalse);
        }
    });
}

RCT_EXPORT_METHOD(sgd: (NSString *)printer
                  key:(NSString *)key
                  value:(NSString *)value
                  resolve: (RCTPromiseResolveBlock)resolve
                  rejector:(RCTPromiseRejectBlock)reject){
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        id<ZebraPrinterConnection, NSObject> connection = nil;
        connection = [[MfiBtPrinterConnection alloc] initWithSerialNumber:printer];
        
        BOOL success = [connection open];
        if(success == YES){
            NSError *error = nil;
            [SGD SET:key withValue:value andWithPrinterConnection:connection error:&error];
            
            if(error == nil){
                resolve((id)kCFBooleanTrue);
            } else {
                resolve((id)kCFBooleanFalse);
            }
            
            [connection close];
        } else {
            resolve((id)kCFBooleanFalse);
        }
    });
}
@end

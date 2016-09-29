//
//  AppDelegate.m
//  iKeyboard
//
//  Created by Lin Chih-An on 2016/4/13.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import "AppDelegate.h"
#import "iKeyboardNormalModeViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.serafimPeripheral = 0;
    NSString* src = [[NSBundle mainBundle] pathForResource:@"sheets" ofType:@"plist"];
    NSFileManager* fm = [[NSFileManager alloc] init];
    NSString* sheetPlistPath = [NSString stringWithFormat:@"%@/Documents/sheets.plist", NSHomeDirectory()];
    if(![fm fileExistsAtPath:sheetPlistPath])
        [fm copyItemAtPath:src toPath:sheetPlistPath error:nil];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    if(self.serafimPeripheral && self.FFA1)
    {
        NSString* code = @"00";
        NSData* data = [self dataWithStringHex:code];
        [self.serafimPeripheral writeValue:data forCharacteristic:self.FFA1 type:CBCharacteristicWriteWithResponse];
    }
}

- (NSData *)dataWithStringHex:(NSString *)string
{
    NSString *cleanString;
    cleanString = [string stringByReplacingOccurrencesOfString:@"<" withString:@""];
    cleanString = [cleanString stringByReplacingOccurrencesOfString:@">" withString:@""];
    cleanString = [cleanString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSInteger length = [cleanString length];
    uint8_t buffer[length/2];
    for (NSInteger i = 0; i < length; i+=2)
    {
        unsigned result = 0;
        NSScanner *scanner = [NSScanner scannerWithString:[cleanString substringWithRange:NSMakeRange(i, 2)]];
        [scanner scanHexInt:&result];
        buffer[i/2] = result;
    }
    return  [[NSMutableData alloc] initWithBytes:&buffer   length:length/2];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    /*if(self.serafimPeripheral && self.FFA1)
    {
        NSString* code = @"00";
        NSData* data = [self dataWithStringHex:code];
        [self.serafimPeripheral writeValue:data forCharacteristic:self.FFA1 type:CBCharacteristicWriteWithResponse];
    }*/
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if(_serafimPeripheral && self.FFA1)
    {
        NSString* code = @"02";
        NSData* data = [self dataWithStringHex:code];
        [_serafimPeripheral writeValue:data forCharacteristic:self.FFA1 type:CBCharacteristicWriteWithResponse];
    }
    
    NSLog(@"jjjjj");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if(_serafimPeripheral && self.FFA1)
    {
        NSString* code = @"02";
        NSData* data = [self dataWithStringHex:code];
        [_serafimPeripheral writeValue:data forCharacteristic:self.FFA1 type:CBCharacteristicWriteWithResponse];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    if(_serafimPeripheral && self.FFA1)
    {
        NSString* code = @"00";
        NSData* data = [self dataWithStringHex:code];
        [_serafimPeripheral writeValue:data forCharacteristic:self.FFA1 type:CBCharacteristicWriteWithResponse];
    }
    NSLog(@"tttt");
}

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return UIInterfaceOrientationMaskAll;
    else  /* iphone */
        return UIInterfaceOrientationMaskLandscape;
}

@end

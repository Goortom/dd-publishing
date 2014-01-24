//
//  AppsFlyerTracker.h
//  AppsFlyerLib
//
//  AppsFlyer iOS SDK v2.5.3.2
//  1-Sep-2013
//  Copyright (c) 2013 AppsFlyer Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 This delegate should be use if you want to use AppsFlyer conversion data (Install referrer)
 */
@protocol AppsFlyerTrackerDelegate <NSObject>

@optional
- (void) onConversionDataReceived:(NSDictionary*) installData;
- (void) onConversionDataRequestFailure:(NSError *)error;

@end

@interface AppsFlyerTracker : NSObject {
    NSString* customerUserID;
    NSString* appsFlyerDevKey;
    NSString* appleAppID;
    NSString* currencyCode;
    BOOL deviceTrackingDisabled;
    id<AppsFlyerTrackerDelegate> appsFlyerDelegate;
    
    BOOL isDebug;
    BOOL isHTTPS;
}

@property (nonatomic,retain) NSString *customerUserID;
@property (nonatomic,retain) NSString *appsFlyerDevKey;
@property (nonatomic,retain) NSString *appleAppID;
@property (nonatomic,retain) NSString *currencyCode;
@property BOOL isHTTPS;

@property BOOL isDebug;
@property BOOL deviceTrackingDisabled;

+(AppsFlyerTracker*) sharedTracker;

- (void) trackAppLaunch;
- (void) trackEvent:(NSString*)eventName withValue:(NSString*)value;
- (NSString *) getAppsFlyerUID;
- (void) loadConversionDataWithDelegate:(id<AppsFlyerTrackerDelegate>) delegate;

@end

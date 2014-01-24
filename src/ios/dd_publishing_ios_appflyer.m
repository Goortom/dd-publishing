// DD Publishing Lib

#include "dd_publishing.h"

#ifdef DD_PBL_IOS_APPFLYER

#if __has_feature(objc_arc)
	#error This file cannot be compiled with ARC. Either turn off ARC for the project or use -fno-objc-arc flag
#endif

#import "AppsFlyerTracker.h"

//AppsFlyerTracker * tracker = nil;

void dd_pbl_ios_appflyer_session_start(const char * client_id, const char * apple_id)
{
	[AppsFlyerTracker sharedTracker].appsFlyerDevKey = [NSString stringWithUTF8String:client_id];
	[AppsFlyerTracker sharedTracker].appleAppID = [NSString stringWithUTF8String:apple_id];
	// Set currency code:
	[AppsFlyerTracker sharedTracker].currencyCode = @"USD"; // US Dollar
	
	// (Optional) Set customer user ID with the SDK and reporting (used to match with the client internal ID’s). See section 8 for more details.
	// [[AppsFlyerTracker sharedTracker].customerUserID =@"YOUR_CUSTOM_DEVICE_ID"];
	// (Optional) If you with the SDK to connect AppsFlyer's servers via HTTPS. The defaults is HTTP.
	// [AppsFlyerTracker sharedTracker].isHTTPS = YES;
}

void dd_pbl_ios_appflyer_track_eventAppLaunch()
{
	[[AppsFlyerTracker sharedTracker] trackAppLaunch];
}

void dd_pbl_ios_appflyer_track_event(const char * name, const char * data, const char * currency)
{
	if(currency != NULL)
		[AppsFlyerTracker sharedTracker].currencyCode = [NSString stringWithUTF8String:currency];
	
	if(data == NULL)
		[[AppsFlyerTracker sharedTracker] trackEvent:[NSString stringWithUTF8String:name] withValue:@""];
	else
		[[AppsFlyerTracker sharedTracker] trackEvent:[NSString stringWithUTF8String:name] withValue:[NSString stringWithUTF8String:data]];
}

#endif
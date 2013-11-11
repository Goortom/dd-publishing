// DD Publishing Lib

#include "dd_publishing.h"

#ifdef DD_PBL_IOS_ADX

#if __has_feature(objc_arc)
	#error This file cannot be compiled with ARC. Either turn off ARC for the project or use -fno-objc-arc flag
#endif

#import "AdXTracking.h"

AdXTracking * tracker = nil;

void dd_pbl_ios_adx_session_start(const char * client_id, const char * apple_id, const char * url_scheme)
{
	if(tracker == nil)
		tracker = [[AdXTracking alloc] init];

	[tracker setURLScheme:[NSString stringWithUTF8String:url_scheme]];
	[tracker setClientId:[NSString stringWithUTF8String:client_id]];
	[tracker setAppleId:[NSString stringWithUTF8String:apple_id]];
	[tracker reportAppOpen];
}

void dd_pbl_ios_adx_track_event(const char * name, const char * data, const char * currency, const char * custom_data)
{
	if(tracker == nil)
	{
		NSLog(@"AdX : Tried to track event before session start");
		return;
	}
	
	if(data == NULL)
		data = "";
	
	if((custom_data != NULL) && (currency == NULL))
		currency = "";
	
	if(custom_data)
	{
		[tracker	sendEvent:[NSString stringWithUTF8String:name]
					withData:[NSString stringWithUTF8String:data]
					andCurrency:[NSString stringWithUTF8String:currency]
					andCustomData:[NSString stringWithUTF8String:custom_data]];
	}
	else if(currency)
	{
		[tracker	sendEvent:[NSString stringWithUTF8String:name]
					withData:[NSString stringWithUTF8String:data]
					andCurrency:[NSString stringWithUTF8String:currency]];
	}
	else
	{
		[tracker sendEvent:[NSString stringWithUTF8String:name] withData:[NSString stringWithUTF8String:data]];
	}
}

void dd_pbl_ios_adx_handle_url(void * url)
{
	NSURL * nsurl = (NSURL*)url;
	
	NSMutableDictionary * dict = [[[NSMutableDictionary alloc] initWithCapacity:16] autorelease];
	
    NSArray * pairs = [[nsurl query] componentsSeparatedByString:@"&"];
	
    for(NSString * pair in pairs)
	{
        NSArray * elements = [pair componentsSeparatedByString:@"="];
        NSString * key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString * val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [dict setObject:val forKey:key];
    }
	
	NSString * ADXID = [dict objectForKey:@"ADXID"];
	if(ADXID)
        [tracker sendEvent:@"DeepLinkLaunch" withData:ADXID];
	
	[tracker handleOpenURL:nsurl];
}

#endif
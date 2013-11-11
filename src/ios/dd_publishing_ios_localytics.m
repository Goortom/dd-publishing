// DD Publishing Lib

#include "dd_publishing.h"

#ifdef DD_PBL_IOS_LOCALYTICS

#if __has_feature(objc_arc)
	#error This file cannot be compiled with ARC. Either turn off ARC for the project or use -fno-objc-arc flag
#endif

#import "LocalyticsSession.h"

void dd_pbl_ios_localytics_session_start(const char * key)
{
	[[LocalyticsSession shared] startSession:[NSString stringWithUTF8String:key]];
}

void dd_pbl_ios_localytics_session_end()
{
	[[LocalyticsSession shared] close];
	[[LocalyticsSession shared] upload];
}

void dd_pbl_ios_localytics_session_resume()
{
	[[LocalyticsSession shared] resume];
	[[LocalyticsSession shared] upload];
}

void dd_pbl_ios_localytics_track_event(const char * name, size_t attributes_count, const char ** parameters, const char ** values, uint32_t customer_value_increase)
{
	NSMutableDictionary * dict = nil;
	
	if(attributes_count)
	{
		dict = [[NSMutableDictionary alloc] initWithCapacity:attributes_count];
		
		for(size_t i = 0; i < attributes_count; ++i)
			[dict setObject:[NSString stringWithUTF8String:values[i]] forKey:[NSString stringWithUTF8String:parameters[i]]];
	}

	[[LocalyticsSession shared] tagEvent:[NSString stringWithUTF8String:name] attributes:dict customerValueIncrease:[NSNumber numberWithInt:customer_value_increase]];
	
	if(dict)
	{
		[dict release];
		dict = nil;
	}
}

void dd_pbl_ios_localytics_track_screen(const char * name)
{
	[[LocalyticsSession shared] tagScreen:[NSString stringWithUTF8String:name]];
}

#endif
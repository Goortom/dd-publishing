// DD Publishing Lib

#include "dd_publishing.h"

#ifdef DD_PBL_IOS_TESTFLIGHT

#if __has_feature(objc_arc)
	#error This file cannot be compiled with ARC. Either turn off ARC for the project or use -fno-objc-arc flag
#endif

#import "TestFlight.h"

void dd_pbl_ios_testflight_session_start(const char * key)
{
	[TestFlight takeOff:[NSString stringWithUTF8String:key]];
}

void dd_pbl_ios_testflight_pass_checkpoint(const char * checkpoint_name)
{
	[TestFlight passCheckpoint:[NSString stringWithUTF8String:checkpoint_name]];
}

void dd_pbl_ios_testflight_submit_feedback(const char * feedback)
{
	[TestFlight submitFeedback:[NSString stringWithUTF8String:feedback]];
}

#endif
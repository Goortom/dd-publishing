// DD Publishing Lib

#include "dd_publishing.h"

#ifdef DD_PBL_IOS_CHARTBOOST

#if __has_feature(objc_arc)
	#error This file cannot be compiled with ARC. Either turn off ARC for the project or use -fno-objc-arc flag
#endif

#import "Chartboost.h"

void dd_pbl_ios_chartboost_start(const char * app_id, const char * app_signature)
{
	Chartboost * cb = [Chartboost sharedChartboost];
	cb.appId = [NSString stringWithUTF8String:app_id];
	cb.appSignature = [NSString stringWithUTF8String:app_signature];
	
	[cb startSession];
	[cb cacheInterstitial];
}

void dd_pbl_ios_chartboost_show_interstitial()
{
	Chartboost * cb = [Chartboost sharedChartboost];
	[cb showInterstitial];
}

#endif
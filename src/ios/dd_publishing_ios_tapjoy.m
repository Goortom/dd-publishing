// DD Publishing Lib

#include "dd_publishing.h"

#ifdef DD_PBL_IOS_TAPJOY

#if __has_feature(objc_arc)
	#error This file cannot be compiled with ARC. Either turn off ARC for the project or use -fno-objc-arc flag
#endif

#import <Tapjoy/Tapjoy.h>

int8_t dd_pbl_ios_tapjoy_request_points_state = 0;
uint32_t dd_pbl_ios_tapjoy_points = 0;

void dd_pbl_ios_tapjoy_start(const char * app_id, const char * secret_key)
{
	[Tapjoy requestTapjoyConnect:[NSString stringWithUTF8String:app_id]
					   secretKey:[NSString stringWithUTF8String:secret_key]
						 options:@{ TJC_OPTION_ENABLE_LOGGING : @(YES) }];
}

void dd_pbl_ios_tapjoy_show_offers(void * viewcontroller)
{
	[Tapjoy showOffersWithViewController:(UIViewController*)viewcontroller];
}

void dd_pbl_ios_tapjoy_request_points()
{
	if(dd_pbl_ios_tapjoy_request_points_state < 0)
		return;
	
	dd_pbl_ios_tapjoy_request_points_state = -1;
	
	[Tapjoy getTapPointsWithCompletion:^
		(NSDictionary *parameters, NSError *error)
	{
		if(error)
		{
			dd_pbl_ios_tapjoy_request_points_state = 0;
		}
		else
		{
			dd_pbl_ios_tapjoy_request_points_state = 1;
			dd_pbl_ios_tapjoy_points = [parameters[@"amount"] intValue];
		}
	}];
}

int8_t dd_pbl_ios_tapjoy_is_points_aviable()
{
	return dd_pbl_ios_tapjoy_request_points_state;
}

uint32_t dd_pbl_ios_tapjoy_get_points()
{
	return dd_pbl_ios_tapjoy_points;
}

void dd_pbl_ios_tapjoy_spend_points(uint32_t count)
{
	if(dd_pbl_ios_tapjoy_request_points_state <= 0)
		return;
	
	[Tapjoy spendTapPoints:count completion:^
		(NSDictionary *parameters, NSError *error)
	{
		if(error)
		{
			dd_pbl_ios_tapjoy_request_points_state = 0;
		}
		else
		{
			dd_pbl_ios_tapjoy_request_points_state = 1;
			dd_pbl_ios_tapjoy_points = [parameters[@"amount"] intValue];
		}
	}];
}

#endif
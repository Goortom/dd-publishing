// DD Publishing Lib

#include "dd_publishing.h"

#ifdef DD_PBL_IOS_IAP

#if __has_feature(objc_arc)
	#error This file cannot be compiled with ARC. Either turn off ARC for the project or use -fno-objc-arc flag
#endif

#import "MKStoreManager.h"

void dd_pbl_ios_iap_buy(const char * name)
{
	[[MKStoreManager sharedManager] buyFeature:[NSString stringWithUTF8String:name] onComplete:^(NSString * purchasedFeature, NSData * purchasedReceipt, NSArray * availableDownloads){} onCancelled:^{}];
}

void dd_pbl_ios_iap_restore()
{
	[[MKStoreManager sharedManager] restorePreviousTransactionsOnComplete:^{} onError:^(NSError * error){}];
}

bool dd_pbl_ios_iap_is_bought(const char * name)
{
	return [MKStoreManager isFeaturePurchased:[NSString stringWithUTF8String:name]] || [[MKStoreManager sharedManager] isSubscriptionActive:[NSString stringWithUTF8String:name]];
}

bool dd_pbl_ios_iap_can_consume(const char * name)
{
	return [[MKStoreManager sharedManager] canConsumeProduct:[NSString stringWithUTF8String:name] quantity:1];
}

bool dd_pbl_ios_iap_consume(const char * name, uint32_t count)
{
	return [[MKStoreManager sharedManager] consumeProduct:[NSString stringWithUTF8String:name] quantity:count];
}

#endif
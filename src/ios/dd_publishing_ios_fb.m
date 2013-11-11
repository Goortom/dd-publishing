// DD Publishing Lib

#include "dd_publishing.h"

#ifdef DD_PBL_IOS_FB

#if __has_feature(objc_arc)
	#error This file cannot be compiled with ARC. Either turn off ARC for the project or use -fno-objc-arc flag
#endif

#import <FacebookSDK/FacebookSDK.h>

// helper for debug
// [FBSettings setLoggingBehavior:[NSSet setWithObjects: FBLoggingBehaviorFBRequests, nil]];

FBSession * fb_session = nil;
int8_t fb_session_state = -2;

typedef struct
{
	uint64_t uid;
	char name[256];
} fb_user;

fb_user fb_me;

const uint32_t fb_friends_count_max = 64;
uint32_t fb_friends_count = 0;
fb_user fb_friends[fb_friends_count_max];

void dd_pbl_ios_fb_grab_data()
{
	if(fb_session_state != 1)
		return;
	
	fb_session_state = -1;
	
	[FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection * connection, id<FBGraphUser> user, NSError * error) {
		if(error)
		{
			if(fb_session_state == -1)
				fb_session_state = 0;
			NSLog(@"fb grab data failed with error %@", [error localizedDescription]);
		}
		else
		{
			NSNumberFormatter * form = [[NSNumberFormatter alloc] init];
			
			fb_me.uid = [[form numberFromString:user.id] unsignedLongLongValue];
			
			const char * name = [user.name UTF8String];
			
			if(name)
			{
				memset(fb_me.name, 0, sizeof(fb_me.name));
				memcpy(fb_me.name, name, MIN(strlen(name), sizeof(fb_me.name) - 1));
			}
			
			[form release];
			
			NSString * query = @"SELECT uid, name FROM user WHERE is_app_user = 1 AND uid IN (SELECT uid2 FROM friend WHERE uid1 = me())";
			NSDictionary *queryParam = @{@"q" : query};
			
			[FBRequestConnection startWithGraphPath:@"/fql" parameters:queryParam HTTPMethod:@"GET" completionHandler:^
			 (FBRequestConnection *connection, id result, NSError *error)
			{
				if(error)
				{
					if(fb_session_state == -1)
						fb_session_state = 0;
					NSLog(@"fb grab friends data failed with error %@", [error localizedDescription]);
				}
				else
				{
					NSNumberFormatter * form = [[NSNumberFormatter alloc] init];

					NSArray * arr = (NSArray*)[result data];

					fb_friends_count = 0;

					for(id user in arr)
					{
						fb_friends[fb_friends_count].uid = [[form numberFromString:user[@"uid"]] unsignedLongLongValue];

						const char * name = [user[@"name"] UTF8String];

						if(name)
						{
							memset(fb_friends[fb_friends_count].name, 0, sizeof(fb_me.name));
							memcpy(fb_friends[fb_friends_count].name, name, MIN(strlen(name), sizeof(fb_me.name) - 1));
						}

						fb_friends_count = fb_friends_count + 1;

						if(fb_friends_count >= fb_friends_count_max)
							break;
					}

					[form release];

					fb_session_state = 1;
				}
			}];
		}
	}];
}

void dd_pbl_ios_fb_init()
{
	if(fb_session_state != -2)
		return;
	
	if(fb_session == nil)
	{
		//session = [[[FBSession alloc] initWithAppID:[NSString stringWithUTF8String:fbapp_id] permissions:[NSArray arrayWithObjects:@"basic_info", nil] urlSchemeSuffix:nil tokenCacheStrategy:nil] retain];
		fb_session = [[[FBSession alloc] init] retain];
		[FBSession setActiveSession:fb_session];
	}
	
	if(fb_session.state == FBSessionStateCreatedTokenLoaded)
	{
		fb_session_state = -1;
		[fb_session openWithCompletionHandler:^
			(FBSession * session, FBSessionState status, NSError * error)
		{
			if(error == nil)
			{
				fb_session_state = 1;
				dd_pbl_ios_fb_grab_data();
			}
			else
			{
				NSLog(@"fb open failed with error %@", [error localizedDescription]);
				fb_session_state = 0;
			}
		}];
	}
	else
		fb_session_state = 0;
}

int8_t dd_pbl_ios_fb_is_aviable() // > 0 then ok, if == 0 then not auth, if == -1 then waiting for result, if == -2 then not aviable
{
	return fb_session_state;
}

void dd_pbl_ios_fb_auth()
{
	if(fb_session_state != 0)
		return;
	
	fb_session_state = -1;
	[fb_session openWithCompletionHandler:^
		(FBSession * session, FBSessionState status, NSError * error)
	{
		if(error == nil)
		{
			fb_session_state = 1;
			dd_pbl_ios_fb_grab_data();
		}
		else
		{
			NSLog(@"fb open failed with error %@", [error localizedDescription]);
			fb_session_state = 0;
		}
	}];
}

void dd_pbl_ios_fb_logout()
{
	if(fb_session_state != 1)
		return;
		
	[fb_session closeAndClearTokenInformation];
	fb_session_state = -2;
	[fb_session release];
	fb_session = nil;
}

void dd_pbl_ios_fb_app_become_active()
{
	[FBAppEvents activateApp];
	[FBAppCall handleDidBecomeActive];
}

bool dd_pbl_ios_fb_handle_url(void * url, void * source_app) // actually its NSURL* and NSString*, use it in handleOpenURL and openURL
{
	return [FBAppCall handleOpenURL:(NSURL*)url sourceApplication:(NSString*)source_app];
}

uint64_t dd_pbl_ios_fb_user_id()
{
	return fb_me.uid;
}

const char * dd_pbl_ios_fb_user_name()
{
	return fb_me.name;
}

uint32_t dd_pbl_ios_fb_friends_count()
{
	return fb_friends_count;
}

uint64_t dd_pbl_ios_fb_friend_id(uint32_t index)
{
	if(index < fb_friends_count)
		return fb_friends[index].uid;
	else
		return UINT64_MAX;
}

const char * dd_pbl_ios_fb_friend_user_name(uint32_t index)
{
	if(index < fb_friends_count)
		return fb_friends[index].name;
	else
		return "%invalid%";
}

void dd_pbl_ios_fb_publish_feed(const char * name, const char * caption, const char * descr, const char * link, const char * picture)
{
	FBShareDialogParams * share_params = [[[FBShareDialogParams alloc] init] autorelease];
	
	if(name)
		share_params.name = [NSString stringWithUTF8String:name];
	if(caption)
		share_params.caption = [NSString stringWithUTF8String:caption];
	if(descr)
		share_params.description = [NSString stringWithUTF8String:descr];
	if(link)
		share_params.link = [NSURL URLWithString:[NSString stringWithUTF8String:link]];
	if(picture)
		share_params.picture = [NSURL URLWithString:[NSString stringWithUTF8String:picture]];

    if([FBDialogs canPresentShareDialogWithParams:share_params])
	{
		[FBDialogs presentShareDialogWithParams:share_params clientState:nil handler:^
			(FBAppCall *call, NSDictionary *results, NSError *error)
		{
			if(error)
			{
				NSLog(@"fb publish feed failed with error %@", [error localizedDescription]);
			}
			else if(results[@"completionGesture"] && [results[@"completionGesture"] isEqualToString:@"cancel"])
			{
			}
			else
			{
			}
		}];
	}
	else
	{
		NSMutableDictionary * params = [[[NSMutableDictionary alloc] init] autorelease];
		
		if(name)
			[params setObject:[NSString stringWithUTF8String:name] forKey:@"name"];
		if(caption)
			[params setObject:[NSString stringWithUTF8String:caption] forKey:@"caption"];
		if(descr)
			[params setObject:[NSString stringWithUTF8String:descr] forKey:@"description"];
		if(link)
			[params setObject:[NSString stringWithUTF8String:link] forKey:@"link"];
		if(picture)
			[params setObject:[NSString stringWithUTF8String:picture] forKey:@"picture"];
		
		[FBWebDialogs presentFeedDialogModallyWithSession:nil parameters:params handler:^
			(FBWebDialogResult result, NSURL * resultURL, NSError * error)
		{
			if(error)
			{
				NSLog(@"fb publish feed failed with error %@", [error localizedDescription]);
			}
			else
			{
				if(result == FBWebDialogResultDialogNotCompleted)
				{
				}
				else
				{
				}
			}
		}];
    }
}

void dd_pbl_ios_fb_invite_friends(const char * message)
{
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
		message:[NSString stringWithUTF8String:(message ? message : "")]
		title:nil
		parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:nil]
		handler:^
	(FBWebDialogResult result, NSURL *resultURL, NSError *error)
	{
		if(error)
		{
			NSLog(@"fb invite friends failed with error %@", [error localizedDescription]);
		}
		else
		{
			if(result == FBWebDialogResultDialogNotCompleted)
			{
			}
			else
			{
			}
		}
	}];
}

#endif
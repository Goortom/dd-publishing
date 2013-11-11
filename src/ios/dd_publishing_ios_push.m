// DD Publishing Lib

#include "dd_publishing.h"

#ifdef DD_PBL_IOS_PUSH_NOTIF

#if __has_feature(objc_arc)
	#error This file cannot be compiled with ARC. Either turn off ARC for the project or use -fno-objc-arc flag
#endif

int32_t dd_pbl_ios_push_add(const char * text, uint32_t seconds)
{
	int32_t push_id = 0;
	
	NSArray * local_pushes = [[UIApplication sharedApplication] scheduledLocalNotifications];
	
	for(size_t i = 0; i < local_pushes.count; ++i)
	{
		int32_t obj_push_id = [[[[local_pushes objectAtIndex:i] userInfo] objectForKey:@"push_id"] integerValue];
		
		if(obj_push_id > push_id)
			push_id = obj_push_id;
	}
	
	push_id = push_id + 1;
	
	UILocalNotification * localNotification = [[UILocalNotification alloc] init];
	[localNotification setApplicationIconBadgeNumber:1];
	[localNotification setAlertBody:[NSString stringWithCString:text encoding:NSUTF8StringEncoding]];
	[localNotification setSoundName:UILocalNotificationDefaultSoundName];
	[localNotification setFireDate:[NSDate dateWithTimeIntervalSinceNow:seconds]];
	[localNotification setTimeZone:[NSTimeZone defaultTimeZone]];
	[localNotification setUserInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:push_id] forKey:@"push_id"]];
	[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
	[localNotification release];
	
	return push_id;
}

bool dd_pbl_ios_push_remove(int32_t push_id)
{
	bool remove_anyone = false;
	
	NSArray * local_pushes = [[UIApplication sharedApplication] scheduledLocalNotifications];
	
	for(size_t i = 0; i < local_pushes.count; ++i)
	{
		int32_t obj_push_id = [[[[local_pushes objectAtIndex:i] userInfo] objectForKey:@"push_id"] integerValue];
		
		if((push_id < 0) || (push_id == obj_push_id))
		{
			[[UIApplication sharedApplication] cancelLocalNotification:[local_pushes objectAtIndex:i]];
			remove_anyone = true;
		}
	}
	
	return remove_anyone;
}

void dd_pbl_ios_push_clear_badges()
{
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

#endif
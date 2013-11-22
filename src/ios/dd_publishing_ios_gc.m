// DD Publishing Lib

#include "dd_publishing.h"

#ifdef DD_PBL_IOS_GC

#if __has_feature(objc_arc)
	#error This file cannot be compiled with ARC. Either turn off ARC for the project or use -fno-objc-arc flag
#endif

#include <stdlib.h>
#import <GameKit/GameKit.h>
#import <CommonCrypto/CommonDigest.h>

// lets enable this when we drop iOS 6 support
//#define DD_PBL_IOS_GC_IOS_7_ONLY

dd_pbl_ios_gc_present_viewcontroller_callback gc_callback = NULL;
int8_t gc_session_state = -2;

typedef struct
{
	char uid[64];
	char name[256];
} gc_user;

gc_user gc_me;

typedef struct
{
	gc_user user;
	int64_t score;
} gc_score;

const uint32_t gc_friends_count_max = 64;
uint32_t gc_friends_count = 0;
gc_user gc_friends[gc_friends_count_max];

const uint32_t gc_scores_count_max = 64;
uint32_t gc_scores_count = 0;
int8_t gc_scores_retrieve_status = 0;
gc_score gc_scores[gc_scores_count_max];

void dd_pbl_ios_gc_save_strcpy(char * buffer, size_t buffer_size, const char * str)
{
	if(!buffer_size)
		return;
	
	memset(buffer, 0, buffer_size);
	
	if(strlen(str) >= buffer_size - 1)
		memcpy(buffer, str, buffer_size - 1);
	else
		strcpy(buffer, str);
}

void dd_pbl_ios_gc_set_preset_viewcontroller(dd_pbl_ios_gc_present_viewcontroller_callback callback)
{
	gc_callback = callback;

	gc_session_state = -1;

	[[GKLocalPlayer localPlayer] setAuthenticateHandler:^
		(UIViewController * viewcontroller, NSError * error)
	{
		if(error != nil)
		{
			NSLog(@"gc auth failed with error %@", [error localizedDescription]);
			gc_session_state = 0;
		}
		else if(viewcontroller != nil)
		{
			if(gc_callback)
			{
				gc_session_state = -1;
				(*gc_callback)(viewcontroller);
			}
			else
			{
				NSLog(@"gc auth failed - no gc auth callback set");
				gc_session_state = 0;
			}
		}
		else
		{
			gc_session_state = -1;

			dd_pbl_ios_gc_save_strcpy(gc_me.uid, sizeof(gc_me.uid), [[[GKLocalPlayer localPlayer] playerID] UTF8String]);
			
			// TODO, GC ask us to use displayName instead of alias
			dd_pbl_ios_gc_save_strcpy(gc_me.name, sizeof(gc_me.name), [[[GKLocalPlayer localPlayer] alias] UTF8String]);
			
			[[GKLocalPlayer localPlayer] loadFriendsWithCompletionHandler:^
				(NSArray * friends, NSError * error)
			{
				if(error != nil)
				{
					NSLog(@"gc get friends failed with error %@", [error localizedDescription]);
					gc_session_state = 0;
				}
				else
				{
					[GKPlayer loadPlayersForIdentifiers:friends withCompletionHandler:^
						(NSArray * players, NSError * error)
					{
						if(error != nil)
						{
							NSLog(@"gc get friends failed with error %@", [error localizedDescription]);
							gc_session_state = 0;
						}
						else
						{
							gc_friends_count = 0;
							
							for(GKPlayer * player in players)
							{
								dd_pbl_ios_gc_save_strcpy(gc_friends[gc_friends_count].uid, sizeof(gc_me.uid), [[player playerID] UTF8String]);

								// TODO, GC ask us to use displayName instead of alias
								dd_pbl_ios_gc_save_strcpy(gc_friends[gc_friends_count].name, sizeof(gc_me.name), [[player alias] UTF8String]);
								
								++gc_friends_count;
								
								if(gc_friends_count >= gc_friends_count_max)
									break;
							}
							
							gc_session_state = 1;
						}
					}];
				}
			}];
		}
	}];
}

int8_t dd_pbl_ios_gc_is_aviable() // > 0 then ok, if == 0 then not auth, if == -1 then waiting for result, if == -2 then not aviable
{
	return gc_session_state;
}

void dd_pbl_ios_gc_auth()
{
	dd_pbl_ios_gc_set_preset_viewcontroller(gc_callback);
}

const char * dd_pbl_ios_gc_user_id()
{
	return gc_me.uid;
}

const char * dd_pbl_ios_gc_user_name()
{
	return gc_me.name;
}

uint32_t dd_pbl_ios_gc_friends_count()
{
	return gc_friends_count;
}

const char * dd_pbl_ios_gc_friend_id(uint32_t index)
{
	if(index < gc_friends_count)
		return gc_friends[index].uid;
	else
		return "%invalid%";
}

const char * dd_pbl_ios_gc_friend_user_name(uint32_t index)
{
	if(index < gc_friends_count)
		return gc_friends[index].name;
	else
		return "%invalid%";
}

uint64_t dd_pbl_ios_gc_unsafe_id_to_uint64_t(const char * user_id) // unsafe method to convert string id to uint64_t, no guarantee
{
	if((user_id[0] == 'G') && (user_id[1] == ']')) // probably apple wont change it forever
		return strtoull(user_id + 2, NULL, 10);

	char temp_buf[2048]; // oh apple

	strcpy(temp_buf, user_id);
	size_t l = strlen(user_id);

	size_t j = 0;
	for(size_t i = 0; i < l; ++i)
		if(((temp_buf[i] >= '0') && (temp_buf[i] <= '9')) || ((temp_buf[i] >= 'a') && (temp_buf[i] <= 'f')) || ((temp_buf[i] >= 'A') && (temp_buf[i] <= 'F')))
			temp_buf[j++] = temp_buf[i];
	temp_buf[j] = '\0';
	
	char * end = NULL;
	uint64_t temp = strtoull(temp_buf, &end, 16);
	if(end != temp_buf)
		return temp;

	unsigned char md5bin[16]; // oh apple apple
	CC_MD5(user_id, strlen(user_id), md5bin);
	
	temp = 0;
	for(size_t i = 0; i < 16; i += 2)
		temp += md5bin[i];
	
	return temp;
}

#ifdef DD_PBL_IOS_GC_IOS_7_ONLY
/*
void dd_pbl_ios_gc_scores_retrieve(const char * leaderboard_name)
{
	gc_scores_retrieve_status = 0;
	gc_scores_count = 0;
	
	GKLeaderboard * leaderboard = [[[GKLeaderboard alloc] init] autorelease];
	leaderboard.playerScope = GKLeaderboardPlayerScopeGlobal;
	leaderboard.timeScope = GKLeaderboardTimeScopeAllTime;
	leaderboard.identifier = [NSString stringWithUTF8String:leaderboard_name];
	leaderboard.range = NSMakeRange(1, gc_scores_count_max);
	[leaderboard loadScoresWithCompletionHandler:
	 ^(NSArray * scores, NSError * error)
	 {
		 if(!error && scores)
		 {
			 NSMutableArray * identifiers = [[NSMutableArray alloc] init];
			 
			 for(GKScore * score in scores)
			 {
				 NSLog(@"score retrieved: %lld", score.value);
				 
				 gc_scores[gc_scores_count].score = score.value;
				 
				 dd_pbl_ios_gc_save_strcpy(gc_scores[gc_scores_count].user.uid, sizeof(gc_scores[gc_scores_count].user.uid), [[score playerID] UTF8String]);
				 
				 [identifiers addObject:score.playerID];
				 
				 gc_scores_count++;
				 
				 if(gc_scores_count >= gc_scores_count_max)
					 break;
			 }
			 
			 [GKPlayer loadPlayersForIdentifiers:identifiers withCompletionHandler:
			  ^(NSArray *players, NSError *error)
			  {
				  if(!error && players)
				  {
					  for(size_t i = 0; i < [players count]; ++i)
					  {
						  GKPlayer * player = [players objectAtIndex:i];
						  
						  for(size_t j = 0; j < gc_scores_count; ++j)
						  {
							  if(!strcmp(gc_scores[j].user.uid, [[player playerID] UTF8String]))
							  {
								  dd_pbl_ios_gc_save_strcpy(gc_scores[j].user.name, sizeof(gc_scores[j].user.name), [[player alias] UTF8String]);
							  }
						  }
					  }
				  }
				  else
				  {
					  NSLog(@"gc scores - something wrong");
				  }
			  }];

			 [identifiers release];
		 }
		 else
		 {
			 NSLog(@"gc scores - something wrong");
		 }
		 
		 gc_scores_retrieve_status = 1;
	 }];
}

int8_t dd_pbl_ios_gc_scores_retrieve_status()
{
	return gc_scores_retrieve_status;
}

uint32_t dd_pbl_ios_gc_scores_count()
{
	return gc_scores_count;
}

int64_t dd_pbl_ios_gc_score(uint32_t index)
{
	if(index < gc_scores_count)
		return gc_scores[index].score;
	else
		return -1;
}

const char * dd_pbl_ios_gc_score_user_id(uint32_t index)
{
	if(index < gc_scores_count)
		return gc_scores[index].user.uid;
	else
		return "%invalid%";
}

const char * dd_pbl_ios_gc_score_user_name(uint32_t index)
{
	if(index < gc_scores_count)
		return gc_scores[index].user.name;
	else
		return "%invalid%";
}

void dd_pbl_ios_gc_leaderboard_show(const char * name)
{
	GKGameCenterViewController * leaderboard = [[[GKGameCenterViewController alloc] init] autorelease];
	leaderboard.viewState = GKGameCenterViewControllerStateLeaderboards;

	if(gc_callback)
	{
		(*gc_callback)(leaderboard);
	}
	else
	{
		NSLog(@"gc show leaderboard - no gc auth callback set");
	}
}

void dd_pbl_ios_gc_leaderboard_report(const char * name, uint32_t value)
{
	GKScore * score = [[[GKScore alloc] initWithLeaderboardIdentifier:[NSString stringWithUTF8String:name]] autorelease];
    score.value = value;
    score.context = 0;

	[GKScore reportScores:@[score] withCompletionHandler:^
	 (NSError *error)
	 {
		 if(error != nil)
		 {
			 NSLog(@"gc report score failed with error %@", [error localizedDescription]);
		 }
	 }];
}

void dd_pbl_ios_gc_achievements_show()
{
	GKGameCenterViewController * achievements = [[[GKGameCenterViewController alloc] init] autorelease];
    achievements.viewState = GKGameCenterViewControllerStateAchievements;

	if(gc_callback)
	{
		(*gc_callback)(achievements);
	}
	else
	{
		NSLog(@"gc show achievements - no gc auth callback set");
	}
}

void dd_pbl_ios_gc_achievements_report(const char * name, float value) // value from 0 to 1
{
	GKAchievement * achv = [[[GKAchievement alloc] initWithIdentifier:[NSString stringWithUTF8String:name]] autorelease];
	achv.percentComplete = value * 100.0f;
	
	[GKAchievement reportAchievements:@[achv] withCompletionHandler:^
	 (NSError *error)
	 {
		 if(error != nil)
		 {
			 NSLog(@"gc report achievements failed with error %@", [error localizedDescription]);
		 }
	 }];
}

void dd_pbl_ios_gc_achievements_reset()
{
	[GKAchievement resetAchievementsWithCompletionHandler:^
	 (NSError *error)
	 {
		 if(error != nil)
		 {
			 NSLog(@"gc achievements reset failed with error %@", [error localizedDescription]);
		 }
	 }];
}
*/

#else

@interface dd_pbl_ios_gc_nav_proxy : NSObject <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
@end

@implementation dd_pbl_ios_gc_nav_proxy

-(void)achievementViewControllerDidFinish:(GKAchievementViewController*)viewController
{
	(*gc_callback)(NULL);
}

-(void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController*)viewController
{
	(*gc_callback)(NULL);
}

@end

void dd_pbl_ios_gc_scores_retrieve(const char * leaderboard_name)
{
	gc_scores_retrieve_status = 0;
	gc_scores_count = 0;
	
	GKLeaderboard * leaderboard = [[[GKLeaderboard alloc] init] autorelease];
	leaderboard.playerScope = GKLeaderboardPlayerScopeGlobal;
	leaderboard.timeScope = GKLeaderboardTimeScopeAllTime;
	leaderboard.category = [NSString stringWithUTF8String:leaderboard_name];
	leaderboard.range = NSMakeRange(1, gc_scores_count_max);
	[leaderboard loadScoresWithCompletionHandler:
	 ^(NSArray * scores, NSError * error)
	 {
		 if(!error && scores)
		 {
			 NSMutableArray * identifiers = [[NSMutableArray alloc] init];
			 
			 for(GKScore * score in scores)
			 {
				 NSLog(@"score retrieved: %lld", score.value);
				 
				 gc_scores[gc_scores_count].score = score.value;
				 
				 dd_pbl_ios_gc_save_strcpy(gc_scores[gc_scores_count].user.uid, sizeof(gc_scores[gc_scores_count].user.uid), [[score playerID] UTF8String]);
				 
				 [identifiers addObject:score.playerID];
				 
				 gc_scores_count++;
				 
				 if(gc_scores_count >= gc_scores_count_max)
					 break;
			 }
			 
			 [GKPlayer loadPlayersForIdentifiers:identifiers withCompletionHandler:
			  ^(NSArray *players, NSError *error)
			  {
				  if(!error && players)
				  {
					  for(size_t i = 0; i < [players count]; ++i)
					  {
						  GKPlayer * player = [players objectAtIndex:i];
						  
						  for(size_t j = 0; j < gc_scores_count; ++j)
						  {
							  if(!strcmp(gc_scores[j].user.uid, [[player playerID] UTF8String]))
							  {
								  dd_pbl_ios_gc_save_strcpy(gc_scores[j].user.name, sizeof(gc_scores[j].user.name), [[player alias] UTF8String]);
							  }
						  }
					  }
				  }
				  else
				  {
					  NSLog(@"gc scores - something wrong");
				  }
			  }];

			 [identifiers release];
		 }
		 else
		 {
			 NSLog(@"gc scores - something wrong");
		 }
		 
		 gc_scores_retrieve_status = 1;
	 }];
}

int8_t dd_pbl_ios_gc_scores_retrieve_status()
{
	return gc_scores_retrieve_status;
}

uint32_t dd_pbl_ios_gc_scores_count()
{
	return gc_scores_count;
}

int64_t dd_pbl_ios_gc_score(uint32_t index)
{
	if(index < gc_scores_count)
		return gc_scores[index].score;
	else
		return -1;
}

const char * dd_pbl_ios_gc_score_user_id(uint32_t index)
{
	if(index < gc_scores_count)
		return gc_scores[index].user.uid;
	else
		return "%invalid%";
}

const char * dd_pbl_ios_gc_score_user_name(uint32_t index)
{
	if(index < gc_scores_count)
		return gc_scores[index].user.name;
	else
		return "%invalid%";
}

void dd_pbl_ios_gc_leaderboard_show(const char * name)
{
	GKLeaderboardViewController * leaderboard = [[[GKLeaderboardViewController alloc] init] autorelease];
	[leaderboard setCategory:[NSString stringWithUTF8String:name]];
	[leaderboard setLeaderboardDelegate:[[dd_pbl_ios_gc_nav_proxy alloc] init]];

	if(gc_callback)
	{
		(*gc_callback)(leaderboard);
	}
	else
	{
		NSLog(@"gc show leaderboard - no gc auth callback set");
	}
}

void dd_pbl_ios_gc_leaderboard_report(const char * name, uint32_t value)
{
	GKScore * score = [[[GKScore alloc] initWithCategory:[NSString stringWithUTF8String:name]] autorelease];
    score.value = value;
    score.context = 0;
	
	[GKScore reportScores:@[score] withCompletionHandler:^
	 (NSError *error)
	 {
		 if(error != nil)
		 {
			 NSLog(@"gc report score failed with error %@", [error localizedDescription]);
		 }
	 }];
}

void dd_pbl_ios_gc_achievements_show()
{
	GKAchievementViewController * achievements = [[[GKAchievementViewController alloc] init] autorelease];
	[achievements setAchievementDelegate:[[dd_pbl_ios_gc_nav_proxy alloc] init]];

	if(gc_callback)
	{
		(*gc_callback)(achievements);
	}
	else
	{
		NSLog(@"gc show achievements - no gc auth callback set");
	}
}

void dd_pbl_ios_gc_achievements_report(const char * name, float value) // value from 0 to 1
{
	GKAchievement * achv = [[[GKAchievement alloc] initWithIdentifier:[NSString stringWithUTF8String:name]] autorelease];
	achv.percentComplete = value * 100.0f;

	[GKAchievement reportAchievements:@[achv] withCompletionHandler:
	 ^(NSError *error)
	 {
		 if(error != nil)
		 {
			 NSLog(@"gc report achievements failed with error %@", [error localizedDescription]);
		 }
	 }];
}

void dd_pbl_ios_gc_achievements_reset()
{
	[GKAchievement resetAchievementsWithCompletionHandler:^
	 (NSError *error)
	 {
		 if(error != nil)
		 {
			 NSLog(@"gc achievements reset failed with error %@", [error localizedDescription]);
		 }
	 }];
}

#endif

#endif
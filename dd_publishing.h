// DD Publishing Lib

#pragma once

#include <stdint.h>
#include <stdbool.h>
#include "dd_publishing_config.h"

#ifdef __cplusplus
extern "C" {
#endif
	
// ------------------------------------------------------------------------------------------- iOS

// -------------------------------------- In-App Purchse

void dd_pbl_ios_iap_buy(const char * name);
void dd_pbl_ios_iap_restore();

bool dd_pbl_ios_iap_is_bought(const char * name);
bool dd_pbl_ios_iap_can_consume(const char * name);
bool dd_pbl_ios_iap_consume(const char * name, uint32_t count);

// -------------------------------------- Game Center

typedef void (*dd_pbl_ios_gc_present_viewcontroller_callback)(void * viewcontroller); // UIViewController type

void dd_pbl_ios_gc_set_preset_viewcontroller(dd_pbl_ios_gc_present_viewcontroller_callback callback);

int8_t dd_pbl_ios_gc_is_aviable(); // > 0 then ok, if == 0 then not auth, if == -1 then waiting for result, if == -2 then not aviable
void dd_pbl_ios_gc_auth();

const char * dd_pbl_ios_gc_user_id();
const char * dd_pbl_ios_gc_user_name();

uint32_t dd_pbl_ios_gc_friends_count();
const char * dd_pbl_ios_gc_friend_id(uint32_t index);
const char * dd_pbl_ios_gc_friend_user_name(uint32_t index);

uint64_t dd_pbl_ios_gc_unsafe_id_to_uint64_t(const char * user_id); // unsafe method to convert string id to uint64_t, no guarantee

void dd_pbl_ios_gc_leaderboard_show(const char * name);
void dd_pbl_ios_gc_leaderboard_report(const char * name, uint32_t value);

void dd_pbl_ios_gc_achievements_show();
void dd_pbl_ios_gc_achievements_report(const char * name, float value); // value from 0 to 1
void dd_pbl_ios_gc_achievements_reset();

// -------------------------------------- FaceBook

/*
integration notes

1) add FacebookAppID string in bundle plist
2) add dd_pbl_ios_fb_app_become_active and dd_pbl_ios_fb_handle_url to application delegate
3) make sure return YES in delegate if dd_pbl_ios_fb_handle_url return YES (so app handle url)
4) if dd_pbl_ios_fb_is_aviable == -2 call dd_pbl_ios_fb_init
5) if dd_pbl_ios_fb_is_aviable == 0 call dd_pbl_ios_fb_auth
6) do anything only after dd_pbl_ios_fb_is_aviable > 0
*/

void dd_pbl_ios_fb_init();
int8_t dd_pbl_ios_fb_is_aviable(); // > 0 then ok, if == 0 then not auth, if == -1 then waiting for result, if == -2 then not aviable
void dd_pbl_ios_fb_auth();
void dd_pbl_ios_fb_logout();

void dd_pbl_ios_fb_app_become_active();
bool dd_pbl_ios_fb_handle_url(void * url, void * source_app); // actually its NSURL* and NSString*, use it in handleOpenURL and openURL

uint64_t dd_pbl_ios_fb_user_id();
const char * dd_pbl_ios_fb_user_name();

uint32_t dd_pbl_ios_fb_friends_count();
uint64_t dd_pbl_ios_fb_friend_id(uint32_t index);
const char * dd_pbl_ios_fb_friend_user_name(uint32_t index);

void dd_pbl_ios_fb_publish_feed(const char * name, const char * caption, const char * descr, const char * link, const char * picture); // can accept NULL

void dd_pbl_ios_fb_invite_friends(const char * message);

// -------------------------------------- Push Notifications

/*
integration notes
 
1) dd_pbl_ios_push_add accept seconds from now
2) call dd_pbl_ios_push_clear_badges for clean badges count
*/

int32_t dd_pbl_ios_push_add(const char * text, uint32_t seconds);
bool dd_pbl_ios_push_remove(int32_t push_id); // if < 0 then remove all
void dd_pbl_ios_push_clear_badges();

// -------------------------------------- Reachability

bool dd_pbl_ios_reachability_is_wan_aviable();

// -------------------------------------- Localytics

void dd_pbl_ios_localytics_session_start(const char * key);
void dd_pbl_ios_localytics_session_end();
void dd_pbl_ios_localytics_session_resume();
void dd_pbl_ios_localytics_track_event(const char * name, size_t attributes_count, const char ** parameters, const char ** values, uint32_t customer_value_increase);
void dd_pbl_ios_localytics_track_screen(const char * name);

// -------------------------------------- TestFlight

void dd_pbl_ios_testflight_session_start(const char * key);
void dd_pbl_ios_testflight_pass_checkpoint(const char * checkpoint_name);
void dd_pbl_ios_testflight_submit_feedback(const char * feedback);

// -------------------------------------- ADX

void dd_pbl_ios_adx_session_start(const char * client_id, const char * apple_id, const char * url_scheme);
void dd_pbl_ios_adx_track_event(const char * name, const char * data, const char * currency, const char * custom_data); // data, currency and custom_data can be null
void dd_pbl_ios_adx_handle_url(void * url); // actually its NSURL*, use it in handleOpenURL and openURL

// ------------------------------------------------------------------------------------------- Android

#ifdef __cplusplus
}
#endif


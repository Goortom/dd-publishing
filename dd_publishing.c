// DD Publishing Lib

#include "dd_publishing.h"

// ------------------------------------------------------------------------------------------- iOS

// -------------------------------------- In-App Purchse

#ifndef DD_PBL_IOS_IAP

void dd_pbl_ios_iap_buy(const char * name) {}
void dd_pbl_ios_iap_restore() {}

bool dd_pbl_ios_iap_is_bought(const char * name) {return false;}
bool dd_pbl_ios_iap_can_consume(const char * name) {return false;}
bool dd_pbl_ios_iap_consume(const char * name, uint32_t count) {return false;}

#endif

// -------------------------------------- Game Center

#ifndef DD_PBL_IOS_GC

void dd_pbl_ios_gc_set_preset_viewcontroller(dd_pbl_ios_gc_present_viewcontroller_callback callback) {}

int8_t dd_pbl_ios_gc_is_aviable() {return -2;} // > 0 then ok, if == 0 then not auth, if == -1 then waiting for result, if == -2 then not aviable
void dd_pbl_ios_gc_auth() {}

const char * dd_pbl_ios_gc_user_id() {return 0;}
const char * dd_pbl_ios_gc_user_name() {return "";}

uint32_t dd_pbl_ios_gc_friends_count() {return 0;}
const char * dd_pbl_ios_gc_friend_id(uint32_t index) {return 0;}
const char * dd_pbl_ios_gc_friend_user_name(uint32_t index) {return "";}

uint64_t dd_pbl_ios_gc_unsafe_id_to_uint64_t(const char * user_id) {return 0;} // unsafe method to convert string id to uint64_t, no guarantee

void dd_pbl_ios_gc_scores_retrieve(const char * name) {}
int8_t dd_pbl_ios_gc_scores_retrieve_status() {return -1;}
int64_t dd_pbl_ios_gc_score(uint32_t index) {return 0;}
const char * dd_pbl_ios_gc_score_user_id(uint32_t index) {return "";}
const char * dd_pbl_ios_gc_score_user_name(uint32_t index) {return "";}

void dd_pbl_ios_gc_leaderboard_show(const char * name) {}
void dd_pbl_ios_gc_leaderboard_report(const char * name, uint32_t value) {}

void dd_pbl_ios_gc_achievements_show() {}
void dd_pbl_ios_gc_achievements_report(const char * name, float value) {} // value from 0 to 1
void dd_pbl_ios_gc_achievements_reset() {}


#endif

// -------------------------------------- FaceBook

#ifndef DD_PBL_IOS_FB

void dd_pbl_ios_fb_init() {}
int8_t dd_pbl_ios_fb_is_aviable() {return -2;} // > 0 then ok, if == 0 then not auth, if == -1 then waiting for result, if == -2 then not aviable
void dd_pbl_ios_fb_auth() {}
void dd_pbl_ios_fb_logout() {}

void dd_pbl_ios_fb_app_become_active() {}
bool dd_pbl_ios_fb_handle_url(void * url, void * source_app) {return false;} // actually its NSURL* and NSString*, use it in handleOpenURL and openURL

uint64_t dd_pbl_ios_fb_user_id() {return 0;}
const char * dd_pbl_ios_fb_user_name() {return "";}

uint32_t dd_pbl_ios_fb_friends_count() {return 0;}
uint64_t dd_pbl_ios_fb_friend_id(uint32_t index) {return 0;}
const char * dd_pbl_ios_fb_friend_user_name(uint32_t index) {return "";}

void dd_pbl_ios_fb_publish_feed(const char * name, const char * caption, const char * descr, const char * link, const char * picture) {}

void dd_pbl_ios_fb_invite_friends(const char * message) {}

int8_t dd_pbl_ios_fb_avatars_is_aviable() {return -1;}
uint8_t * dd_pbl_ios_fb_avatars_bitmap() {return 0;}
uint16_t dd_pbl_ios_fb_avatars_bitmap_width() {return 256;}
uint16_t dd_pbl_ios_fb_avatars_bitmap_height() {return 256;}
uint16_t dd_pbl_ios_fb_avatars_width() {return 32;}
uint16_t dd_pbl_ios_fb_avatars_height() {return 32;}

#endif

// -------------------------------------- Push Notifications

#ifndef DD_PBL_IOS_PUSH_NOTIF

int32_t dd_pbl_ios_push_add(const char * text, uint32_t seconds) {return -1;}
bool dd_pbl_ios_push_remove(int32_t push_id) {return false;} // if < 0 then remove all
void dd_pbl_ios_push_clear_badges() {}

#endif

// -------------------------------------- Reachability

#ifndef DD_PBL_IOS_REACHABILITY

bool dd_pbl_ios_reachability_is_wan_aviable() {return true;}

#endif

// -------------------------------------- Localytics

#ifndef DD_PBL_IOS_LOCALYTICS

void dd_pbl_ios_localytics_session_start(const char * key) {}
void dd_pbl_ios_localytics_session_end() {}
void dd_pbl_ios_localytics_session_resume() {}
void dd_pbl_ios_localytics_track_event(const char * name, uint16_t attributes_count, const char ** parameters, const char ** values, uint32_t customer_value_increase) {}
void dd_pbl_ios_localytics_track_screen(const char * name) {}

#endif

// -------------------------------------- TestFlight

#ifndef DD_PBL_IOS_TESTFLIGHT

void dd_pbl_ios_testflight_session_start(const char * key) {}
void dd_pbl_ios_testflight_pass_checkpoint(const char * checkpoint_name) {}
void dd_pbl_ios_testflight_submit_feedback(const char * feedback) {}

#endif

// -------------------------------------- ADX

#ifndef DD_PBL_IOS_ADX

void dd_pbl_ios_adx_session_start(const char * client_id, const char * apple_id, const char * url_scheme) {}
void dd_pbl_ios_adx_track_event(const char * name, const char * data, const char * currency, const char * custom_data) {} // data, currency and custom_data can be null
void dd_pbl_ios_adx_handle_url(void * url) {}

#endif

// -------------------------------------- Chartboost

#ifndef DD_PBL_IOS_CHARTBOOST

void dd_pbl_ios_chartboost_start(const char * app_id, const char * app_signature) {}
void dd_pbl_ios_chartboost_show_interstitial() {}

#endif

// -------------------------------------- Tapjoy

#ifndef DD_PBL_IOS_TAPJOY

void dd_pbl_ios_tapjoy_start(const char * app_id, const char * secret_key) {}
void dd_pbl_ios_tapjoy_show_offers(void * viewcontroller) {}
void dd_pbl_ios_tapjoy_request_points() {}
int8_t dd_pbl_ios_tapjoy_is_points_aviable() {return -1;}
uint32_t dd_pbl_ios_tapjoy_get_points() {return 0;}
void dd_pbl_ios_tapjoy_spend_points(uint32_t count) {}

#endif

// ------------------------------------------------------------------------------------------- Android


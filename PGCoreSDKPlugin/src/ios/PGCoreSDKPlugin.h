#import <Cordova/CDV.h>
#import "PGAgent.h"
#import "Constants.h"


#define ADSUPPORT_INTEGRATION  1;
//#define ENABLE_BACKGROUND_FETCH  1;

typedef int JSSensorState;

@interface PGCoreSDKPlugin : CDVPlugin

/**
 Configures the PgCorePlugin.
 @param app_key the api key you receive from partner portal
 @param app_sensor_state set the initial sensor state
 @param sensors, pass on the sensors value that your want to enable or disable. values are "app", "facebook", "loaction"
 */
-(void) init:(CDVInvokedUrlCommand*)command;

/**
 Returns the PgCorePlugin inline SDK(PGAgent) version.
 */
-(void) getSDKVersion:(CDVInvokedUrlCommand*)command;

/**
 sets the sensor state to ON/OFF.
 @param sensor_name, expect any one of the predefined sensor name. like "app", "facebook", "location"
 @param enable
 */
-(void) sensor:(CDVInvokedUrlCommand*)command;

/**
 sets the facebook token.
 @param JSON object with two key value pairs, fbtoken & permissions
 */
-(void) shareFBToken:(CDVInvokedUrlCommand*)command;

/**
 sets the facebook token.
 @param JSON object with single key value pairs, sensor_name with any predefined value from "app", "facebook", "location"
 */
-(void) sensorState:(CDVInvokedUrlCommand*)command;

/**
 Returns the PgCorePlugin inline SDK(App key) generated at partner portal.
 */
-(void) getAPIKey:(CDVInvokedUrlCommand*)command;

/**
 sets the facebook token.
 @param JSON object with single key value pairs, info_log_status & BOOL value for it. To enable or disable logs
 */
-(void) setInfoLogStatus:(CDVInvokedUrlCommand*)command;

/**
 capture the event.
 @param JSON object with two key-value pair, first key(event) value(event name) is mandatory, second key(parameter) value(JSON object) is optional.
 */
-(void) logEvent:(CDVInvokedUrlCommand*)command;

/**
 capture the timed event.
 @param JSON object with two key-value pair, first key(event) value(event name) is mandatory, second key(parameter) value(JSON object) is optional.
 */
-(void) logTimedEvent:(CDVInvokedUrlCommand*)command;

/**
 ends the timed event.
 @param JSON object with two key-value pair, first key(event) value(event name) is mandatory, second key(parameter) value(JSON object) is optional.
 */
-(void) endTimedEvent:(CDVInvokedUrlCommand*)command;


/**
 Share userID with PGCoreSDK.
 @param JSON object with single key value pairs, external_user_id as key & its value as string
 */
-(void) shareExternalUserId:(CDVInvokedUrlCommand*)command;

/**
 capture the timed event.
 @param JSON object with two key-value pair, first key(event) value(event name) is mandatory, second key(parameter) value(JSON object) is optional.
 */

/**
 These two methods are no more supported in iOS latest SDK.
 */
-(void) startSession:(CDVInvokedUrlCommand*)command;
-(void) endSession:(CDVInvokedUrlCommand*)command;



@end

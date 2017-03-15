/**
 *  @file PGAgent.h
 *  TradewindStaticLibrary
 *  @brief A class to represent the infrastructure of a PGAgent SDK
 *
 *  @author Created by Personagraph on 11/01/12.
 *  Copyright (c) 2012, 2013 Intertrust. All rights reserved.
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#ifndef __PGAgent_H__
#define __PGAgent_H__


/**
 enum defines the error codes associated with this module.
 */

typedef NS_OPTIONS(NSUInteger, PGErrorType)
{
    PGErrorInvalidSensor = 1000,
    PGErrorSensorNotIncorporated=1001,
    PGErrorSensorNotActive=1002, //if sensor:enable is called even before the sensors are created
};

/**
 enum defines the different states associated with the sensors.
 */
typedef NS_OPTIONS(NSUInteger, PGSensorState)
{
    PGSensorStateNotAvailable,  /* The sensor is not incorporated into the SDK */
    PGSensorStateDisable,       /* The sensor is disabled in the SDK*/
    PGSensorStateEnable,        /* The sensor is enabled in the SDK */
};


/**
 PGErrorDomain is the error domain used in the NSErrors associated with this module.
 */
extern NSString *const PGErrorDomain;

/**
 Constant to name the facebook sensor. Used in setAPPKey:sdkSettings:, sensorState: & sensor:enable:completionBlock
 */
extern NSString *const PGSensorFacebook;

/**
 Constant to name the Location sensor. Used in setAPPKey:sdkSettings:, sensorState: & sensor:enable:completionBlock
 */
extern NSString *const PGSensorLocation;


/**
 PGSettings class represents the default options passed to the SDK during the configuraton process.
 */
@interface PGSettings : NSObject
{
    
}

+ (PGSettings *)defaultSettings;

/**
 @description This is the launchOptions paramter of application:didFinishLaunchingWithOptions:.
 
 @param launchOptions  is a dictionary indicating the reason the app was launched.
 */
@property (nonatomic)NSDictionary *launchOptions;

/**
 @description This sets the distinct ID to the current user. The Advertising Identifier(IDFA) is the optional parameter passed to the SDK by partner.
 If this value is not set, then we use the  IDFV <code>[UIDevice currentDevice].identifierForVendor</code> as the default distinct ID.
 The IDFV will identify a user across all apps by the same vendor, but cannot be used to link the same user across apps from different
 vendors.
 If your app is displaying ads then you are allowed to use Advertising Identifier to identify users.
 
 @param idfa string that uniquely identifies the current user
 */
@property (nonatomic)NSString *idfa;

/**
 The the array of sensors to be tracked by SDK. eg: @[PGSensorVisits] to track user visited locations.
 @discussion Refer PGAgent class for list of available sensors
 */
@property (nonatomic, strong)NSArray *pgSensors;

/**
 Enables (or disables) the PGSDK sensors.
 If you plan to incorporate the PGSDK sensors to your mobile app, you must enable or disable the sensor with setAppSensorState: method call before invoking application:didFinishLaunchingWithOptions: on PGSDKAgent class. Please note that turning on PGSDK sensors helps in improving PGSDKAgent' platform in generating inferences for your mobile users.
 
 What happens when you turn the PG Sensor on?
 The PGSDKAgent collects usage and data to infer user interests, behavioral and demographic information. These inferences provide valuable insights into your users, and enrich the overall understanding of your users when combined with the additional signal sources.
 
 What happens when you turn the PG Sensor off?
 By switching the PGSDK sensors off, the ability to infer demographic, behavioral, and interest information is diminished.
 
 Our Recommendation:
 We recommend that you inform your users about the Sensor’s data collection if you decide to turn the PG Sensor On.
 
 Failing to call this method would raise the PGRuntimeInconsistencyException exception at the runtime.
 @param sensors can be either PGSensorStateEnable, PGSensorStateDisable or PGSensorStateNotAvailable.
 */
@property (nonatomic)PGSensorState pgSensorState;



/*!
 *  @brief Debug information to configure the runtime behaviour of SDK
 *  @since 2.3.0
 *
 *  @note This method is used to test the SDK beghaviour. Do not use this in production.
 *
 *  @param none.
 */

@property (nonatomic)NSDictionary *debugInfo;

/*!
 *  @brief Controls the Limit Ad Tracking behavior in the SDK
 *  @since 2.3.1
 *
 *  @note If YES then overides the Limit ad tracking value set by user in settings app and ignores the value. The default value is set to NO.
 *
 *  @param none.
 */

@property (nonatomic,assign)BOOL shouldIgnoreLimitAdTracking;

/*!
 *  @brief Controls the sensor information to server
 *  @since 2.4.1
 *
 *  @note If YES then overides the shouldPushSensorInformation value set by user in settings app and ignores the value. The default value is set to YES.
 *
 *  @param none.
 */

@property (nonatomic,assign)BOOL shouldPushSensorInformation;

@end


/**
 PGAgent class to configure and provide the basic infrastructure for the PGAgent SDK.
 The PGAgent iOS SDK enables PGAgent partners to easily incorporate PGAgent technology into an iOS application.
 This integration provides the partner with insights into their users demographics, interests and activity not easily available before. 
 */
@interface PGAgent : NSObject
{
}

#pragma mark
#pragma mark Initializing PGAgent
/**---------------------------------------------------------------------------------------
 * @name Initialization Methods
 *  ---------------------------------------------------------------------------------------
 */

/**
 Get the current version of the SDK.
 @returns a version string in MajorVersion .[dot] MinorVersion .[dot] Build_Number For Eg. 1.0.23
 */
+ (NSString *)sdkVersion;


/**
 Configures the PGAgent SDK.
 @param appKey the app key you receive from PGAgent
 @param settings the settings to be passed during configuration. Refer PGSettings class for configuration options.
 */
+ (void)setAPPKey : (NSString *) appKey  sdkSettings:(PGSettings *)settings;



 /*!
 * @brief Configures the PGAgent SDK with Partner App key.
 * @param appKey the app key you receive from PGAgent
 * @param settings the settings to be passed during configuration. Refer PGSettings class for configuration options.
 * @since 2.3.0
 * @note This API is used only by the Ad partners.
 */

+ (void)setPartnerAppKey : (NSString *) apiKey  sdkSettings:(PGSettings *)settings;



/**
 Retrieves the APP Key used in the SDK.
 @returns APP Key used in the SDK.
 */
+ (NSString *)getAPPKey;

/**
 Retrieves configured sensors  in the SDK.
 @returns List of sensors configured in the SDK.
 */
+ (NSArray *)getConfigurationSesnors;

/*!
 *  @brief Generates debug logs to console. This is an optional method that displays debug information related to the Personagraph SDK. The default setting for this method is NO
 *  @since 1.10.1
 *
 *  @param value YES to show debug logs, NO to omit debug logs.
 *
 */
+ (void)setDebugLogEnabled:(BOOL)value;

/*!
 *  @brief enable delegate.
 *
 */
+ (void)setDelegate:(id)obj;

/*!
 *  @brief Assign a unique id for a user in your app.
 *  @since 1.11.0
 *
 *  @note Please be sure not to use this method to pass any private or confidential information
 *  about the user.
 *
 *  @param userID The app id for a user.
 */

+ (void)shareExternalUserId:(NSString *)userID;

/*!
 *  @brief Prints the feedback to the console.
 *  @since 2.1.0
 *
 *  @note This API is used to check the status of the SDK at any given point of time.
 *
 */
+ (void)showFeedback;

#pragma mark
#pragma mark Sensor Management
/**---------------------------------------------------------------------------------------
 * @name Sensor State Methods
 *  ---------------------------------------------------------------------------------------
 */

/**
 Enables (or disables) the specified sensor.
 @param sensorName The "name" of the sensor in question.  Valid values currently are described above.
 @param state BOOL which indicates whether the sensor should be enabled (YES) or disabled (NO).
 @param data optional parameter.
 @param completionBlock Used to communicate error conditions.  Pass nil if you have no interest in errors.
 @return Indicates success/failure.  If the method fails utilize error argument to determine nature of failure.
 */
+ (void) sensor : (NSString *) sensorName enable:(BOOL)state data:(id)data completionBlock:(void(^)(BOOL success, NSError *error))completionBlock;


/**
 Returns returns the state of the specified sensor. 
 @param sensor The "name" of the sensor in question.  Valid values currently are as described above.
 @return Indicates whether or not the sensor in question is incorporated, enabled or disabled in the SDK.
 */
+ (PGSensorState)sensorState:(NSString *)sensor;


#pragma mark
#pragma mark Share Social Tokens
/**---------------------------------------------------------------------------------------
 * @name Share Facebook Token
 *  ---------------------------------------------------------------------------------------
 */

/**
  Share Facebook Token and its Permissions with Personagraph Servers.
  @param accessToken fbToken extracted from current Active FBSession
  @param permissions Array of permissions requested in Active FBSession
  */
+ (void)shareFBToken:(NSString *)accessToken andPermissions:(NSArray *)permissions;

#pragma mark
#pragma mark ApplicationDelegate Methods

/**---------------------------------------------------------------------------------------
 * @name application:performFetchWithCompletionHandler:
 *  ---------------------------------------------------------------------------------------
 
 Called by the app to perform background fetch: typically to gather sensor information in regular intervals
 @param application obtained from [UIApplication sharedApplication]
 @param completionHandler completion handler block to passed. Completion handler will be invoked when the background task is completed
 @discussion Invoke this API only in application:performFetchWithCompletionHandler: which is available only for iOS 7.0 and above. PGAgent will invoke completionHandler when the background task is completed or 25 seconds have already elapsed.
 */

+ (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

#pragma mark
#pragma mark Event Analytics
/**---------------------------------------------------------------------------------------
 * @name Event Analytics
 * Event analytics is a way to help you derive about how the usage patterns, and much more insights of your applications and gain some insights from reports generate in PGAgent Partner portal
 *---------------------------------------------------------------------------------------
 */

/**
 Record the Event with given custom event name
 @param eventName name of the event. Give a name which has contextual meaning, for example PLAY_VIDEO_ACTION, so that you can obtain meaningful insights from the reports generated in PGAgent Partner Portal
 */
+ (void)logEvent:(NSString *)eventName;

/**
 Record the Event with given custom event name, with options to supply few contextual parameters that relate to the event
 @param eventName name of the event. Give a name which has contextual meaning, for example PLAY_VIDEO_ACTION, so that you can obtain meaningful insights from the reports generated in PGAgent Partner Portal
 @param contextParameters A dictionary with the key/value pairs where you can put additional contextual parameters related to the event.
 @note contextParameters can only accept maximum of 10 key value pairs.
 For Example, In for Event PLAY_VIDEO_ACTION, parameters would be
  { MOVIE : <NAME_OF_MOVIE_PLAYING> }. This will enable you to know how many movies were played and what movies were played the most.
 */
+ (void)logEvent:(NSString *)eventName withParameters:(NSDictionary *)contextParameters;

/**
 Start the Timed Event.
 @param eventName name of the event. Give a name which has contextual meaning, for example PLAY_VIDEO_ACTION, so that you can obtain meaningful insights from the reports generated in PGAgent Partner Portal
 
 @note Timed events are useful when we want to find out the duration a particular event. Please note that the timed events are symmetric, which means every logTimedEvent: call must have a corresponding endTimedEvent:withParameters: call in order to complete the event. If the eventName is already started, then start time would be replaced by the current time.
 For Example, start the timed event MOVE_PLAY_DURATION, to find out how long the movie was watched.
 */
+ (void)logTimedEvent:(NSString *)eventName;

/**
 End the Timed Event.
 @param eventName name of the event. Give a name which has contextual meaning, for example PLAY_VIDEO_ACTION, so that you can obtain meaningful insights from the reports generated in PGAgent Partner Portal
 @param contextParameters A dictionary with the key/value pairs where you can put additional contextual parameters related to the event.
 @note contextParameters can only accept maximum of 10 key value pairs.
 @note Timed events are useful when we want to find out the duration a particular event. Please note that the timed events are symmetric, which means every logTimedEvent: call must have a corresponding endTimedEvent:withParameters: call in order to complete the event. If the eventName is already started, then start time would be replaced by the current time. However, calling endTimedEvent:withParameters: without its corresponding logTimedEvent: will result in NSInternalInconsistencyException.
 
 For Example, start the timed event MOVE_PLAY_DURATION, to find out how long the movie was watched.
 */
+ (void)endTimedEvent:(NSString *)eventName withParameters:(NSDictionary *)contextParameters;

@end

#endif

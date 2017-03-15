#import "PGCoreSDKPlugin.h"
#import "AppDelegate.h"

#ifdef ADSUPPORT_INTEGRATION
#import <AdSupport/AdSupport.h>
#endif


//logs when debug mode is enabled
# define DEBUG 1
#ifdef DEBUG
#   define DLog(fmt, ...)\
if (isLoggingEnabled)\
NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

@implementation AppDelegate(PgCorePlugin)

#ifdef ENABLE_BACKGROUND_FETCH
-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    [PGAgent application:application performFetchWithCompletionHandler:^(UIBackgroundFetchResult result) {
        completionHandler(result);
    }];
}
#endif

@end

@implementation PGCoreSDKPlugin
{
    BOOL isLoggingEnabled;
    NSDictionary *sensorsMap;
}

-(void)initPgCorePlugin
{
    sensorsMap = @{JS_SENSOR_VALUE_FB:PGSensorFacebook,
                   JS_SENSOR_VALUE_LOCATION:PGSensorLocation};
}

-(NSDictionary*)verifyArguments:(CDVInvokedUrlCommand*)command
{
    NSDictionary* arguments = nil;
    
    if ([command.arguments count] > 0) {
        if ([[command.arguments objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
            arguments = [command.arguments objectAtIndex:0];
        }else{
            DLog(@"%@",@"Expected a JSON object");
        }
    }
    if (!arguments) {
        NSString *payload = [NSString stringWithFormat:@"expected argument not passed, please check the documentation"];
        DLog(@"[Argument error: ]%@",payload);
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:payload];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    return arguments;
}

- (void)init:(CDVInvokedUrlCommand*)command {
    isLoggingEnabled = NO;
    [self initPgCorePlugin];
    
    DLog(@"%@",command.arguments);
    
    __block NSDictionary* arguments = [self verifyArguments:command];
    
    if (arguments) {
        [self.commandDelegate runInBackground:^{
            NSString* payload = nil;
            CDVPluginResult* pluginResult = nil;
            @try {
                PGSettings *settings = [PGSettings defaultSettings];
                settings.launchOptions = arguments;
                
#ifdef ADSUPPORT_INTEGRATION
                if (NSClassFromString(@"ASIdentifierManager") != Nil) {
                    settings.idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]; //enable the MACRO in header file if your app is displaying ads
                }
#endif
                PGSensorState pgCoreSensorState = PGSensorStateNotAvailable;
                if([[arguments objectForKey:JS_SENSOR_STATE_KEY] intValue] == 1){
                    pgCoreSensorState = PGSensorStateEnable;
                }else if([[arguments objectForKey:JS_SENSOR_STATE_KEY] intValue] == 0){
                    pgCoreSensorState = PGSensorStateDisable;
                }
                settings.pgSensorState = pgCoreSensorState;
                
                NSMutableArray *sensorsEnabledArr = [[NSMutableArray alloc] init];
                for (NSString* sensorName in [arguments objectForKey:JS_SENSOR_KEY]) {
                    if ([sensorName isEqualToString:JS_SENSOR_VALUE_FB] || [sensorName isEqualToString:JS_SENSOR_VALUE_LOCATION]) {
                        NSString *sensorStr = [sensorsMap objectForKey:sensorName];
                        [sensorsEnabledArr addObject:sensorStr];
                    }
                }
                settings.pgSensors = sensorsEnabledArr;
                
                //[PGAgent setDebugLogEnabled:NO]; //Default value is off
                
                [PGAgent setAPPKey:[arguments objectForKey:JS_IOS_APP_KEY] sdkSettings:settings];
                payload = @"SDK initialisation successful";
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:payload];
            }
            @catch (NSException *exception) {
                // deal with the exception
                payload = [NSString stringWithFormat:@"Exception occured: info: name= %@\n reason= %@ \nmoreInfo= %@",exception.name,exception.reason,exception.userInfo];
                DLog(@"[Exception Occured]%@",payload);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:payload];
                
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }
}

-(void) getSDKVersion:(CDVInvokedUrlCommand*)command {
    
    DLog(@"%@",command.arguments);
    [self.commandDelegate runInBackground:^{
        
        NSString *sdkVersion = [PGAgent sdkVersion];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:sdkVersion];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

-(void) changeSensor:(NSString*)PGSensorName toState:(BOOL)sensorState withData:(id)sensorData andCallbackId:(NSString *)callbackId
{
    __block CDVPluginResult* pluginResult = nil;
    DLog(@"%@",PGSensorName);
    [PGAgent sensor:PGSensorName enable:sensorState data:nil completionBlock:^(BOOL success, NSError *error) {
        if (success) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:success];
        }else{
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error description]];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    }];
}

-(void) sensor:(CDVInvokedUrlCommand*)command {
    
    DLog(@"%@",command.arguments);
    
    __block NSDictionary* arguments = [self verifyArguments:command];
    
    if (arguments) {
        @try {
            [self.commandDelegate runInBackground:^{
                
                BOOL sensorState = [[arguments valueForKey:JS_SENSOR_ENABLE_KEY] boolValue];
                NSString *sensorStr = [sensorsMap objectForKey:[arguments valueForKey:JS_SENSOR_SPECIFIC_KEY]];
                [self changeSensor:sensorStr toState:sensorState withData:nil andCallbackId:command.callbackId];
            }];
        }@catch (NSException *exception) {
            NSString *payload = [NSString stringWithFormat:@"Exception occured: info: name= %@\n reason= %@ \nmoreInfo= %@",exception.name,exception.reason,exception.userInfo];
            DLog(@"[Exception Occured]%@",payload);
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:payload];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }
}

-(void) startSession:(CDVInvokedUrlCommand*)command {
    
    DLog(@"%@",command.arguments);
    
    [self.commandDelegate runInBackground:^{
        
        NSString *sdkVersion = [PGAgent sdkVersion];
        NSString *resultStr = [@"This method is no more used in SDK version" stringByAppendingString:sdkVersion];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:resultStr];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

-(void) endSession:(CDVInvokedUrlCommand*)command {
    
    DLog(@"%@",command.arguments);
    
    [self.commandDelegate runInBackground:^{
        
        NSString *sdkVersion = [PGAgent sdkVersion];
        NSString *resultStr = [@"This method is no more used in SDK version" stringByAppendingString:sdkVersion];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:resultStr];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

-(void) shareFBToken:(CDVInvokedUrlCommand*)command {
    
    DLog(@"%@",command.arguments);
    
    __block NSDictionary* arguments = [self verifyArguments:command];
    
    if (arguments) {
        [self.commandDelegate runInBackground:^{
            CDVPluginResult* pluginResult = nil;
            @try {
                NSString *fbTokenStr = [arguments objectForKey:JS_FB_TOKEN];
                NSArray *fbPermissionArr = nil;
                if ([[arguments objectForKey:JS_FB_PERMISSION] isKindOfClass:[NSArray class]]) {
                    fbPermissionArr = [arguments objectForKey:JS_FB_PERMISSION];
                }else{
                    NSException* fbException = [NSException exceptionWithName:@"FB-permissions"
                                                                       reason:@"permission object is inappropiate"
                                                                     userInfo:@{@"info":@"Expected a array of permission strings",
                                                                                @"example":@"['public_profile','publish_actions','user_friends']"
                                                                                }];
                    @throw fbException;
                }
                
                [PGAgent shareFBToken:fbTokenStr andPermissions:fbPermissionArr];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
            }@catch(NSException *exception){
                NSString *payload = [NSString stringWithFormat:@"Exception occured: info: name= %@\n reason= %@ \nmoreInfo= %@",exception.name,exception.reason,exception.userInfo];
                DLog(@"[Exception Occured]%@",payload);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:payload];
                
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }
}

-(void) sensorState:(CDVInvokedUrlCommand*)command {
    
    DLog(@"%@",command.arguments);
    
    __block NSDictionary* arguments = [self verifyArguments:command];
    
    if (arguments) {
        [self.commandDelegate runInBackground:^{
            CDVPluginResult* pluginResult = nil;
            NSMutableDictionary *sensorStateDict = [NSMutableDictionary dictionary];
            NSMutableArray *sensorsStateArr = [NSMutableArray array];
            @try {
                PGSensorState sensorState = PGSensorStateNotAvailable;
                for (NSString *sensorName in [arguments valueForKey:JS_SENSOR_SPECIFIC_KEY]) {
                    sensorStateDict = [NSMutableDictionary dictionary];
                    NSString *sensorStr = [sensorsMap objectForKey:sensorName];
                    
                    sensorState = [PGAgent sensorState:sensorStr];
                    JSSensorState jsSensorState = sensorState - 1;
                    DLog(@"sensorName= %@ and sensorState= %d",[arguments valueForKey:JS_SENSOR_SPECIFIC_KEY],jsSensorState);
                    
                    [sensorStateDict setObject:sensorName forKey:@"name"];
                    [sensorStateDict setObject:[NSNumber numberWithInt:jsSensorState] forKey:@"value"];
                    [sensorsStateArr addObject:sensorStateDict];
                }
                //NSString *sensorStr = [sensorsMap objectForKey:[arguments valueForKey:JS_SENSOR_SPECIFIC_KEY]];
                //sensorState = [PGAgent sensorState:sensorStr];
                //JSSensorState jsSensorState = sensorState - 1;
                
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:sensorsStateArr];
            }@catch(NSException *exception){
                NSString *payload = [NSString stringWithFormat:@"Exception occured: info: name= %@\n reason= %@ \nmoreInfo= %@",exception.name,exception.reason,exception.userInfo];
                DLog(@"[Exception Occured]%@",payload);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:payload];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
        
    }
}

-(void) getAPIKey:(CDVInvokedUrlCommand*)command {
    
    DLog(@"%@",command.arguments);
    
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[PGAgent getAPPKey]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

-(void)shareExternalUserId:(CDVInvokedUrlCommand*)command{
    DLog(@"%@",command.arguments);
    __block NSDictionary* arguments = [self verifyArguments:command];
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        @try {
            id exterUserId = [arguments valueForKey:JS_EXTERNAL_USER_ID];
            
            if ([exterUserId isKindOfClass:[NSString class]]) {
                [PGAgent shareExternalUserId:exterUserId];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }else{
                DLog(@"%@",@"Expected a string value for userid");
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            }
        }
        @catch (NSException *exception) {
            NSString* exceptionString = [NSString stringWithFormat:@"Exception occured: info: name= %@\n reason= %@ \nmoreInfo= %@",exception.name,exception.reason,exception.userInfo];
            DLog(@"[Exception Occured]%@",exceptionString);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exceptionString];
        }
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
    
}

-(NSString*)jsonString:(id)objcDict
{
    NSString *jsonString = nil;
    @try {
        NSDictionary *jsonObjcDict = nil;
        NSError *error = nil;
        if ([objcDict isKindOfClass:[NSArray class]]) {
            jsonObjcDict = @{@"response":objcDict};
        }else if([objcDict isKindOfClass:[NSDictionary class]]){
            jsonObjcDict = objcDict;
        }
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObjcDict options:0 error:&error];
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    @catch (NSException *exception) {
        NSString* exceptionString = [NSString stringWithFormat:@"Exception occured: info: name= %@\n reason= %@ \nmoreInfo= %@",exception.name,exception.reason,exception.userInfo];
        DLog(@"[Exception Occured]%@",exceptionString);
    }
    return jsonString;
}

-(void) setInfoLogStatus:(CDVInvokedUrlCommand*)command {
    
    DLog(@"%@",command.arguments);
    
    __block NSDictionary* arguments = [self verifyArguments:command];
    
    if (arguments) {
        [self.commandDelegate runInBackground:^{
            CDVPluginResult* pluginResult = nil;
            NSString *resultString = nil;
            @try {
                isLoggingEnabled = [[arguments valueForKey:JS_LOG_ENABLE_KEY] boolValue];
                resultString = @"logging state changed";
                
                [PGAgent setDebugLogEnabled:isLoggingEnabled];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:resultString];
                
            }@catch(NSException *exception){
                resultString = [NSString stringWithFormat:@"Exception occured: info: name= %@\n reason= %@ \nmoreInfo= %@",exception.name,exception.reason,exception.userInfo];
                DLog(@"[Exception Occured]%@",resultString);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:resultString];
                
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }
}

-(void) logEvent:(CDVInvokedUrlCommand*)command {
    
    DLog(@"%@",command.arguments);
    
    __block NSDictionary* arguments = [self verifyArguments:command];
    
    if (arguments) {
        [self.commandDelegate runInBackground:^{
            CDVPluginResult* pluginResult = nil;
            @try {
                id eventName = [arguments objectForKey:JS_LOGEVENT_KEY];
                if (![eventName isKindOfClass:[NSString class]]) {
                    NSException* dataTypeException = [NSException exceptionWithName:@"Datatype Exception"
                                                                             reason:@"parameter passed is inappropiate"
                                                                           userInfo:@{@"info":@"Expected a String value for key event"
                                                                                      }];
                    @throw dataTypeException;
                }
                if ([[arguments allKeys] count]>1) {
                    id eventParameters = [arguments objectForKey:JS_LOGEVENT_PARAMS];
                    if (![eventParameters isKindOfClass:[NSDictionary class]]) {
                        NSException* dataTypeException = [NSException exceptionWithName:@"Datatype Exception"
                                                                                 reason:@"parameter passed is inappropiate"
                                                                               userInfo:@{@"info":@"Expected a JSON object for key parameter"
                                                                                          }];
                        @throw dataTypeException;
                    }
                    [PGAgent logEvent:eventName withParameters:eventParameters];
                }else{
                    [PGAgent logEvent:eventName];
                }
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }@catch(NSException *exception){
                NSString *payload = [NSString stringWithFormat:@"Exception occured: info: name= %@\n reason= %@ \nmoreInfo= %@",exception.name,exception.reason,exception.userInfo];
                DLog(@"[Exception Occured]%@",payload);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:payload];
                
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }
}


-(void) logTimedEvent:(CDVInvokedUrlCommand*)command {
    
    DLog(@"%@",command.arguments);
    
    __block NSDictionary* arguments = [self verifyArguments:command];
    
    if (arguments) {
        [self.commandDelegate runInBackground:^{
            CDVPluginResult* pluginResult = nil;
            @try {
                id eventName = [arguments objectForKey:JS_LOGEVENT_KEY];
                if (![eventName isKindOfClass:[NSString class]]) {
                    NSException* dataTypeException = [NSException exceptionWithName:@"Datatype Exception"
                                                                             reason:@"parameter passed is inappropiate"
                                                                           userInfo:@{@"info":@"Expected a String value for key event"
                                                                                      }];
                    @throw dataTypeException;
                }
                if ([[arguments allKeys] count]>1) {
                    id eventParameters = [arguments objectForKey:JS_LOGEVENT_PARAMS];
                    if (![eventParameters isKindOfClass:[NSDictionary class]]) {
                        NSException* dataTypeException = [NSException exceptionWithName:@"Datatype Exception"
                                                                                 reason:@"parameter passed is inappropiate"
                                                                               userInfo:@{@"info":@"Expected a JSON object for key parameter"
                                                                                          }];
                        @throw dataTypeException;
                    }
                    [PGAgent logTimedEvent:eventName]; //check for update
                }else{
                    [PGAgent logTimedEvent:eventName];
                }
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }@catch(NSException *exception){
                NSString *payload = [NSString stringWithFormat:@"Exception occured: info: name= %@\n reason= %@ \nmoreInfo= %@",exception.name,exception.reason,exception.userInfo];
                DLog(@"[Exception Occured]%@",payload);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:payload];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }
}

-(void) endTimedEvent:(CDVInvokedUrlCommand*)command {
    
    DLog(@"%@",command.arguments);
    
    __block NSDictionary* arguments = [self verifyArguments:command];
    
    if (arguments) {
        [self.commandDelegate runInBackground:^{
            CDVPluginResult* pluginResult = nil;
            @try {
                id eventName = [arguments objectForKey:JS_LOGEVENT_KEY];
                if (![eventName isKindOfClass:[NSString class]]) {
                    NSException* dataTypeException = [NSException exceptionWithName:@"Datatype Exception"
                                                                             reason:@"parameter passed is inappropiate"
                                                                           userInfo:@{@"info":@"Expected a String value for key event"
                                                                                      }];
                    @throw dataTypeException;
                }
                if ([[arguments allKeys] count]>1) {
                    id eventParameters = [arguments objectForKey:JS_LOGEVENT_PARAMS];
                    if (![eventParameters isKindOfClass:[NSDictionary class]]) {
                        NSException* dataTypeException = [NSException exceptionWithName:@"Datatype Exception"
                                                                                 reason:@"parameter passed is inappropiate"
                                                                               userInfo:@{@"info":@"Expected a JSON object for key parameter"
                                                                                          }];
                        @throw dataTypeException;
                    }
                    [PGAgent endTimedEvent:eventName withParameters:eventParameters]; //check for update
                }else{
                    [PGAgent endTimedEvent:eventName withParameters:nil];
                }
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }@catch(NSException *exception){
                NSString *payload = [NSString stringWithFormat:@"Exception occured: info: name= %@\n reason= %@ \nmoreInfo= %@",exception.name,exception.reason,exception.userInfo];
                DLog(@"[Exception Occured]%@",payload);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:payload];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }
}

-(void)getIDFA:(CDVInvokedUrlCommand*)command {
    //__block NSDictionary* arguments = [self verifyArguments:command];
    NSString *ifdaStr = @"";
    if (NSClassFromString(@"ASIdentifierManager") != Nil) {
        ifdaStr = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
    [self.commandDelegate runInBackground:^{
        NSString* payload = ifdaStr;
        CDVPluginResult* pluginResult = nil;
        @try {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:payload];
        } @catch (NSException *exception) {
            payload = [NSString stringWithFormat:@"%@",exception.userInfo];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:payload];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end

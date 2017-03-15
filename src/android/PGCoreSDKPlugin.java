package com.pgcore.plugin;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

//Cordova imports
import org.apache.cordova.CordovaInterface; 
import org.apache.cordova.CallbackContext; 
import org.apache.cordova.CordovaPlugin; 
import org.apache.cordova.CordovaWebView;

//Android imports
import android.content.Context;
import android.app.Application;
import android.app.Activity;
import android.util.Log;

//Java Imports
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Iterator;

//PG Class Imports
import com.personagraph.api.PGAgent; 
import com.personagraph.api.PGSensorState;
import com.personagraph.api.PGSettings;
import com.personagraph.api.PGSourceType;

//pgcore import
import com.pgcore.plugin.PGCoreException;

/**
 * This class echoes a string called from JavaScript.
 */
public class PGCoreSDKPlugin extends CordovaPlugin {

    private Context context;
    private Application app;   
    private boolean enableLog;
    private Activity activity;
    //Sensor Name
    public static final String APP = "app";
    public static final String NONE = "none";
    public static final String LOCATION = "location";
    public static final String RUNNING_APPS = "running_apps";
    public static final String FACEBOOK = "facebook";
    public static final String INSTALLED_APPS = "installed_apps";
    
    //Sensor States
    public static final int SENSOR_STATE_NOT_AVAILABLE = -1;
    public static final int SENSOR_STATE_DISABLED = 0;
    public static final int SENSOR_STATE_ENABLED = 1;
    public static final String TAG = "PGCORE";
    private static final Map<String, Integer> sensorMap;
    static {
        sensorMap = new HashMap<String, Integer>();
        sensorMap.put(PGCoreSDKPlugin.NONE, PGAgent.NONE);
        sensorMap.put(PGCoreSDKPlugin.LOCATION, PGAgent.LOCATION);
        sensorMap.put(PGCoreSDKPlugin.RUNNING_APPS, PGAgent.RUNNING_APPS);
        sensorMap.put(PGCoreSDKPlugin.FACEBOOK, PGAgent.FACEBOOK);
        sensorMap.put(PGCoreSDKPlugin.INSTALLED_APPS, PGAgent.INSTALLED_APPS);
        
    }


    //Constructor function.
    public void initialize(CordovaInterface cordova, CordovaWebView webView) { 
        super.initialize(cordova, webView);
        context = this.cordova.getActivity().getApplicationContext();
        app = this.cordova.getActivity().getApplication(); 
        activity = this.cordova.getActivity();
        enableLog =  false; 
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        try {
            if ("init".equals(action)) {
                init(args,callbackContext);
            }else if("initWithPartnerKey".equals(action)){
                initWithPartnerKey(args, callbackContext);
            }else if ("getSDKVersion".equals(action)) {
                getSDKVersion(callbackContext);
            }else if ("startSession".equals(action)) {
               startSession(callbackContext);
            }else if ("endSession".equals(action)) {
               endSession(callbackContext);
            }else if ("sensor".equals(action)) {
               sensor(callbackContext,args);
            }else if ("sensorState".equals(action)) {
                sensorState(callbackContext,args);
            }else if ("setInfoLogStatus".equals(action)) {
                setInfoLogStatus(args);
            }else if ("shareFBToken".equals(action)) {
                shareFBToken(args);
            }else if ("logEvent".equals(action)) {
                logEvent(args);
            }else if ("logTimedEvent".equals(action)) {
                logTimedEvent(args);
            }else if ("endTimedEvent".equals(action)) {
                endTimedEvent(args);
            }

            return true; 
        }catch (Exception e){
            if(enableLog){
                e.printStackTrace();
                System.err.println("Exception: " + e.getMessage()); 
            }
            callbackContext.error(e.getMessage());
            return false;
        }
    }

    public void init(JSONArray args, CallbackContext callbackContext) throws JSONException, PGCoreException {
        
        JSONObject jsonobject = args.getJSONObject(0);
        String appKey = jsonobject.getString("app_key");
        int appSensorState = jsonobject.getInt("app_sensor_state");
        JSONArray sensors = jsonobject.getJSONArray("sensors");
        
        if(enableLog)
            Log.d(TAG, "Init :: params ::" + args.toString());

        PGSettings settings = PGSettings.getInstance();
        // Setting App sensor states
        if(appSensorState == PGCoreSDKPlugin.SENSOR_STATE_ENABLED){
            settings.appSensorState = PGSensorState.SENSOR_STATE_ENABLED;
        }else if(appSensorState == PGCoreSDKPlugin.SENSOR_STATE_DISABLED){
            settings.appSensorState = PGSensorState.SENSOR_STATE_DISABLED;
        }else if(appSensorState == PGCoreSDKPlugin.SENSOR_STATE_NOT_AVAILABLE){
            settings.appSensorState = PGSensorState.SENSOR_STATE_NOT_AVAILABLE;
        }else{
            Log.e(TAG, "Invalid sensor state");
            throw new PGCoreException("Invalid sensor state");
        }

        settings.sourceType = PGSourceType.PGSourcePhoneGap;

        //Enable sensors
        for(int i = 0 ; i < sensors.length(); i++){
            String sensorName  = sensors.getString(i);
            if(sensorName.equals(PGCoreSDKPlugin.NONE)){
                settings.sensors = PGAgent.NONE; 
                return;
            }else{
                Integer sensorVal = sensorMap.get(sensorName);
                if(sensorVal == null){
                    throw new PGCoreException("Invalid sensor :" + sensorName);
                }
                settings.sensors = settings.sensors| sensorMap.get(sensorName); 
            }
        }

        PGAgent.init(app, appKey, settings);
        callbackContext.success("success");

        //Since on resume does not calls in phonegap during application start
        PGAgent.startSession(activity);
    }

    public void initWithPartnerKey(JSONArray args, CallbackContext callbackContext) throws JSONException, PGCoreException {

        JSONObject jsonobject = args.getJSONObject(0);
        String partnerKey = jsonobject.getString("partner_key");
        int appSensorState = jsonobject.getInt("app_sensor_state");
        JSONArray sensors = jsonobject.getJSONArray("sensors");

        if(enableLog)
            Log.d(TAG, "Init :: params ::" + args.toString());

        PGSettings settings = PGSettings.getInstance();
        // Setting App sensor states
        if(appSensorState == PGCoreSDKPlugin.SENSOR_STATE_ENABLED){
            settings.appSensorState = PGSensorState.SENSOR_STATE_ENABLED;
        }else if(appSensorState == PGCoreSDKPlugin.SENSOR_STATE_DISABLED){
            settings.appSensorState = PGSensorState.SENSOR_STATE_DISABLED;
        }else if(appSensorState == PGCoreSDKPlugin.SENSOR_STATE_NOT_AVAILABLE){
            settings.appSensorState = PGSensorState.SENSOR_STATE_NOT_AVAILABLE;
        }else{
            Log.e(TAG, "Invalid sensor state");
            throw new PGCoreException("Invalid sensor state");
        }

        settings.sourceType = PGSourceType.PGSourcePhoneGap;

        //Enable sensors
        for(int i = 0 ; i < sensors.length(); i++){
            String sensorName  = sensors.getString(i);
            if(sensorName.equals(PGCoreSDKPlugin.NONE)){
                settings.sensors = PGAgent.NONE;
                return;
            }else{
                Integer sensorVal = sensorMap.get(sensorName);
                if(sensorVal == null){
                    throw new PGCoreException("Invalid sensor :" + sensorName);
                }
                settings.sensors = settings.sensors| sensorMap.get(sensorName);
            }
        }

        PGAgent.initWithPartnerAppKey(app, partnerKey, settings);
        callbackContext.success("success");

        //Since on resume does not calls in phonegap during application start
        PGAgent.startSession(activity);
    }

    public void startSession(CallbackContext callbackContext){
        
        PGAgent.startSession(activity);
        if(enableLog)
            Log.d(TAG, "startSession");
        
    }

    public void endSession(CallbackContext callbackContext){
        
        PGAgent.endSession(activity);
        if(enableLog)
            Log.d(TAG, "endSession");
    }


     @Override
    public void onPause(boolean multitasking) {

        if(enableLog)
            Log.d(TAG, "Activity on pause is called");

        PGAgent.endSession(activity);
        super.onPause(multitasking);
    }
    
    @Override
    public void onResume(boolean multitasking) {
       
        if(enableLog)
            Log.d(TAG, "Activity on resume is called");

        super.onResume(multitasking);
        PGAgent.startSession(activity);
    }

    public void setInfoLogStatus(JSONArray args) throws JSONException {
        
        JSONObject jsonobject = args.getJSONObject(0);
        boolean infoLogStatus = jsonobject.getBoolean("info_log_status");
        enableLog = infoLogStatus;
        PGAgent.setInfoLogStatus(context,infoLogStatus);
        if(enableLog)
            Log.d(TAG, "setInfoLogStatus :: "+args.toString());
    }

    public void getSDKVersion(CallbackContext callbackContext){

        String sdkVersion = PGAgent.getSDKVersion(context);
        if(enableLog)
            Log.d(TAG, "getSDKVersion :: "+sdkVersion);
        callbackContext.success(sdkVersion);
    }

//    public void getAPIKey(CallbackContext callbackContext){
//
//        String apiKey = PGAgent.getAPIKey(context);
//        if(enableLog)
//            Log.d(TAG, "getAPIKey :: "+apiKey);
//        callbackContext.success(apiKey);
//    }

    public void sensorState(CallbackContext callbackContext,JSONArray args) throws JSONException{
        PGSensorState pgSensorState = PGSensorState.SENSOR_STATE_NOT_AVAILABLE;
        JSONObject jsonobject = args.getJSONObject(0);
        JSONArray sensors = jsonobject.getJSONArray("sensor_name");
        JSONArray sensorArray = new JSONArray();
        for(int i = 0 ; i < sensors.length(); i++) {
            JSONObject sensorObject = new JSONObject();
            String sensorName = sensors.getString(i);
            sensorObject.put("name", sensorName);
            if (enableLog)
                Log.d(TAG, "sensorState :: " + args.toString());
            if (sensorName.equals(PGCoreSDKPlugin.RUNNING_APPS)) {
                pgSensorState = PGAgent.sensorState(context, PGAgent.RUNNING_APPS);
            }
            if (sensorName.equals(PGCoreSDKPlugin.FACEBOOK)) {
                pgSensorState = PGAgent.sensorState(context, PGAgent.FACEBOOK);
            }
            if (sensorName.equals(PGCoreSDKPlugin.LOCATION)) {
                pgSensorState = PGAgent.sensorState(context, PGAgent.LOCATION);
            }
            if (sensorName.equals(PGCoreSDKPlugin.INSTALLED_APPS)) {
                pgSensorState = PGAgent.sensorState(context, PGAgent.INSTALLED_APPS);
            }

            int value = PGCoreSDKPlugin.SENSOR_STATE_NOT_AVAILABLE;
            if (pgSensorState == PGSensorState.SENSOR_STATE_DISABLED){
                value = PGCoreSDKPlugin.SENSOR_STATE_DISABLED;
            }else if(pgSensorState == PGSensorState.SENSOR_STATE_ENABLED){
                value = PGCoreSDKPlugin.SENSOR_STATE_ENABLED;
            }
            sensorObject.put("value", value);
            sensorArray.put(sensorObject);
        }
        callbackContext.success(sensorArray);
    }

    public void sensor(CallbackContext callbackContext,JSONArray args) throws JSONException{

        JSONObject jsonobject = args.getJSONObject(0);
        String sensorName = jsonobject.getString("sensor_name");
        boolean enable = jsonobject.getBoolean("enable");
        if(sensorName.equals(PGCoreSDKPlugin.RUNNING_APPS))
            PGAgent.sensor(PGAgent.RUNNING_APPS,enable); 
        if(sensorName.equals(PGCoreSDKPlugin.FACEBOOK))
            PGAgent.sensor(PGAgent.FACEBOOK,enable);
        if(sensorName.equals(PGCoreSDKPlugin.LOCATION))
            PGAgent.sensor(PGAgent.LOCATION,enable);
        if(sensorName.equals(PGCoreSDKPlugin.INSTALLED_APPS))
            PGAgent.sensor(PGAgent.INSTALLED_APPS,enable);
        if(enableLog)
            Log.d(TAG, "sensor :: "+args.toString());

        callbackContext.success("Success");
    }

    public void shareFBToken(JSONArray args) throws JSONException{
        
        JSONObject jsonobject = args.getJSONObject(0);
        String fbToken = jsonobject.getString("fbtoken");
        JSONArray permissions = jsonobject.getJSONArray("permissions");
        if(enableLog)
            Log.d(TAG, "shareFBToken :: "+args.toString());

        ArrayList<String> listdata = new ArrayList<String>();          
        if (permissions != null) { 
            for (int i=0;i<permissions.length();i++){ 
                String permission = permissions.get(i).toString();
                listdata.add(permission);
            } 
        } 
        PGAgent.shareFBToken(fbToken,listdata);
    }

    public void logEvent(JSONArray args)  throws JSONException{

        if(enableLog)
            Log.d(TAG, "logEvent :: "+args.toString());

        JSONObject jsonobject = args.getJSONObject(0);
        String event = jsonobject.getString("event");
        Map<String, String> map = new HashMap<String, String>();
        JSONObject parameter = null;

       if(jsonobject.has("parameter")){
           parameter = jsonobject.getJSONObject("parameter");
           Iterator iter = parameter.keys();
           while(iter.hasNext()){
                String key = (String)iter.next();
                String value = parameter.getString(key);
                map.put(key,value);
            }
        }
        if(map.size() > 0){
            if(enableLog)
                Log.d(TAG, "logTimedEvent :: Log event with parameter " + map.toString());
            PGAgent.logEvent(event, map);
        }else{
            if(enableLog)
                Log.d(TAG, "logEvent :: Log event without parameter");
            PGAgent.logEvent(event);
        }
    }

    public void logTimedEvent(JSONArray args)  throws JSONException{

        if(enableLog)
            Log.d(TAG, "logTimedEvent :: "+args.toString());

        JSONObject jsonobject = args.getJSONObject(0);
        String event = jsonobject.getString("event");       
        Map<String, String> map = new HashMap<String, String>();
        JSONObject parameter = null;

       if(jsonobject.has("parameter")){
           parameter = jsonobject.getJSONObject("parameter");
           Iterator iter = parameter.keys();
           while(iter.hasNext()){
                String key = (String)iter.next();
                String value = parameter.getString(key);
                map.put(key,value);
            }
        }
        
        if(map.size() >0){
            if(enableLog)
                Log.d(TAG, "logTimedEvent :: Log Timed event with parameter " + map.toString());
            PGAgent.logEvent(event, map,true);
        }else{
            if(enableLog)
                Log.d(TAG, "logTimedEvent :: Log Timed event without parameter");
            PGAgent.logEvent(event,true);
        }
    }

    public void endTimedEvent(JSONArray args) throws JSONException{
        if(enableLog)
            Log.d(TAG, "endTimedEvent :: "+args.toString()); 
        JSONObject jsonobject = args.getJSONObject(0);
        String event = jsonobject.getString("event");
        PGAgent.endTimedEvent(event);
    }


}

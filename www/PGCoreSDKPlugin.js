var exec = require('cordova/exec');

var pgcore = {

    // Sensor State
    SENSOR_STATE_NOT_AVAILABLE : -1,
    SENSOR_STATE_DISABLED : 0,
    SENSOR_STATE_ENABLED : 1,

    //Sensor's

    // TODO Check and remove app sensor
    APP : 'app',
    NONE : 'none',
    LOCATION : 'location',
    RUNNING_APPS : 'running_apps',
    FACEBOOK : 'facebook',
    INSTALLED_APPS : 'installed_apps', 

    pluginVersion : "1.0.3-b1", //TODO Need to read from plugin.xml file. this value should be in sync plugin.xml value
	
	init: function(successCallback, errorCallback,options) {
		exec(successCallback, errorCallback, 'PGCoreSDKPlugin', 'init', [options]);
	},

	getSDKVersion : function(successCallback, errorCallback){
 		exec(successCallback, errorCallback, 'PGCoreSDKPlugin', 'getSDKVersion', []);
	},

	sensor : function(options){
		 exec(function(){}, function(){}, 'PGCoreSDKPlugin', 'sensor', [options]);
	},

	startSession : function(){
		exec(function(){}, function(){}, 'PGCoreSDKPlugin', 'startSession', []);
	},

	endSession : function(){
        exec(function(){}, function(){}, 'PGCoreSDKPlugin', 'endSession', []);
	},

	shareFBToken : function(options){
		exec(function(){}, function(){}, 'PGCoreSDKPlugin', 'shareFBToken', [options]);
	},

	sensorState : function(successCallback, errorCallback, sensorName){
	   var options = {};
	   options.sensor_name = sensorName;
       exec(successCallback, errorCallback, 'PGCoreSDKPlugin', 'sensorState', [options]);
	},

	getAPIKey: function(successCallback, errorCallback){
 		exec(successCallback, errorCallback, 'PGCoreSDKPlugin', 'getAPIKey', []);
	},

	getPluginVersion : function(successCallback,errorCallback){
        successCallback(this.pluginVersion);
	},
    
	setInfoLogStatus : function(status){
		var options = {};
        if(status === true){
           options.info_log_status = true;
        }else{
        	options.info_log_status = false;
        }
		exec(function(){}, function(){}, 'PGCoreSDKPlugin', 'setInfoLogStatus', [options]);
	},
	
	logEvent : function(options){
		exec(function(){}, function(){}, 'PGCoreSDKPlugin', 'logEvent', [options]);
	},

	logTimedEvent : function(options){
		exec(function(){}, function(){}, 'PGCoreSDKPlugin', 'logTimedEvent', [options]);
	},
	
	endTimedEvent : function(options){
		exec(function(){}, function(){}, 'PGCoreSDKPlugin', 'endTimedEvent', [options]);
	},

    shareExternalUserId : function(options){
    	exec(function(){}, function(){}, 'PGCoreSDKPlugin', 'shareExternalUserId', [options]);
    }
};

module.exports = pgcore;

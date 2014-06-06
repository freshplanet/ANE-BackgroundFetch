//////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 Freshplanet (http://freshplanet.com | opensource@freshplanet.com)
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//    http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  
//////////////////////////////////////////////////////////////////////////////////////

package com.freshplanet.ane.AirBackgroundFetch
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;

	public class BackgroundFetch extends EventDispatcher
	{
		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									   PUBLIC API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//
		
		public static const BACKGROUND_MODE_FETCH: String = "fetch";
		public static const BACKGROUND_MODE_REMOTE_NOTIFICATION: String = "remote-notification";
		
		public static const BACKGROUND_FETCH_INTERVAL_MINIMUM: Number = 0;
		public static const BACKGROUND_FETCH_INTERVAL_NEVER: Number = -1;
		
		public static const DID_FETCH_DATA: String = "AirBackgroundFetch_DidFetchData";
		
		/** AirBackgroundFetch is supported on iOS devices. */
		public static function get isSupported(): Boolean
		{
			var isIOS: Boolean = (Capabilities.manufacturer.indexOf("iOS") != -1);
			return isIOS;
		}
		
		public static function set minimumBackgroundFetchInterval(value: int): void
		{
			defaultContext.call("AirBackgroundFetch_setMinimumBackgroundFetchInterval", value);
		}
		
		public static var logEnabled: Boolean = true;
		
		public function BackgroundFetch(backgroundMode: String, url: String)
		{
			if (backgroundMode != BACKGROUND_MODE_FETCH && backgroundMode != BACKGROUND_MODE_REMOTE_NOTIFICATION)
			{
				log("ERROR - Invalid background mode value: " + backgroundMode);
				return;
			}
			
			_context = ExtensionContext.createExtensionContext(EXTENSION_ID, backgroundMode);
			if (!_context)
			{
				log("ERROR - Extension context is null. Please check if extension.xml is setup correctly.");
				return;
			}
			_context.call("AirBackgroundFetch_init", backgroundMode, url);
			_context.addEventListener(StatusEvent.STATUS, onStatus);
		}
		
		public static function cancelAll(): void
		{
			if (!isSupported) return;
			
			defaultContext.call("AirBackgroundFetch_cancelAll");
		}
		
		public function cancel(): void
		{
			if (!isSupported) return;
			
			_context.call("AirBackgroundFetch_cancel");
		}
		
		public function get backgroundMode(): String
		{
			if (!isSupported) return null;
			
			return _context.call("AirBackgroundFetch_getBackgroundMode") as String;
		}
		
		public function get url(): String
		{
			if (!isSupported) return null;
			
			return _context.call("AirBackgroundFetch_getURL") as String;
		}

        public function get data(): Object
        {
			if (!isSupported) return null;
			
			var jsonData: String = _context.call("AirBackgroundFetch_getData") as String;
			try
			{
				return JSON.parse(jsonData);
			} 
			catch(error:Error) 
			{
				return null;
			}
        }

        public function clearData(): void
        {
			if (!isSupported) return;
			
            _context.call("AirBackgroundFetch_clearData");
        }

		
		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									 	PRIVATE API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//
		
		private static const EXTENSION_ID: String = "com.freshplanet.AirBackgroundFetch"; 
		
		private static var _defaultContext: ExtensionContext;
		
		private var _context: ExtensionContext;
		
		private static function get defaultContext(): ExtensionContext
		{
			if (!_defaultContext)
			{
				_defaultContext = ExtensionContext.createExtensionContext(EXTENSION_ID, "default");
				if (!_defaultContext)
				{
					log("ERROR - Extension context is null. Please check if extension.xml is setup correctly.");
				}
			}
			
			return _defaultContext;
		}
		
		private function onStatus(event: StatusEvent): void
		{
			if (event.code == "LOGGING") // Simple log message
			{
				log(event.level);
			}
			else if (event.code == "DID_FETCH_DATA")
			{
				dispatchEvent(new Event(DID_FETCH_DATA));
			}
		}
		
		private static function log(message: String): void
		{
			if (logEnabled) trace("[BackgroundFetch] " + message);
		}
	}
}
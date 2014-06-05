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

	public class AirBackgroundFetch extends EventDispatcher
	{
		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									   PUBLIC API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//
		
		public static const DID_FETCH_DATA:String = "DidFetchData";
		
		/** AirBackgroundFetch is supported on iOS and Android devices. */
		public static function get isSupported() : Boolean
		{
			var isIOS:Boolean = (Capabilities.manufacturer.indexOf("iOS") != -1);
			return isIOS;
		}
		
		public function AirBackgroundFetch()
		{
			if (!_instance)
			{
				_context = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
				if (!_context)
				{
					log("ERROR - Extension context is null. Please check if extension.xml is setup correctly.");
					return;
				}
				_context.addEventListener(StatusEvent.STATUS, onStatus);
				
				_instance = this;
			}
			else
			{
				throw Error("This is a singleton, use getInstance(), do not call the constructor directly.");
			}
		}
		
		public static function getInstance() : AirBackgroundFetch
		{
			return _instance ? _instance : new AirBackgroundFetch();
		}
		
		public var logEnabled : Boolean = true;


		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									 	FUNCTIONS										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//

        public function setFetchURL(url:String, params:String):void
        {
			if (!isSupported) return;
			
            _context.call("AirBackgroundFetchSetFetchURL", url, params);
        }

        public function getFetchedData():String
        {
			if (!isSupported) return null;
			
            return _context.call("AirBackgroundFetchGetFetchedData") as String;
        }

        public function clearFetchedData():void
        {
			if (!isSupported) return;
			
            _context.call("AirBackgroundFetchClearFetchedData");
        }

		
		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									 	PRIVATE API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//
		
		private static const EXTENSION_ID : String = "com.freshplanet.AirBackgroundFetch";
		
		private static var _instance : AirBackgroundFetch;
		
		private var _context : ExtensionContext;
		
		private function onStatus( event : StatusEvent ) : void
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
		
		private function log( message : String ) : void
		{
			if (logEnabled) trace("[AirBackgroundFetch] " + message);
		}
	}
}
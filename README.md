Air Native Extension for Background Fetch on iOS 7+
======================================

This is an [Air native extension](http://www.adobe.com/devnet/air/native-extensions-for-air.html) for [Background Fetch](https://developer.apple.com/library/ios/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/ManagingYourApplicationsFlow/ManagingYourApplicationsFlow.html#//apple_ref/doc/uid/TP40007072-CH4-SW24) on iOS 7+. It has been developed by [FreshPlanet](http://freshplanet.com) and is used in the game [SongPop](http://songpop.fm).


Notes
------

This ANE currently supports fetching one or several URLs (GET requests) while your app is in the background or inactive, and getting the fetched data when your app resumes.

Two background modes are supported:

* __fetch__: the background fetch is triggered periodically by iOS
* __remote-notification__: the background fetch is triggered when your app receives a push notification containing the flag _content-available_.


Installation
------

The ANE binary (AirFacebook.ane) is located in the *bin* folder. You should add it to your application project's Build Path and make sure to package it with your app (more information [here](http://help.adobe.com/en_US/air/build/WS597e5dadb9cc1e0253f7d2fc1311b491071-8000.html)).

You also need to setup your app descriptor to support the right background modes:

```xml
<iPhone>

	<InfoAdditions><![CDATA[

		<key>UIBackgroundModes</key>
		<array>
        	<string>fetch</string>
        	<string>remote-notification</string>
		</array>

	]]></InfoAdditions>

</iPhone>
```


Usage
-----

```actionscript
var fetchURL: String = "http://mydomain.com/some/path?param1=value1&param2=value2"

// Setup a BackgroundFetch instance (here we use the remote notification mode)
var backgroundFetch: BackgroundFetch = new BackgroundFetch(BackgroundFetch.BACKGROUND_MODE_REMOTE_NOTIFICATION, fetchURL);

// If some data is available, do something with it
if (backgroundFetch.data)
{
	// do something with data
}

// To stop any future background fetch
backgroundFetch.cancel();
// or
BackgroundFetch.cancelAll();
```

Here are a few things to keep in mind:

* you can create several instances of BackgroundFetch, but you should only create one for each (backgroundMode, url) pair
* if your app is killed, it will be awaken by the OS in a sandbox (the user won't see it) to perform the fetch
* when in sandbox, your ActionScript code won't be executed, just the native code
* when in sandbox, the ANE only has 30 seconds to perform the fetch, so don't try to fetch dozens of URLs


Build from source
---------

Should you need to edit the extension source code and/or recompile it, you will find an ant build script (build.xml) in the *build* folder:
    
```bash
cd /path/to/the/ane

# Setup build configuration
cd build
mv example.build.config build.config
# Edit build.config file to provide your machine-specific paths

# Build the ANE
ant
```


Authors
------

This ANE has been written by [Alexis Taugeron](http://alexistaugeron.com). It belongs to [FreshPlanet Inc.](http://freshplanet.com) and is distributed under the [Apache Licence, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
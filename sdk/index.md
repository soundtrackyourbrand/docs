# Soundtrack SDK | Docs

## Table of Contents
  * [Introduction](#introduction)
  * [Changelog](#changelog)
  * [Getting started](#getting-started)
  * [Reference implementation](#reference-implementation)
  * [Authentication &amp; Pairing](#authentication--pairing)
  * [Upgrade and provisioning](#upgrade-and-provisioning)
  * [Approval process and certification](#approval-process-and-certification)
  * [Release management](#release-management)
  * [Q&amp;A](#qa)
  * [Certification](#certification)


## Introduction

The Soundtrack SDK makes it possible to play music from Soundtrack on your platform. 
It is available for selected partners with potential for over 5000 locations. 
If you're interested in becoming one, please reach out to [sdk@soundtrackyourbrand.com](mailto:sdk@soundtrackyourbrand.com).

All applications using the SDK must adhere to the Soundtrack Terms & Conditions. Certification is required before launch.

### API
The SDK provides C header files, exposing an API called SPlayer API. It enables you to can do basic playback control and interface to the audio output of your choice.
In its most basic form you'll get raw PCM samples out, but there are examples provided for common platforms for how to interface with the OS audio output.

The player itself is provided as a single shared library, built by us with a toolchain you provide. API additions can be made without the need for recompile from your side.

#### Available Actions
* Create and free an SPlayer API context.
* Exit the player gracefully (after current song has ended).
* Authentication
* Playback controls (play, pause, skip track, set volume).
* Retrieve errors.

### Requirements
* A POSIX API compatible OS, that supports TCP sockets, and threads.
* At least 64 MB free RAM for the player to operate in.
* A reasonably strong CPU that could handle our parallel encryption, decoding and digital signal processing.
* A minimum of 4 GB of storage used for offline music and data storage. 8 GB is recommended.
* You need to provide a C++14 capable cross-compiler toolchain and compiler options, so we can build our library in an x86-64 linux docker container.
* An onboard RTC with backup battery. In case of a power loss, we cannot play audio until we have a valid system time due to our scheduling, and licensing constraints.

### Soundtrack Responsibilities
* SPlayer binary and header files (e.g. libsplayer-x.so and splayerapi-x.h).
* Backend infrastructure used by SPlayer.

### Partner Responsibilities
* Application lifecycle.
* Application monitoring.
* Audio processing of the SPlayer output.
* All source code except for splayerapi-x.h.
* Library update mechanism.
* Updating the toolchain to make sure it supports a C++ standard that is at most 5 years old at any given time now and in the future.

## Getting started

### What's in the package?
* Header files for Splayer API
* Shared library for Splayer API
* Example implementations for audio output via ALSA or Darwin
* Example source code using the update service to fetch latest shared library

You'll find the link for it here: https://builds.soundtrackyourbrand.com/remote/splayer-ubuntu/latest
Look for the splayerapi-1-v4 package. Inside it, there are the headers needed to interface to the library as well as some example applications.

In order for you to get a player up and running as quickly as possible, use the pairing code option available in the auth api. There is an example of how to use it in the example_auth.c file.
Unfortunately, we haven't yet finished updating the official documentation over at https://developer.soundtrackyourbrand.com/sdk/ with this feature. But I believe you can figure it out using the example and the function descriptions in the headers.

It’s extra important that you understand the hierarchy, where one **account** (e.g. “Ludwig's Burgers”) can have multiple **locations** (e.g. “Flagship restaurant, Stockholm”) which in turn can have multiple **sound zones** (e.g. “Bar”, “Restaurant area”, “Staff room”).

Each sound zone can only have one **device**. Soundtrack supports multiple device types (see our help pages to see which ones). The rationale for having multiple sound zones is that you want different music in different parts of the same location. If you want the same music everywhere in the same location you’ll only need one device and then distribute the music with your audio system.

## Pairing a device with a sound zone
To initiate streaming, your application must first be paired with a specific sound zone within a Soundtrack location. This pairing process utilizes a unique pairing code, generated on demand by Soundtrack.
Once paired, a unique Device ID will be returned that can be used when checking for SDK updates later.

### Obtaining a Pairing Code
There are two primary methods for obtaining a pairing code; Redirect and Callback or Manual Entry.

#### Redirect and Callback (Preferred):

This method provides the smoothest user experience by eliminating manual entry.

1. Your application initiates a redirect to the following URL:
   `http://business.soundtrackyourbrand.com/connect/generic?redirect=<REDIRECT_URL>`
   Replace `<REDIRECT_URL>` with the URL of your application that will handle the callback. This URL must be accessible by the device that is used for the pairing flow.
1. The user logs in to their Soundtrack account and selects the desired sound zone.
1. Soundtrack redirects the user back to your specified REDIRECT_URL with the pairing code appended as a query parameter: `<REDIRECT_URL>?code=<CODE>`
1. Your application can then extract the code parameter and programmatically provide it to the SDK. See `example_auth.c` in the SDK package for a proof-of-concept using this method.

Important Considerations:
* When using the redirect method, ensure your application can handle URL redirects and retrieve parameters from the callback URL.
* Clearly communicate the redirect process to the user to avoid confusion.

#### Manual Entry:

1. The user logs in to their Soundtrack account through the [Soundtrack web application](https://business.soundtrackyourbrand.com).
1. They navigate to the desired sound zone and generate a pairing code by selecting `pair`.
1. A pairing code will be generated and displayed on the page.
1. The user manually enters this code into your application's interface.

## Building and running the example code
1. Open the /src folder. There are several examples showcasing some basic setup of a player application.
1. Build the project using cmake
1. There will now be several example targets in the build root folder
1. Run the example executable (eg. libsplayer_simple). When running an example for the first time, provide the pairing code (see above) as the first argument to the application.
1. There should be some console output and music should start playing shortly

## Reference implementation
In the package distributed by Soundtrack, you will find an array of example implementations. Feel free to modify as you wish.

## Upgrade and provisioning
Splayer API is provisioned by Soundtrack's build systems with rollout limited to a certain percent of all devices, or at a certain time of day considering local time zone of the device. Below are two different endpoints to use to retrieve the latest version of Splayer API for two different platforms (Android ARM 64 bit, Ubuntu 16.04 32 bit).

* https://builds.soundtrackyourbrand.com/remote/android-arm64-sdk/latest
* https://builds.soundtrackyourbrand.com/remote/splayer-i686/latest

The template is basically:
* https://builds.soundtrackyourbrand.com/remote/\<platform_name\>/latest

```json
{
  "id": "QnVpbGQsLDFsZ2g1bW1uNnJrLw..",
  "version": "48.17-308",
  "link": "https://download.api.soundtrackyourbrand.com/ci-releases/splayer-x86_64/libsplayer-1-48.17-308-splayer-x86_64.so",
  "checksum": "9e12bb0ded21711ea1c666dc776b2751febcc01f",
  "platform": "splayer-x86_64"
}
```

The two important fields are version and link, you can disregard all other fields in the JSON.

The checksum is a sha1 hash of the file in the link. Make sure to verify the checksum matches for security and reliability reasons.

To get provisioning working you need to send three HTTP headers containing:
* `X-Device-Key-0` - always with value `eth0`.
* `X-Device-Vendor` - Vendor Hardware ID, will be provided to you by Soundtrack.
* `X-Device-Id-0` - Device ID. Available once the device is paired. In the example below the Device ID is `28cfe91fcc6d`. If not paired, omit this header.

If the device is not yet paired, then no Device ID is available yet.

```
X-Device-Key-0:eth0
X-Device-Id-0:28cfe91fcc6d
X-Device-Vendor:your_vendor_ID
```

**Example of adding HTTP headers with cURL**

```c
char buf[1024];
snprintf(buf, sizeof(buf), "X-Device-Id-0:%s", device_id);

struct curl_slist *chunk = NULL;
chunk = curl_slist_append(chunk, "Accept:");
chunk = curl_slist_append(chunk, "X-Device-Key-0:eth0");
chunk = curl_slist_append(chunk, buf);
curl_easy_setopt(curl, CURLOPT_HTTPHEADER, chunk);
```

## Approval process and certification
The application built is to be approved by Soundtrack and shall at all times adhere to the certification criterias (see: Certification).

## Release management
This section describes the release management of the player library that we send out once a quarter. Note, that this update does not refer to the SDK itself with updated API, which will be communicated when available and backwards compatibility will be kept as long as possible.

### Release SDK player software
The Soundtrack SDK releases contain a pre- and full-release. The pre-release is sent out for the purpose of SDK partner testing and the full-release is the the costumer production release. The Soundtrack SDK releases are taking place once every quarter, which is distributed into following months: November, February, May, August. See [SDK Release Calendar](https://calendar.google.com/calendar?cid=c291bmR0cmFja3lvdXJicmFuZC5jb21fZjM5YmpzbWxrZWtncDllazN0dWprZ2NkdWNAZ3JvdXAuY2FsZW5kYXIuZ29vZ2xlLmNvbQ) for exact dates.

#### Pre-release
Every quarter the pre-release is sent out to the SDK pre-release channel.
* An email will be sent to you when it's done.
* Your internal test account will be updated.
* From this day, you have three weeks to flag any issues to Soundtrack. Soundtrack will decide whether or not the issue is a blocker.

#### Full-release
Three weeks after the pre-release is sent out, the production release is sent out to the full customer base on Wednesday morning 02.00-06.00 (based on each player’s local time).
* An email will be sent to you when it's scheduled.

### Patching SDK player software
In the event of a critical issue and there is a need for a patch release Soundtrack has the possibility to release outside of the normal release schedule. The reason for a patch is either an incident or an important bug.

* Important bugs are classified as something that has direct customer impact, such as audio playback issues, UI bugs or irregular data consumption. Fixes are mostly small and should not affect major parts of the code.
* An incident is when a back-end change may or have already happened, that we will or want to protect us from.

### Release schedule

You will get an email notification whenever we are sending out a new release either to your pre-release channel or a full production release. For any questions/issues, just reply back to us.

Here's the full [SDK Release Calendar](https://calendar.google.com/calendar?cid=c291bmR0cmFja3lvdXJicmFuZC5jb21fZjM5YmpzbWxrZWtncDllazN0dWprZ2NkdWNAZ3JvdXAuY2FsZW5kYXIuZ29vZ2xlLmNvbQ).

## Deprecation of software

We support a release for 6 months. Players running versions older than 6 month will stop music playback. One month in advance, the player is deprecated. The time is based on when the software was released.

Here's the full [Soundtrack Deprecation Schedule](https://calendar.google.com/calendar/u/0?cid=Y18yN3B2cThpMWs3b2cwYmhpN2xuYnVjOHFzc0Bncm91cC5jYWxlbmRhci5nb29nbGUuY29t).

## Unsupported
When a player is unsupported, a device error `DEVICE_ERROR_UNSUPPORTED_VERSION` is raised on the zone and authentication will fail with http 426 which results in that the player won't be able to play more music. Mails are being sent out to the concerned customers and it's possible to filter on "Need player update" in Business to find the right players.

## Deprecated
When a player is deprecated, a device error `DEVICE_ERROR_SOON_UNSUPPORTED_VERSION` is raised on the zone but nothing happens on the player. Mails are being sent out to the concerned customers and it's possible to filter on "Need player update" in Business to find the right players.

Please note that we can't say which versions will be deprecated when, as that mainly depends on when that version was released (which can change over time). When we deprecate once a month the next deprecation batch will be decided, which will get the deprecation error (one month in advance of being unsupported). No player newer than 6 month will ever be unsupported from release date.

## Q&A

### Older version of libstdc++ and ld.so running on the target.
Depending on GCC version you might have an older version of libc, libstdc++ and ld.
```
./libSplayer_alsa: /lib/libstdc++.so.6: version `GLIBCXX_3.4.20' not found (required by libSplayer.so)
./libSplayer_alsa: /lib/libstdc++.so.6: version `CXXABI_1.3.8' not found (required by libSplayer.so)
./libSplayer_alsa: /lib/libstdc++.so.6: version `GLIBCXX_3.4.19' not found (required by libSplayer.so)
./libSplayer_alsa: /lib/libstdc++.so.6: version `GLIBCXX_3.4.21' not found (required by libSplayer.so)
```
If needed, we can link libstdc++ statically to avoid most of the issues, but your target platform needs a compatible libc.so. Use the same version of libc and libstdc++ on your target as in the toolchain that you provide us. For Linux, you can create them using Yocto or Buildroot. Be aware that we are using atomics from c++ 11, and some gcc toolchains put these in a separate library called libatomic.so. This library is required on the device for our player to run.

### Audio stutters
On some hardware we have seen ALSA defaulting to a very small buffer size. A 44.1Khz two channel PCM stream is 88 200 samples/per second. In the below example that's a context switch 200 times a second (every 5ms). Now a small buffer size is great for low latency, game and sound applications where instant sound feedback is needed on user input. This is not the case for audio streaming. With these small buffers we can't feed ALSA with audio fast enough, so we will get -EPIPE from snd_pcm_writei().
```
Alsa initialized, buffer_size: 1323 period_size: 441
```
Set the ALSA buffer size to at least 1 period (second). For 44.1Khz two channel PCM stream is buffer size 88 200 samples and a period size of 22 050 samples. We have provided the code in callbacks_alsa.c. You could try to set the buffer size to 4 periods instead.
```
Alsa initialized, buffer_size: 88200 period_size: 22050
```

### Error codes explanation
By calling `splayer_get_troubles()` you are able to retrieve a list of Soundtrack internal errors.
See the example code to know how to do it. These error codes can vary between Splayer versions, but this list is updated whenever a new version is released with changes to them.

Here follows a brief explanation of the current possible errors:

Error name | Explanation | Condition
--- | --- | ---
ERROR_VALID_IP | Returns a list of the current network config. | Fails if no network config is found.
ERROR_PING_SOUNDTRACK |  Checks connectivity to Soundtrack internal endpoints in order for the product to work as expected | Fails if the player can't connect to any of these endpoints.
ERROR_PING_DNS | Check the DNS | Fails if DNS lookup doesn't work
ERROR_PING_CDN | Checks connectivity to the CDN-servers in order for the product to download/stream music. | Fails if the player can't connect to the endpoints.
ERROR_PING_CDN_IP | Checks connectivity rate to the CDN-servers in order for the product to have sufficient connectivity to guarantee download/stream music. | Fails if the player has a low success rate.
ERROR_PING_CERT | Checks if a proxy is used. We do not support that. | Fails if proxy is found.
ERROR_ONLINE_STATE | Checks online state | Fails if the player is offline/high amount of failing requests.
ERROR_PAIRED | Checks if player is paired | Fails if not paired.
ERROR_ACTIVE_SUBSCRIPTION | Checks if player have an active subscription | Fails if inactive.
ERROR_CHANNEL_ASSIGNED | Checks if any source of music is assigned | Fails if no music is assigned
ERROR_DOWNLOADED_DATA | Checks downloaded data for the assigned music. | Fails if nothing is downloaded.
ERROR_NO_VOLUME | Checks the volume level | Fails if there is volume is set to zero.
ERROR_DISKCACHE_LOW | Checks free disk space | Fails if the free disk space is below 1 GB.
ERROR_DISKCACHE_CRITICALLY_LOW | Checks free disk space | Fails if the free disk space is below 256 MB.
ERROR_PAYMENT_EXPIRED | Check payment status | Fails if the paired zone doesn't have a valid and payed subscription.
ERROR_CLOCK_WRONG | Check server time offset | Fails if server time offset differs +- 15 min from the device local time.

## Certification

### Background
* The below is applicable to the Soundtrack SDK, not the Soundtrack API
* All applications built using the Soundtrack SDK are to be certified by Soundtrack prior to being shared with customers
* In order to conduct the certification, you need, in addition to the credentials used in the SDK, a Soundtrack test account (subject to Soundtrack T&C and provided by Soundtrack)
* The certification process is developed from a customer experience standpoint. Ease of use is critical

### Definitions
* **Pair** is Soundtrack lingo for connecting the Application with Soundtrack
* **Pairing code** is the Soundtrack generated code needed for pairing the Application with Soundtrack's services
* **SDK** is the APIs and binaries provided by Soundtrack
* **Application** is the partner built application that contains the SDK

### Certification process
* Please note that you need to provide Soundtrack with two pcs of the hardware in order for Soundtrack to do the certification
* Any changes to the hardware will prompt a new certification process
* All tests should pass on a 0.5 Mbps network, unless anything else is stated in the instructions
* The partner shall recommend an SD-card to its client (unless internal storage is used). The same SD-card shall be used for the certification
* The certification shall be as close to the real environment as possible, so if the platform's normal state is e.g. to have two other applications running at the same time, these shall be running during the certification as well

Type | Test case | Instructions | Expected behavior
--- | --- | --- | ---
Setup | 1.1 | Start the device. | - The device should be intuitive to install and come with necessary instructions. - It should be simple to start the Application.
. | 1.2 | Ensure Application has connectivity | Clearly stated whether or not the Application can access Soundtrack
. | 1.3 | Clear pairing flow | - The user entry point to initiate pairing should be clear and easily accessable for the user. - Clear user feedback if the pairing fails at any point in the flow should be present.
. | 1.4 | Pair the Application in Soundtrack and assign a soundtrack | Music should start playing within 2 minutes.
Actions in [web interface](https://business.soundtrackyourbrand.com) | 2.1 | Skip track | Track skipped
. | 2.2 | Press pause | Track paused
. | 2.3 | Press play | Track resumed
. | 2.4 | Increase volume to max | Volume set to max
. | 2.5 | Decrease volume to zero | Volume set to minimum
. | 2.6 | Change soundtrack | New soundtrack should start playing after the current track is done
Playback (offline) | 3.1 | Cut off internet access (e.g. by plugging out the ethernet cable) when the device is powered on | Music should keep playing
. | 3.2 | Start device without internet access | Music should keep playing
. | 3.3 | Enable internet again | - Music should keep playing. - Device should go online in Soundtrack.
Playback - poor internet connectivity _(ensure that you have music cached offline for this step)_ | 4.1 | Set up a network according to the profile "100% Loss". See below. | Music should keep playing
. | 4.2 | Set up a network according to the profile "High latency DNS". See below. | Music should keep playing
. | 4.3 | Set up a network according to the profile "Very bad network". See below. | Music should keep playing
. | 4.4 | Set up a network according to the profile "Edge". See below. | Music should keep playing
Updater | 5.1 | None | - Contacts Soundtrack's update service every 15 minutes (if the device is online). - If a new SDK is available: download. -When the new SDK downloaded: quit Application at end of next song. - If installation fails: fall back to previous SDK version
Watchdog | 6.1 | Make sure the application is running, then ask Soundtrack to simulate a crash remotely | - Application should be restarted. - Music should start playing within 30 seconds.
Test latency on actions _(implementation of these actions are not mandatory)_ | 7.1 | Skip track (e.g. using a button on the device or in the application) | Track changes within 1 second
. | 7.2 | Press pause (e.g. using a button on the device or in the application) | Track paused within 1 second
. | 7.3 | Press play (e.g. using a button on the device or in the application) | Track resumed within 1 second
. | 7.4 | Change volume (e.g. using a button on the device or in the application) | Volume changed within 1 second
. | 7.5 | Show result from troubleshooting endpoint (e.g. exposing if device is paired or not in the application) | Correct information exposed (e.g. if the device is not paired to Soundtrack)
Stress test (final boss) | 8.1 | Assign the soundtrack 'SDK Certification' and play for one week | Music playing
General | 9.1 | Check for Soundtrack marketing material (e.g. logos) | Material not in breach with marketing guidelines


#### Poor internet connectivity profiles

. | 100% loss | High latency DNS | Very bad network | Edge
--- | --- | --- | --- | ---
**Downlink bandwidth** | No limit | No limit | 1 Mbps | 240 Kbps
**Downlink packets dropped** | 100 % | 0 % | 10 % | 0 %
**Downlink delay** | 0 ms | 0 ms | 500 ms | 400 ms
**Uplink bandwidth** | No limit | No limit | 1 Mbps | 200 Kbps
**Uplink packets dropped** | 100 % | 0 % | 10 % | 0 %
**Uplink delay** | 0 ms | 0 ms | 500 ms | 440 ms
**DNS delay** | 0 ms | 3000 ms | 0 ms | 0 ms

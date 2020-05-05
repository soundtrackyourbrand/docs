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

The Soundtrack SDK enables you to build support for Soundtrack on your platform. By combining expert curation and world-class tech, Soundtrack Your Brand provides a beautiful all-in-one solution for streaming music to stores, hotels, restaurants, and other commercial settings.

The SDK is available for selected partners. If you're interested in becoming one, please reach out to sdk@soundtrackyourbrand.com (applications currently open for opportunities of more than 5000 locations).

This page contains the documentation for the SDK. In order to use it, you will need our latest build (which we need to send to you).

Soundtrack SDK is the package containing all code and documentation needed for you to get started. Splayer API is the local API within the SDK, used for initiating and controlling playback.

Unless anything else is communicated by Soundtrack, the application shall be named "Soundtrack Player".

### Features
* Provided as a single shared library, built with toolchain provided by partner and with no external dependencies out of that.
* Few entry points which means faster load times and simple mapping both for dynamic linking
* Extendable API without the need to recompile (unless there are breaking changes)
* Callbacks for audio so the user can control their hardware specific needs.

### Functionality
* Create and free a Splayer API context
* Exit the player gracefully (after the next song)
* Player control (play, pause, skip track, set volume)
* Checklist for common troubles
* Callbacks for audio so the user can control their hardware specific needs (eg. ALSA)

### Responsibilities
* Soundtrack is responsible for the binary and header file (eg libsplayer-x.so and splayerapi-x.h).
* Splayer communicates with Soundtrack's infrastructure and delivers sound buffers (eg. PCM data).
* Partner is responsible for all the parts concerning the executable, the actual playback (eg. ALSA).
* Soundtrack provides source code examples as-is and it's the Partners responsibility to make them work.
* Partner can use any part of the source code example, change and modify them, except splayerapi-x.h
* Partner is responsible to check with Soundtrack's infrastructure every 15 minutes to see if new releases are available.
* Partner is responsible for providing a toolchain that supports a C++ standard that is at most 5 years old at any given time now and in the future.

### Requirements
* A POSIX api compatible OS, that support tcp sockets, and threads.
* At lest 64Mb free ram for the player to operate in.
* A reasonable strong cpu, that could handle our parallel encryption, decoding and digital signal processing.
* A minimum of 4GB, recommended 8GB of storage used for offline music and data storage.
* Partner needs to provide a C++14 capable cross compiler toolchain, and compiler options that we can build our library in a x86-64 linux docker container.
* An onboard battery backuped RTC, in case of a powerloss we can not play audio playback until we have a valid systemtime due to our scheduling, and licensing constraints.


## Changelog

Detailed changelog can be found in the SDK package.

Date | Version | Changes | Included APIs
--- | --- | ---
Q4, 2017 | 1 | First draft including basic functionality. | splayerapi v1
Q2, 2018 | 2 | Moved controls to a separate API. Clarified examples. | splayerapi v2, splayerapi_control v1
Q4, 2018 | 3 | Major/minor versioning. New metadata API. Some config variables renamed for clarity. | splayerapi v3, splayer_controls_api v2, splayer_troubles_api v1, splayer_audio_api v1, splayer_metadata_api v1

## Getting started

### Prerequisites
Make sure that you have:
* your vendor secret (provided to you by Soundtrack).
* your Partner API credentials (provided to you by Soundtrack).
* access to Soundtrack. Sign up at soundtrackyourbrand.com.
* the Splayer API header file (e.g. splayer-2.h) and the Splayer shared library (eg. libsplayer-1.so, libsplayer-1.dylib).

All applications must be in line with the terms & conditions and be certified by Soundtrack (see certification criteria further down on this page).

### What's in the package?
* Header files for Splayer API and ALSA implementation example
* Shared library for Splayer API
* Example implementations for audio output via ALSA or Darwin
* Example source code using ALSA or Darwin
* Example source code using the update service to fetch latest shared library

Note: The package can't be find on this page. It will be sent to you by Soundtrack. A static library version can be provided. It is not included by default due to the increase in size of the package

### Soundtrack - Overview
We highly recommend that you play around with your Soundtrack account so you get an overview of the product prior to using the API. All guides and frequently asked questions regarding Soundtrack can be found on our help pages.

It’s extra important that you understand the hierarchy, where one **account** (e.g. “Ludwig's Burgers”) can have multiple **locations** (e.g. “Flagship restaurant, Stockholm”) which in turn can have multiple **sound zones** (e.g. “Bar”, “Restaurant area”, “Staff room”).

Each sound zone can only have one **device**. Soundtrack supports multiple device types (see our help pages to see which ones). The rationale for having multiple sound zones is that you want different music in different parts of the same location. If you want the same music everywhere in the same location you’ll only need one device and then distribute the music with your audio system.

### Create a device

Before we can run an application using the SDK we must create a device using the Partner API. This device will be unique and needs to be paired to a sound zone. A device can only be paired with one sound zone at a time. The Partner API is a GraphQL API and you can run the following to create a device. Note: you need your Partner API credentials to do this step. It only needs to be done once since the pairing code does not change.

1. Go to https://partner.soundtrackyourbrand.com/api/explore (this is just an explore tool, you should of course implement this code where you find it suitable)
2. Add the Authorization header. In the “Value” field, write “Basic <your_credentials>” where <your_credentials> are the Partner API credentials that you should have received from Soundtrack. Ensure that you copy the full base64-token including the == on the end

Example:
```
Authorization: base64encode(client_id:client_secret)
```
3. Enter a GraphQL query in the top box
```
mutation PartnerCodeCreator($input:GeneratePairingCodesInput!){
    generatePairingCodes(input: $input) {
        codes {
            pairingCode
        }
    }
}
```
4. Include the query variables
```
{   
    "input": {
        "description":"ARM64",
        "deviceType": "EMBEDDED",
        "label": "Partnername M324",
        "hardwareIds": ["partner_id_ab12"]
    }
}
```
 * Change the `description` to add information about the platform. It’s more of a description of the specific hardware/platform, so we can distinguish among your devices in case there are any differences in hardware/platform or you come up with a new generation etc (will be shown to users).
 * Set `deviceType` to `EMBEDDED` (currently not optional)
 * Change the `label` to something unique for you as an SDK-partner. This is for us to be able to distinguish you from other SDK-partners. Prefarable your name (will not be shown to users).
 * Change the `hardwareIds` entry to the hardware_id of your choice. See "Authentication & Pairing" for more info


5. Run the query and you should get a pairing code as output. You will need this code to pair the created device with a specific sound zone later.
6. Write down the hardware_id that you chose (in the example ‘partner_id_ab12’). Write down the pairing code that was output when you ran the query

### Pairing a device with a sound zone
1. Go to Soundtrack (https://www.soundtrackyourbrand.com/)
2. Press “Locations”
3. If you have no location set up. Create location using the “Add Location” button
4. When the location is created, you need to create a sound zone
5. Press the options button to the right of the location
6. Add a zone with a name
7. Click on the new zone
8. Pair your player application by choosing “Hardware Device”
9. In the input field, enter the Pairing Code that you got when creating a device.
10. The device should now be paired with this sound zone.

### Building and running the example code
1. Unpack tar ball (sent to you by Soundtrack)
2. In the /src folder there are several examples showcasing some basic setup of a player application
3. Open any example file, and change the parameter: hardware_id to the hardware id you created in the “Create a device” section (“partner_id_ab12” in above example)
4. We also need to provide the vendor secret to the application (will be sent to you by Soundtrack). This can be done in a few different ways:
 * Set the value directly in vendor_secret
 * Set `-DVENDOR_SECRET=xxxx` when building with cmake
 * Add the vendor secret directly in the CMakeList.txt file
 ```c
 add_definitions(-DVENDOR_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)
 ```
5. Build the project using cmake
6. There will now be several example targets in the build root folder
7. Run the example executable (eg. libsplayer_simple)
8. There should be some console output and music should start playing shortly

```c
libsplayer_alsa
is_playing() = false


alsa_open samp: 44100 channels: 2
Alsa initialized, buffer_size: 88200 period_size: 22050
Couldn't find PCM 'PCM' volume control.
alsa_audio_impl::audio_pause: 0
  9 21:56:36 tyson                    warn             job.cpp:161  Slow timer, seconds: 0.052278248003858607, context: "from: dsp.cpp:344 schedule_setup"
 alsa_audio_impl::audio_pause: 0
ERROR: EBADFD: Let's prepare alsa again
snd_pcm_prepare returned 0
```

## Reference implementation
In the package distributed by SYB, you will find an array of example implementations. Feel free to modify as you wish.

## Authentication & Pairing

Splayer API is only aware of Vendor Hardware ID, which is something that you as a vendor chose, and a Vendor Secret that you will get from Soundtrack. The hardware ID is used to generate the Device ID in the Partner API (see Create a Device above). The reason Soundtrack Device ID's are used for pairing is because they are guaranteed to be unique, even though two vendors might have the same Vendor Hardware ID for two different devices. This way we avoid name clashes for devices.

Second reason, is that our website is open for all customers, which means a user can have devices from multiple vendors and the end user would then need to pick from a list of vendor. It wouldn't be the best user experience, it would be easy to make mistakes and the user himself could guess a Vendor Hardware ID and do a denial of service for somebody else.

## Upgrade and provisioning
Splayer API is provisioned by Soundtrack's backoffice systems with rollout limited to a certain percent of all devices, or at a certain time of day considering local time zone of the device. Below are two different endpoints to use to retrieve the latest version of Splayer API for two different platforms (Ubuntu 16.04 64-bit, Ubuntu 16.04 32 bit).

* https://builds.soundtrackyourbrand.com/remote/splayer-x86_64/latest
* https://builds.soundtrackyourbrand.com/remote/splayer-i686/latest

The template is basically:
* https://builds.soundtrackyourbrand.com/remote/<platform_name>/latest

```json
{
"id": "QnVpbGQsLDFsZ2g1bW1uNnJrLw..",
"version": "48.17-308",
"link": "https://download.api.soundtrackyourbrand.com/ci-releases/splayer-x86_64/libsplayer-1-48.17-308-splayer-x86_64.so",
"checksum": "9e12bb0ded21711ea1c666dc776b2751febcc01f",
"platform": "splayer-x86_64"
}
```

The two important fields are version and link, you can disregard all other fields in the JSON. In the example above the version is hashnumber, since the example is not from a proper release, but the latest build. The link points directly to the library.

The checksum is a sha1 hash of the file in the link. Make sure to verify the checksum matches for security and reliability reason.

To get provisioning working you need to send three HTTP headers. Basically each device sends a Vendor Hardware ID as described above and a Device Vendor ID. In the example below the Vendor Hardware ID is `28cfe91fcc6d`.

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
Please note that the below release information relates to the player software within the SDK, so it's not the SDK and the splayer-APIs per se.

### Release SDK player software
 
 The production releases are taking place on Wednesday's morning (02.00-06.00) local time. **Due to COVID-19 and limited resources, releases will be done on Tuesdays.**
 
 Every second week the pre-release is sent out to your pre-release channel.
* An email will be sent to you when it's done. 
* Your internal test account will be updated.
* From this day, you have one week to flag any issues to Soundtrack. Soundtrack will decide whether or not the issue is a blocker.

Every second other week, the full-release is sent out to full costumer base between 02.00 and 06.00 (based on each player’s local time).
* An email will be sent to you when it's done. 

### Patching SDK player software
Every Thursday Soundtrack decides if there is a need for a patch the coming week. The reason for a patch is either an incident or an important bug.

* Important bugs are classified as something that has direct customer impact, such as audio playback issues, UI bugs or irregular data consumption. Fixes are mostly small and should not affect major parts of the code
* An incident is when a back-end change may or have already happened, that we will or want to protect us from

All times below are CET/CEST. Consider that the times below are deadlines.

No later than Thursday, 18:00:
 * Your internal test account will be updated with the patch version
 * We will send you an email to the designated address
No later than Tuesday (***Mondays now due to COVID-19***), 15:00:
 * Soundtrack Test Lead decides if the patch can be released
 * If no-go: email to you informing about the decision
 * If you have had the time to test and approve (via email): patch is released in the next morning
 * If we have not heard from you, we will not do the release to your customers

If you did not get in touch with us, you will have to wait until next full release to get the patch.

### Release schedule

You will get email notifcation whenever we are sending out a new release either to your pre-release channel or a full production release. For any questions/issues, just reply back to us.

Here's the full release calender (***temporary changed due to COVID-19***): https://calendar.google.com/calendar?cid=c291bmR0cmFja3lvdXJicmFuZC5jb21fZjM5YmpzbWxrZWtncDllazN0dWprZ2NkdWNAZ3JvdXAuY2FsZW5kYXIuZ29vZ2xlLmNvbQ

## Q&A

### Older version of libstdc++ and ld.so running on the target.
Depending on GCC version you might have an older version of libc, libstdc++ and ld. We are running GCC 6.4 and 7.0 in production.
```
./libSplayer_alsa: /lib/libstdc++.so.6: version `GLIBCXX_3.4.20' not found (required by libSplayer.so)
./libSplayer_alsa: /lib/libstdc++.so.6: version `CXXABI_1.3.8' not found (required by libSplayer.so)
./libSplayer_alsa: /lib/libstdc++.so.6: version `GLIBCXX_3.4.19' not found (required by libSplayer.so)
./libSplayer_alsa: /lib/libstdc++.so.6: version `GLIBCXX_3.4.21' not found (required by libSplayer.so)
```
If needed we can link libstdc++ statically to avoid most of the issues, but your target platform needs a compatible libc.so (glibc). Use the same version of libc and libstdc++ on your target as in the toolchain that you provide us. For Linux, you can create them using Yocto or Buildroot. Be aware that we are using atomics from c++ 11, and some gcc toolchains put these in a separate library called libatomic.so. This library is required on the device for our player to run.

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
By calling "splayer_get_troubles()" you are able to achieve a list of SYB internal errors. See the example code snippets for exact return types since this changes over API version. Also, these error code can change depending on which SYB software is installed, but this is a list of the latest errors.

Here follows a explanation of all errors we have at the moment.

Error name | Explanation | Condition
--- | ---
ERROR_VALID_IP | Returns a list of the current network config. | Fails if no network config is found.
ERROR_PING_SOUNDTRACK |  Checks connectivity to SYB internal endpoints in order for the product to work as expected | Fails if the player can't connect to any of these endpoints.    
ERROR_PING_DNS | Check the DNS | Fails if DNS lookup doesn't work
ERROR_PING_CDN | Checks connectivity to the CDN-servers in order for the product to download/stream music. | Fails if the player can't connect to the endpoints.
ERROR_PING_CDN_IP | Checks connectivity rate to the CDN-servers in order for the product to have sufficient connectivity to guarantee download/stream music. | Fails if the player have a low success rate.
ERROR_PING_CERT | Checks if proxy is used. We do not support that. | Fails if proxy is found.    
ERROR_ONLINE_STATE | Checks online state | Fails if the player is offline/high amount of failing requests.
ERROR_PAIRED | Checks if player is paried | Fails if not paired.
ERROR_ACTIVE_SUBSCRIPTION | Checks if player have active subscription | Fails if inactice.  
ERROR_CHANNEL_ASSIGNED | Checks if any music is assigned | Fails if no music assigned
ERROR_DOWNLOADED_DATA | Checks downloaded data for the assigned music. | Fails if nothing is downloaded.
ERROR_NO_VOLUME | Checks the volume level | Fails if there is no volume level is zero.
ERROR_DISKCACHE_LOW | Checks free diskspace | Fails if free diskspace is below 1 GB.
ERROR_DISKCACHE_CRITICALLY_LOW | Checks free diskspace | Fails if free diskspace is below 256 MB.
ERROR_PAYMENT_EXPIRED | Check payment status | Fails if payment expired.
ERROR_DEPRECATED | Checks if players version is deprecated (6 months old) | Fails if deprecated.
ERROR_SOON_DEPRECATED | Checks if players version is soon to be deprecated (1 month prior to 6 months) | Fails if soon to be deprecated.
ERROR_CLOCK_WRONG | Check server time offset | Fails if server time offset differs +- 15 min

## Certification

### Background
* The below is applicable to the Soundtrack SDK, not the Soundtrack API
* All applications built using the Soundtrack SDK are to be certified by Soundtrack prior to being shared with customers
* In order to conduct the certification, you need, in addition to the credentials used in the SDK, a Soundtrack test account (subject to Soundtrack T&C and provided by Soundtrack)
* The certification process is developed from a customer experience standpoint. Ease of use is critical

### Definitions
* **Pair** is Soundtrack lingo for connecting the Application with Soundtrack using the Device ID
* **Device ID** is the Soundtrack generated ID needed for pairing the Application with Soundtrack's services
* **SDK** is the APIs and binaries provided by Soundtrack
* **Application** is the partner built application that contains the SDK

### Certification process
* Please note that you need to provide Soundtrack with two pcs of the hardware in order for Soundtrack to do the certification
* Any changes to the hardware will prompt a new certification process
* All tests should pass on a 0.5 Mbps network, unless anything else is stated in the instructions
* The partner shall recommend an SD-card to it's client (unless internal storage is used). The same SD-card shall be used for the certification
* The certification shall be as close to the real environment as possible, so if the platform's normal state is e.g. to have two other applications running at the same time, these shall be running during the certification as well

Type | Test case | Instructions | Expected behaviour
--- | --- | --- | ---
Setup | 1.1 | Start the device. | - The device should be intuitive to install and come with necessary instructions. - It should be simple to start the Application.
. | 1.2 | Ensure Application has connectivity | Clearly stated whether or not the Application can access Soundtrack
. | 1.3 | Find the device ID | - The device ID shall be easy to find. - If the device ID is generated in the Application, this generation should take less than one second. - The device ID shall not be generated more than once (not needed, since the request always will give the same response). - When creating the device ID, the correct label and description should be set. - Clearly stated what the device ID is used for and how to use it in order to connect the Application to Soundtrack. - The `label`-field used when creating the device shall be correct.
. | 1.4 | Pair the Application in Soundtrack and assign a soundtrack | Music should start playing within 2 minutes.
. | 1.5 | Ensure config variable `bandwidth_limitation_kbps` is set to at least 2000 kbps. | Music playing.
Actions in web interface (www.soundtrackyourbrand.com) | 2.1 | Skip track | Track skipped
. | 2.2 | Press pause | Track paused
. | 2.3 | Press play | Track resumed
. | 2.4 | Increase volume to max | Volume set to max
. | 2.5 | Decrease volume to zero | Volume set to minimum
. | 2.6 | Change soundtrack | New soundtrack should start playing after the current track is done
Playback (offline) | 3.1 | Cut off internet access (e.g. by plugging out the ethernet cable) when the device is powered on | Music should keep playing
. | 3.2 | Start device without internet access | Music should keep playing
. | 3.3 | Enable internet again | - Music should keep playing. - Device should go online in Soundtrack.
Playback - poor internet connectivity _(ensure that you have music cached offline for this step)_ | 4.1 | Set up network according to profile "100% Loss". See below. | Music should keep playing
. | 4.2 | Set up network according to profile "High latency DNS". See below. | Music should keep playing
. | 4.3 | Set up network according to profile "Very bad network". See below. | Music should keep playing
. | 4.4 | Set up network according to profile "Edge". See below. | Music should keep playing
Updater | 5.1 | None | - Contacts Soundtrack's update service every 15 minutes (if the device is online). - If new SDK available: download. -When new SDK downloaded: quit Application at end of next song. - If installation fails: fall back to previous SDK version
Watchdog | 6.1 | Make sure the application is running, then ask Soundtrack to simulate a crash remotely | - Application should be restarted. - Music should start playing within 30 seconds.
Test latency on actions _(implementation of these actions are not mandatory)_ | 7.1 | Skip track (e.g. using a button on the device or in the application) | Track changed within 1 second
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

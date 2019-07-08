---
layout: post
title: "Designing ShareVitalSigns for iOS"
excerpt_separator: "<!--more-->"
tags:
  - ShareVitalSigns
  - iOS
  - LambdaNative
  - LNhealth
---

_For usage notes, see the LNhealth wiki page on [SVS for iOS](https://github.com/part-cw/LNhealth/wiki/Index-of-Module-sharevitalsigns-for-ios). This post is cross-posted to the LNhealth wiki at [Designing ShareVitalSigns for iOS](https://github.com/part-cw/LNhealth/wiki/Designing-ShareVitalSigns-for-iOS)._

# A Primer on ShareVitalSigns
ShareVitalSigns is a method for transmitting vital sign data between [LambdaNative](https://github.com/part-cw/lambdanative) apps on Android and consists of a [`sharevitalsigns`](https://github.com/part-cw/LNhealth/tree/master/modules/sharevitalsigns) LambdaNative module and an [Android `.jar` library](https://github.com/part-cw/sharevitalsigns) containing a single `ShareVitalSigns` class containing methods to extract, store, and transmit the data. The workflow from a high-level Android perspective is as follows:

<!--more-->

1. The requester app creates an Intent, adds the code of the desired vital sign along with other data as extras, and sends a start Activity request with the Intent.
2. The provider app, having the correct Intent filters, is initialized and declares the codes of the vital signs it can provide.
3. The provider app retrieves the requested vital sign code and compares it with its own vital sign codes. If they do no match, the app finishes its own Activity, returning to the requester app.
4. If the vital sign codes do match, the user now interacts with the provider app to produce vital sign data, in the form of either a string or a number with a confidence percentage out of 100 (also referred to here as a quality measure). 
5. The provider app adds these data to an Intent as extras, sets it as the result, and finishes its own Activity, returning to the requester app.
6. In the meantime, the requester app has been regularly polling for results. Once the result has been returned, it can retrieve the vital sign data for use.

Both the requester and provider apps have a ShareVitalSigns Java object used to store vital sign codes and vital sign data before transmission, create request and provision Intents, and parse and store data from request and provision Intents, while the Java Activity additions in the ShareVitalSigns module is responsible for calling the methods in the ShareVitalSigns objects, starting and finishing Activities with the created Intents, and checking the validity of vital sign requests and results.

# Data Sharing on iOS
The following is the Android user workflow we want to emulate in iOS:

1. The user, being asked to provide a vital sign, taps on a button in the requester app.
2. The provider app opens immediately, and the user can interact with the app to produce a vital sign.
3. The user taps on a button in the requester app to signal that the interaction has completed.
4. The requester app opens immediately where it was left off, and automatically makes use of the vital sign data if it has been produced.

[This](http://www.enharmonichq.com/sharing-data-locally-between-ios-apps/) data-sharing tutorial provides some suggestions on how this behaviour might be implemented. A number of common solutions are not suitable for the following reasons:

* `UIDocumentInteractionController` and `UIActivityViewController` require additional user interaction and knowing what app would provide the correct vital sign.
* `GenericKeychain` requires that both the requester and provider apps have the same app ID prefix, while we would like to allow for apps created by different developers to be able to communicate with each other via ShareVitalSigns.
* [Universal Links](https://developer.apple.com/library/archive/documentation/General/Conceptual/AppSearch/UniversalLinks.html) are only available in iOS 9+, while LambdaNative officially supports devices on iOS 6+.

URL schemes are the best remaining viable solution. A URL comes in the form `<scheme>://?<var1>=<val1>&<var2>=<val2>&...&<varn>=<valn>`, where `<scheme>` is registered in an app's `Info.plist` file to indicate that it can open URLs with this scheme, and each `<vari>`, `<vali>` are the transmitted data, with the value `vali` associated with the variable `vari`. Note that the `query` property of `NSURL` returns the entire string after `?`, so the data would have to be manually parsed.

Although we have simple data that conforms to this key-value model, SVS in the future may want to adopt more data types than only integers and strings. To avoid excessive manual serialization and deserialization of data, which can be complex and error-prone when developing, data is transmitted as suggested in the tutorial through `UIPasteboard`. This involves inserting data objects into a custom pasteboard (not the general pasteboard, where user copy/paste takes place) and using custom URL schemes only to open the provider and requester apps.

# Implementation Details
Various portions of the [`IOS_objc_additions`](https://github.com/part-cw/LNhealth/blob/master/modules/sharevitalsigns/IOS_objc_additions) file in the `sharevitalsigns` module are discussed in further detail below.

## Vital Sign Codes
As with SVS on Android, basic vital sign codes are assigned in powers of two, allowing for combinations of vital signs to be requested via bitwise `OR` of multiple codes. A provider must provide _at least_ the vital signs that are requested and no less, so to verify that the provider can do so, we check that `providerCode & requesterCode >= requesterCode`. Again, similarly to Android, when the requester polls for the vital sign, only the vital sign with the largest code is returned, and the requester must poll for other vital signs separately. This is done by taking the binary exponent of the vital sign code, which indexes the vital signs, as will be discussed in the next section.

Along with the codes, each basic vital sign and each preassigned combination of vital signs is associated with a URL scheme of the form `svs-<vitalsign>`. The requester app will open the URL `<scheme>://`, and the provider app with this scheme registered will be launched. Note that according to the [documentation](https://developer.apple.com/library/archive/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/Inter-AppCommunication/Inter-AppCommunication.html#//apple_ref/doc/uid/TP40007072-CH6-SW10), 

> If more than one third-party app registers to handle the same URL scheme, there is currently no process for determining which app will be given that scheme.

## Data in the Pasteboard
Data shared between the provider and the requester is saved in an `NSDictionary` in a custom pasteboard under the name `svsPasteboard`. The `items` property of `UIPasteboard` is an array of dictionaries mapping from representation type names (often in the form of UTIs) to stored data. Because the stored data must be an `NSData` object, we need to convert `NSDictionary` to and from it before assigning. The following replaces and retrieves all pasteboard items with a single encoded `NSDictionary`:

```objc
NSString *const name = @"svsPasteboard";

// put dictionary into pasteboard
pasteboard.items = @[@{name: [NSKeyedArchiver archivedDataWithRootObject:dictionary]}];

// get dictionary from pasteboard
NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:board.items[0][name]]
```

The requester's sign and state and the provider's success code are stored under the keys `sign`, `state`, and `success`, respectively, while vital sign values and quality measures are stored under the keys `<sign-exp>` and `<sign-exp>-qual`, respectively, where `<sign-exp>` is the integral unbiased binary exponent of the vital sign code calculated using `ilogb`. Although there's no need to store vital signs indexed by their binary exponent because we're using a dictionary as our primary data structure and not a fixed-size array, this facilitates vital sign retrieval for combined vital signs, since for instance `RRATE == RR | RRTAPS == 66` and `RRTAPS == 64` will both resolve to the index `6` and retrieve the `RRTAPS` vital sign value.

Again, as with SVS on Android, the requester app will need to repeatedly poll for the vital sign by calling the retrieval function, which returns different values depending on the presence and value of the success code and the vital sign.

```
| Success code? | Code | Vital sign? | Return value     |
|===============|======|=============|==================|
| No            | _    | _           |   0   or `""`    | (in progress)
| Yes           | 0    | _           |  -1   or `NULL`  | (invalid)
| Yes           | 1    | No          |  -1   or `NULL`  | (invalid)
| Yes           | 1    | Yes         | `int` or `char*` | (vital sign)
```

## Alert Dialogs
In SVS for Android, there are two scenarios in which a toast message is triggered: when an Intent fails to open due to a missing provider app, and when a provider app does not provide all of the requested vital signs. Since iOS has no toast messages, alerts are used in its place. In the first error case, we remain in the requester app, but in the second case, the provider app has been opened, so we need to automatically return to the requester app after the user closes the alert by opening the provider's URL, as described in the next section. This is done by assigning a `UIAlertViewDelegate` that calls the appropriate callback.

```objc
@interface AlertViewCancelDelegate : NSObject<UIAlertViewDelegate>
@end

@implementation AlertViewCancelDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index {
    ios_finishVitalSign(false); // return to requester with failure code
}
@end
```

## Bundle ID
To return to the requester app, it must register a unique URL scheme that the provider app can then open. For simplicity, this URL scheme is set to be the same as its bundle ID in `Info.plist`, since the bundle ID can be retrieved when an app first launches or when it resumes:

```objc
extern NSString *sourceBundleID;

// Scheme EVENT_INIT sent at the end of this method
- (BOOL)application:(UIApplication *)application
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    sourceBundleID = [[launchOptions objectForKey:UIApplicationLaunchOptionsSourceApplicationKey] copy];
    ...
}

// Scheme EVENT_RESUME sent in applicationDidBecomeActive:,
// which is called after this method
- (BOOL)application:(UIApplication *)application 
        openURL:(NSURL *)url 
        sourceApplication:(NSString *)sourceApplication 
        annotation:(id)annotation {
    ...
    sourceBundleID = [sourceApplication copy];
    return YES;
}
```

If desired, the URL that the provider is meant to open can also be retrieved in these two methods using the `UIApplicationLaunchOptionsURLKey` key and the `url` argument, respectively.

See Figures 6-1 and 6-2 [here](https://developer.apple.com/library/archive/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/Inter-AppCommunication/Inter-AppCommunication.html#//apple_ref/doc/uid/TP40007072-CH6-SW10) for more details on the iOS application lifecycle.

# Expanding ShareVitalSigns
As ShareVitalSigns grows, the code itself will need to be expanded. Below is an outline of what would need to be changed.

* To add a new vital sign or a new combination of vital signs, add an entry to the end of the `VitalSign` enum, a corresponding URL scheme, and a case in `getURLScheme` to map the code to the scheme.
* To add a new extra datum, add a global field and a constant name for it, a corresponding argument and assignment line to the `addExtras` function, an entry in the dictionary assigned to the pasteboard in the `requestVitalSign` function, and a retrieval function in the "Provider methods" section.
* To add a new vital sign data type, there needs to be corresponding `passVitalSign` and `retrieveVitalSign` functions.

# Possible Improvements
The most obvious disadvantage of using a pasteboard to transfer information between apps is that, as opposed to Android's Intent extras, pasteboards are inherently public. Any app that knows the name of a pasteboard can then access and modify its contents. Although pasteboards cannot be accessed by background apps and in our workflow we go directly from the provider app to the requester app, since the pasteboard is not wiped until a second vital signs request is sent to allow for the requester app to refetch values if needed, if the user later opens a malicious app specifically targeting SVS, it will be able to fetch whatever data was passed between the provider and requester apps. This scenario is very unlikely, but if it is considered to be a significant threat, it could be mitigated using standard key encryption methods between the provider and requester apps to either generate a unique pasteboard name only they know about (i.e. security through obscurity), transferred via URL, or to encrypt the transferred data itself.

Because we need to support iOS 6+, many of the methods used are currently deprecated. If the supported iOS verion is raised, the following can be replaced:

* `UIPasteboard setPersistent:` (<= 10.0) ->
  Universal Links (>= 9.0)
* `UIApplicationDelegate application:openURL:sourceApplication:annotation:` (<= 9.0) ->
  `UIApplicationDelegate application:openURL:options:` (>= 9.0)
* `UIApplication openURL:` (<= 10.0) ->
  `UIApplication openURL:options:completionHandler:` (>= 10.0)
* `UIAlertView` and `UIAlertViewDelegate` (<= 9.0) ->
  `UIAlertController` (>= 8.0)
* `NSKeyedArchiver archivedDataWithRootObject:` (<= 12.0) ->
  `NSKeyedArchiver archivedDataWithRootObject:requiringSecureCoding:error:` (>= 11.0)
* `NSKeyedUnarchiver unarchiveObjectWithData:` (<= 12.0) ->
  `NSKeyedUnarchiver unarchivedObjectOfClass:fromData:error:` (>= 11.0)

# Resources
* "ShareVitalSigns Usage on iOS" from the LNhealth repository wiki: <https://github.com/part-cw/LNhealth/wiki/Index-of-Module-sharevitalsigns-for-ios>
* "Tutorial: Sharing Data Locally Between iOS Apps" by Dillan Laughlin: <http://www.enharmonichq.com/sharing-data-locally-between-ios-apps/>
* "Inter-App Communication" from Apple's Documentation Archive: <https://developer.apple.com/library/archive/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/Inter-AppCommunication/Inter-AppCommunication.html>
* "Support Universal Links" from Apple's Documentation Archive: <https://developer.apple.com/library/archive/documentation/General/Conceptual/AppSearch/UniversalLinks.html>
* PART repositories: [lambdanative](https://github.com/part-cw/lambdanative), [LNhealth](https://github.com/part-cw/LNhealth), and [sharevitalsigns](https://github.com/part-cw/sharevitalsigns).

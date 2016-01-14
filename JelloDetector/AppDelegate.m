//  AppDelegate.m

#import "AppDelegate.h"
#import <CoreServices/CoreServices.h>

#define MAXCHARS 4
u_int numMatches = 0;
unichar jello[] = {'j', 'e', 'l', 'o'};

// Takes care of locking the screen
OSStatus MDSendAppleEventToSystemProcess(AEEventID eventToSendID) {
    AEAddressDesc                    targetDesc;
    static const ProcessSerialNumber kPSNOfSystemProcess = {0, kSystemProcess};
    AppleEvent                       eventReply          = {typeNull, NULL};
    AppleEvent                       eventToSend         = {typeNull, NULL};
    
    OSStatus status = AECreateDesc(typeProcessSerialNumber,
                                   &kPSNOfSystemProcess, sizeof(kPSNOfSystemProcess), &targetDesc);
    
    if ( status != noErr ) return status;
    
    status = AECreateAppleEvent(kCoreEventClass, eventToSendID,
                                &targetDesc, kAutoGenerateReturnID, kAnyTransactionID, &eventToSend);
    
    AEDisposeDesc(&targetDesc);
    
    if ( status != noErr ) return status;
    
    status = AESendMessage(&eventToSend, &eventReply,
                           kAENormalPriority, kAEDefaultTimeout);
    
    AEDisposeDesc(&eventToSend);
    if ( status != noErr ) return status;
    AEDisposeDesc(&eventReply);
    return status;
}

// Turns the screen saver on by sending the computer to sleep
void lockScreen() {
    MDSendAppleEventToSystemProcess(kAESleep);
}

// Input: the last key to be pressed.
// Moves the pointer of the state machine that records what character we're looking for next.
// If we've reached the end of the state machine (i.e. the user has entered 'jello', return true, otherwise false.
BOOL checkForJello(unichar character) {
    // Allow infinite # of repeats of the previous character that we're looking for.
    if(numMatches > 0 && character == jello[numMatches-1]) {
        return false;
    }
    
    // Support backspaces
    if (character == 0x7f && numMatches > 0) {
        numMatches--;
        return false;
    }
    
    if (character == jello[numMatches]) {
        numMatches++;
        // Have we reached the end of the state machine yet?
        if(numMatches == MAXCHARS) {
            numMatches = 0;
            return true;
        }
    } else {
        // They entered some other character, so reset the state machine.
        numMatches = 0;
    }
    return false;
}


// Apps that listen to global keydown events MUST be enabled in Security + Privacy Prefs > Assistive devices otherwise
// they won't receive any events at all.
// This check wil automatically throw up the prompt for you if it's not enabled, but after manually enabling it
// you'll have to restart the app.
// 10.9+ only, see this url for compatibility:
// http://stackoverflow.com/questions/17693408/enable-access-for-assistive-devices-programmatically-on-10-9
BOOL checkAccessibility() {
    NSDictionary* opts = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    return AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)opts);
}


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSLog(@"Starting up!");
    if (checkAccessibility()) {
        NSLog(@"Accessibility Enabled");
    } else {
        NSLog(@"Accessibility Disabled");
    }
    // register for keys throughout the device...
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask
                                           handler:^(NSEvent *event) {
                                               
                                               NSString *chars = [[event characters] lowercaseString];
                                               unichar character = [chars characterAtIndex:0];
                                               
                                               // lowercase it if necessary
                                               if(character >= 'A' && character <= 'Z') {
                                                   character += 'a' - 'A';
                                               }
                                               if (checkForJello(character)) {
                                                   // NSLog(@"Jello detected! Calling lockScreen!");
                                                   lockScreen();
                                               }
                                               //NSLog(@"keydown globally! Which key? This key: %x %c", character, character);
                                               
                                           }];

}
/*
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
*/

@end

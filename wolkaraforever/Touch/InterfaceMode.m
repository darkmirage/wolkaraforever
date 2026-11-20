#import "InterfaceMode.h"
#import <UIKit/UIKit.h>
#include <string.h>
#include <sys/utsname.h>

NSString *const AKInterfaceModeDefaultsKey = @"WolkaraForeverInterfaceModeV1";
NSString *const AKInterfaceModeIPadOS = @"ipados";
NSString *const AKInterfaceModeIOS = @"ios";
NSString *const AKInterfaceModeIOSDuo = @"iosduo";
NSString *const AKInterfaceModeAuto = @"auto";

/// Read on every call rather than cached: the launcher writes the key before a
/// guest starts, and a fixture writes it between two guests in one process, so a
/// cached copy would make the second read answer for the first.
///
/// A phone that never chose follows its own hardware: the iPad interface on a phone was never a
/// choice anyone made there, only what the key's absence used to mean. A tablet that never
/// chose keeps Standard, which is also what "auto" resolves to on it.
static NSString *AKInterfaceModeStored(void) {
    id value = [NSUserDefaults.standardUserDefaults objectForKey:AKInterfaceModeDefaultsKey];
    if ([value isKindOfClass:NSString.class]) return [(NSString *)value lowercaseString];
    return UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone ? AKInterfaceModeAuto : nil;
}

/// The device's own class, and the only thing "auto" reads: a tablet (and anything else) is
/// iPadOS, a phone is iOS, and the Duo is its own name so the selector can show it. Not a screen
/// size, not a gamepad preference, and not an add-on: the hardware, exactly.
static BOOL AKInterfaceModeHardwareIsDuo(void) {
#if TARGET_OS_SIMULATOR
    NSString *name = NSProcessInfo.processInfo.environment[@"SIMULATOR_DEVICE_NAME"];
    return [name isKindOfClass:NSString.class] && [name containsString:@"Duo"];
#else
    struct utsname system;
    if (uname(&system) != 0) return NO;
    return strcmp(system.machine, "iPhone19,4") == 0;
#endif
}

static NSString *AKInterfaceModeHardwareName(void) {
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) return AKInterfaceModeIPadOS;
    return AKInterfaceModeHardwareIsDuo() ? AKInterfaceModeIOSDuo : AKInterfaceModeIOS;
}

BOOL AKInterfaceModeIsMobile(void) {
    NSString *stored = AKInterfaceModeStored();
    if ([stored isEqual:AKInterfaceModeIOS] || [stored isEqual:AKInterfaceModeIOSDuo]) return YES;
    if ([stored isEqual:AKInterfaceModeAuto]) return ![AKInterfaceModeHardwareName() isEqual:AKInterfaceModeIPadOS];
    // "ipados", nothing on a tablet, or something a hand edit invented: Standard.
    return NO;
}

BOOL AKInterfaceModeIsAutomatic(void) {
    return [AKInterfaceModeStored() isEqual:AKInterfaceModeAuto];
}

NSString *AKInterfaceModeAutomaticName(void) {
    return AKInterfaceModeHardwareName();
}

NSString *AKInterfaceModeName(void) {
    NSString *stored = AKInterfaceModeStored();
    if ([stored isEqual:AKInterfaceModeIOS]) return AKInterfaceModeIOS;
    if ([stored isEqual:AKInterfaceModeIOSDuo]) return AKInterfaceModeIOSDuo;
    if ([stored isEqual:AKInterfaceModeAuto]) return AKInterfaceModeHardwareName();
    return AKInterfaceModeIPadOS;
}

NSString *AKInterfaceModeStoredName(void) {
    NSString *stored = AKInterfaceModeStored();
    if ([stored isEqual:AKInterfaceModeIOS] || [stored isEqual:AKInterfaceModeIOSDuo] ||
        [stored isEqual:AKInterfaceModeAuto]) return stored;
    return AKInterfaceModeIPadOS;
}

// Implementation that wraps [FIRApp configure] in @try/@catch to avoid aborting the app
#import "FirebaseConfigurator.h"
#import <FirebaseCore/FirebaseCore.h>

BOOL FIRAppConfigureSafe(NSError **_Nullable error) {
  @try {
    if ([FIRApp defaultApp] == nil) {
      [FIRApp configure];
    }
    return YES;
  } @catch (NSException *exception) {
    if (error) {
      NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: exception.reason ?: @"Unknown exception during FIRApp.configure()" };
      *error = [NSError errorWithDomain:@"com.smartfactory.firebase" code:1 userInfo:userInfo];
    }
    NSLog(@"FirebaseConfigurator: caught exception while configuring Firebase: %@", exception);
    return NO;
  }
}

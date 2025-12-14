// Objective-C helper to safely call FIRApp.configure() and catch ObjC exceptions
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Returns YES on success. If NO, *error will contain an NSError describing the exception.
BOOL FIRAppConfigureSafe(NSError **_Nullable error);

NS_ASSUME_NONNULL_END

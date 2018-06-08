@interface PSSystemConfigurationDynamicStoreWifiWatcher : NSObject

+ (instancetype)sharedInstance;

- (NSDictionary *)wifiConfig;

@end
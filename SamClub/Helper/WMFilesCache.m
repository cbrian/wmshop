//
//  WMFilesCache.m
//

#import <UIKit/UIKit.h>
#import "WMFilesCache.h"

const NSString * kWMPathMapDictonaryKey = @"WM_PATH_MAP_KEY";

@implementation WMFilesCache
{
    NSString *_cacheNamespace;
}

#pragma mark - Supporting Methods

///
/// Gets the base NSCachesDirectory path
///
+(NSString *)cachesDirectoryName
{
    static NSString *cachePath = nil;
    if(!cachePath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        cachePath = [paths objectAtIndex:0];
    }
    
    return cachePath;
}

///
/// Builds paths for identifiers in the cache directory
///
+(NSString *)pathForName:(NSString *)name
{
    NSString *cachePath = [WMFilesCache cachesDirectoryName];
    NSString *path = [cachePath stringByAppendingPathComponent:name];
    return path;
}

#pragma mark - NSData Cache methods

///
/// Saves the given data to the cache directory
///
+(void)saveToCacheDirectory:(NSData *)data withName:(NSString *)name
{
    NSString *path = [WMFilesCache pathForName:name];
    [data writeToFile:path atomically:YES];

#if EnableCachedFileMapDictionaryFromNSUserDefaults
    // TODO: Check here again for additional work
    NSMutableDictionary *wmCacheFileMapDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kWMPathMapDictonaryKey];
    if (lastReadRow && !wmCacheFileMapDictionary)
    {   // Consider to backup all files per page in one save op instead of one row at a time
        wmCacheFileMapDictionary = [[NSMutableDictionary  alloc] init];
        [wmCacheFileMapDictionary setObject:name forKey:path];
        [[NSUserDefaults standardUserDefaults] setObject:wmCacheFileMapDictionary forKey:kWMPathMapDictonaryKey];
    }
    else
    {
        [wmCacheFileMapDictionary setObject:name forKey:path];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
}

///
/// Returns the cached data with the given name; otherwise, returns false
///
+(NSData *)cachedDataWithName:(NSString *)name
{
#if EnableCachedFileMapDictionaryFromNSUserDefaults
    NSDictionary *wmCacheFileMapDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kWMPathMapDictonaryKey];
    NSString *path = wmCacheFileMapDictionary[name];
#else
    NSString *path = [WMFilesCache pathForName:name];
#endif
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if(fileExists) {
        
        NSData *data = [NSData dataWithContentsOfFile:path];
        return data;
        
    } else {
        return nil;
    }
}

#pragma mark - UIImage cache methods

///
/// Saves the given image to the cache directory using the given name identifier
///
+(void)saveImageToCacheDirectory:(UIImage *)image withName:(NSString *)name
{
    NSData *imgData = UIImagePNGRepresentation(image);
    [WMFilesCache saveToCacheDirectory:imgData withName:name];
}

///
/// Returns the cached image if found; otherwise, returns nil
///
+(UIImage *)cachedImageWithName:(NSString *)name
{
    NSData *data = [WMFilesCache cachedDataWithName:name];
    
    if(data) {
        
        UIImage *img = [UIImage imageWithData:data];
        return img;
        
    } else {
        
        return nil;
    }
}

#pragma mark - Instance Methods

-(NSString *)applyNamespaceToName:(NSString *)name
{
    return [_cacheNamespace stringByAppendingString:name];
}

-(id)initWithNamespace:(NSString *)cacheNamespace
{
    self = [super init];
    
    if(self) {
        _cacheNamespace = cacheNamespace;
    }
    
    return self;
}

-(void)saveToCacheDirectory:(NSData *)data withName:(NSString *)name
{
    name = [self applyNamespaceToName:name];
    [WMFilesCache saveToCacheDirectory:data withName:name];
}

-(NSData *)cachedDataWithName:(NSString *)name
{
    name = [self applyNamespaceToName:name];
    return [WMFilesCache cachedDataWithName:name];
}

-(void)saveImageToCacheDirectory:(UIImage *)image withName:(NSString *)name
{
    name = [self applyNamespaceToName:name];
    [WMFilesCache saveImageToCacheDirectory:image withName:name];
}

-(UIImage *)cachedImageWithName:(NSString *)name
{
    name = [self applyNamespaceToName:name];
    return [WMFilesCache cachedImageWithName:name];
}

@end

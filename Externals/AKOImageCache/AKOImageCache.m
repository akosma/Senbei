//
//  AKOImageCache.m
//  AKOLibrary
//
//  Created by Adrian on 1/28/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import "AKOImageCache.h"
#import "SynthesizeSingleton.h"

@interface AKOImageCache ()

- (void)addImageToMemoryCache:(UIImage *)image withKey:(NSString *)key;
- (NSString *)getCacheDirectoryName;
- (NSString *)getFileNameForKey:(NSString *)key;

@end


@implementation AKOImageCache

#pragma mark -
#pragma mark Singleton definition

SYNTHESIZE_SINGLETON_FOR_CLASS(AKOImageCache)

#pragma mark -
#pragma mark Constructor and destructor

- (id)init
{
    if (self = [super init])
    {
        _keyArray = [[NSMutableArray alloc] initWithCapacity:MEMORY_CACHE_SIZE];
        _memoryCache = [[NSMutableDictionary alloc] initWithCapacity:MEMORY_CACHE_SIZE];
        _fileManager = [NSFileManager defaultManager];
        
        NSString *cacheDirectoryName = [self getCacheDirectoryName];
        BOOL isDirectory = NO;
        BOOL folderExists = [_fileManager fileExistsAtPath:cacheDirectoryName isDirectory:&isDirectory] && isDirectory;

        if (!folderExists)
        {
            NSError *error = nil;
            [_fileManager createDirectoryAtPath:cacheDirectoryName withIntermediateDirectories:YES attributes:nil error:&error];
            [error release];
        }
    }
    return self;
}

- (void)dealloc
{
    [_keyArray release];
    [_memoryCache release];
    [super dealloc];
}

#pragma mark -
#pragma mark Public methods

- (UIImage *)imageForKey:(NSString *)key
{
    UIImage *image = [_memoryCache objectForKey:key];
    if (image == nil && [self imageExistsInDisk:key])
    {
        NSString *fileName = [self getFileNameForKey:key];
        NSData *data = [NSData dataWithContentsOfFile:fileName];
        image = [[[UIImage alloc] initWithData:data] autorelease];
        [self addImageToMemoryCache:image withKey:key];
    }
    return image;
}

- (BOOL)hasImageWithKey:(NSString *)key
{
    BOOL exists = [self imageExistsInMemory:key];
    if (!exists)
    {
        exists = [self imageExistsInDisk:key];
    }
    return exists;
}

- (void)storeImage:(UIImage *)image withKey:(NSString *)key
{
    if (image != nil && key != nil)
    {
        NSString *fileName = [self getFileNameForKey:key];
        [UIImagePNGRepresentation(image) writeToFile:fileName atomically:YES];
        [self addImageToMemoryCache:image withKey:key];
    }
}

- (void)removeImageWithKey:(NSString *)key
{
    if ([self imageExistsInMemory:key])
    {
        NSUInteger index = [_keyArray indexOfObject:key];
        [_keyArray removeObjectAtIndex:index];
        [_memoryCache removeObjectForKey:key];
    }

    if ([self imageExistsInDisk:key])
    {
        NSError *error = nil;
        NSString *fileName = [self getFileNameForKey:key];
        [_fileManager removeItemAtPath:fileName error:&error];
        [error release];
    }
}

- (void)removeAllImages
{
    [_memoryCache removeAllObjects];
    
    NSString *cacheDirectoryName = [self getCacheDirectoryName];
    NSArray *items = [_fileManager directoryContentsAtPath:cacheDirectoryName];
    for (NSString *item in items)
    {
        NSString *path = [cacheDirectoryName stringByAppendingPathComponent:item];
        NSError *error = nil;
        [_fileManager removeItemAtPath:path error:&error];
        [error release];
    }
}

- (void)removeAllImagesInMemory
{
    [_memoryCache removeAllObjects];
}

- (void)removeOldImages
{
    NSString *cacheDirectoryName = [self getCacheDirectoryName];
    NSArray *items = [_fileManager directoryContentsAtPath:cacheDirectoryName];
    for (NSString *item in items)
    {
        NSString *path = [cacheDirectoryName stringByAppendingPathComponent:item];
        NSDictionary *attributes = [_fileManager attributesOfItemAtPath:path error:nil];
        NSDate *creationDate = [attributes valueForKey:NSFileCreationDate];
        if (abs([creationDate timeIntervalSinceNow]) > IMAGE_FILE_LIFETIME)
        {
            NSError *error = nil;
            [_fileManager removeItemAtPath:path error:&error];
        }
    }
}

- (BOOL)imageExistsInMemory:(NSString *)key
{
    return ([_memoryCache objectForKey:key] != nil);
}

- (BOOL)imageExistsInDisk:(NSString *)key
{
    NSString *fileName = [self getFileNameForKey:key];
    return [_fileManager fileExistsAtPath:fileName];
}

- (NSUInteger)countImagesInMemory
{
    return [_memoryCache count];
}

- (NSUInteger)countImagesInDisk
{
    NSString *cacheDirectoryName = [self getCacheDirectoryName];
    NSArray *items = [_fileManager directoryContentsAtPath:cacheDirectoryName];
    return [items count];
}

#pragma mark -
#pragma mark Private methods

- (void)addImageToMemoryCache:(UIImage *)image withKey:(NSString *)key
{
    // Add the object to the memory cache for faster retrieval next time
    [_memoryCache setObject:image forKey:key];
    
    // Add the key at the beginning of the keyArray
    [_keyArray insertObject:key atIndex:0];

    // Remove the first object added to the memory cache
    if ([_keyArray count] > MEMORY_CACHE_SIZE)
    {
        // This is the "raison d'etre" de keyArray:
        // we use it to keep track of the last object
        // in it (that is, the first we've inserted), 
        // so that the total size of objects in memory
        // is never higher than MEMORY_CACHE_SIZE.
        NSString *lastObjectKey = [_keyArray lastObject];
        [_memoryCache removeObjectForKey:lastObjectKey];
        [_keyArray removeLastObject];
    }    
}

- (NSString *)getCacheDirectoryName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *cacheDirectoryName = [documentsDirectory stringByAppendingPathComponent:CACHE_FOLDER_NAME];
    return cacheDirectoryName;
}

- (NSString *)getFileNameForKey:(NSString *)key
{
    NSString *cacheDirectoryName = [self getCacheDirectoryName];
    NSString *fileName = [cacheDirectoryName stringByAppendingPathComponent:key];
    return fileName;
}

@end

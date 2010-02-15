//
//  AKOImageCache.h
//  AKOLibrary
//
//  Created by Adrian on 1/28/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MEMORY_CACHE_SIZE 50
#define CACHE_FOLDER_NAME @"AKOImageCacheFolder"

// 10 days in seconds
#define IMAGE_FILE_LIFETIME 864000.0

@interface AKOImageCache : NSObject 
{
@private
    NSMutableArray *_keyArray;
    NSMutableDictionary *_memoryCache;
    NSFileManager *_fileManager;
    NSString *_cacheDirectoryName;
}

+ (AKOImageCache *)sharedAKOImageCache;

- (UIImage *)imageForKey:(NSString *)key;

- (BOOL)hasImageWithKey:(NSString *)key;

- (void)storeImage:(UIImage *)image withKey:(NSString *)key;

- (BOOL)imageExistsInMemory:(NSString *)key;

- (BOOL)imageExistsInDisk:(NSString *)key;

- (NSUInteger)countImagesInMemory;

- (NSUInteger)countImagesInDisk;

- (void)removeImageWithKey:(NSString *)key;

- (void)removeAllImages;

- (void)removeAllImagesInMemory;

- (void)removeOldImages;

@end

/*
     File: DirectoryWatcher.h 
 Abstract: 
 Object used to monitor the contents of a given directory by using
 "kqueue": a kernel event notification mechanism.
  
  Version: 1.4 
  
   
 Copyright (C) 2012 Apple Inc. All Rights Reserved. 
  
 */

#import <Foundation/Foundation.h>

@class DirectoryWatcher;

@protocol DirectoryWatcherDelegate <NSObject>
@required
- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher;
@end

@interface DirectoryWatcher : NSObject 
{
	id <DirectoryWatcherDelegate> __unsafe_unretained delegate;
    
	int dirFD;
    int kq;

	CFFileDescriptorRef dirKQRef;
}
@property (nonatomic, unsafe_unretained) id <DirectoryWatcherDelegate> delegate;

+ (DirectoryWatcher *)watchFolderWithPath:(NSString *)watchPath delegate:(id<DirectoryWatcherDelegate>)watchDelegate;
- (void)invalidate;
@end

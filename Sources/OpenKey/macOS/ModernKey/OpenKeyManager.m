//
//  OpenKeyManager.m
//  OpenKey
//
//  Created by Tuyen on 1/27/19.
//  Copyright © 2019 Tuyen Mai. All rights reserved.
//

#import "OpenKeyManager.h"
#include <sys/stat.h>

extern void OpenKeyInit(void);

extern CGEventRef OpenKeyCallback(CGEventTapProxy proxy,
                                  CGEventType type,
                                  CGEventRef event,
                                  void *refcon);

extern NSString* ConvertUtil(NSString* str);

@interface OpenKeyManager ()

@end

@implementation OpenKeyManager {

}
static BOOL _isInited = NO;

static CFMachPortRef      eventTap;
static CGEventMask        eventMask;
static CFRunLoopSourceRef runLoopSource;

+(BOOL)isInited {
    return _isInited;
}

+(BOOL)initEventTap {
    if (_isInited)
        return true;
    
    //init modernKey
    OpenKeyInit();
    
    // Create an event tap. We are interested in key presses.
    eventMask = ((1 << kCGEventKeyDown) |
                 (1 << kCGEventKeyUp) |
                 (1 << kCGEventFlagsChanged) |
                 (1 << kCGEventLeftMouseDown) |
                 (1 << kCGEventRightMouseDown) |
                 (1 << kCGEventLeftMouseDragged) |
                 (1 << kCGEventRightMouseDragged));
    
    eventTap = CGEventTapCreate(kCGSessionEventTap,
                                kCGHeadInsertEventTap,
                                0,
                                eventMask,
                                OpenKeyCallback,
                                NULL);
    
    if (!eventTap) {
        
        fprintf(stderr, "failed to create event tap\n");
        return NO;
    }
    
    _isInited = YES;
    
    // Create a run loop source.
    runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
    
    // Add to the current run loop.
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
    
    // Enable the event tap.
    CGEventTapEnable(eventTap, true);
    
    return YES;
}

+(BOOL)stopEventTap {
    if (_isInited) { //release all object
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
        CFRelease(runLoopSource);
        runLoopSource = nil;
        
        CFMachPortInvalidate(eventTap);
        CFRelease(eventTap);
        eventTap = nil;
        
        _isInited = false;
    }
    return YES;
}

+(void)reEnableEventTap {
    if (eventTap != nil) {
        CGEventTapEnable(eventTap, true);
    }
}

+(NSArray*)getTableCodes {
    return [[NSArray alloc] initWithObjects:
            @"Unicode",
            @"TCVN3 (ABC)",
            @"VNI Windows",
            @"Unicode tổ hợp",
            @"Vietnamese Locale CP 1258", nil];
}

+(NSString*)getBuildDate {
    return [NSString stringWithUTF8String:__DATE__];
}

#pragma mark -Convert feature
+(BOOL)quickConvert {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSString *htmlString = [pasteboard stringForType:NSPasteboardTypeHTML];
    NSString *rawString = [pasteboard stringForType:NSPasteboardTypeString];
    bool converted = false;
    if (htmlString != nil) {
        htmlString = ConvertUtil(htmlString);
        converted = true;
    }
    if (rawString != nil) {
        rawString = ConvertUtil(rawString);
        converted = true;
    }
    if (converted) {
        [pasteboard clearContents];
        if (htmlString != nil)
            [pasteboard setString:htmlString forType:NSPasteboardTypeHTML];
        if (rawString != nil)
            [pasteboard setString:rawString forType:NSPasteboardTypeString];
        
        return YES;
    }
    return NO;
}

+(void)showMessage:(NSWindow*)window message:(NSString*)msg subMsg:(NSString*)subMsg {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:msg];
    [alert setInformativeText:subMsg];
    [alert addButtonWithTitle:@"OK"];
    if (window) {
        [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
        }];
    } else {
        [alert runModal];
    }
}

#pragma mark -AutoUpdate feature

+(void)checkNewVersion:(NSWindow*)parent callbackFunc:(CheckNewVersionCallback) callback {
    NSURLSession *aSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/minhlu99/MOpenKey/main/version.json"];
    
    [[aSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback != nil) {
                callback();
            }
        });
        
        if (error != nil || ((NSHTTPURLResponse *)response).statusCode != 200 || data == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (parent != nil) {
                    [self showMessage:parent message:@"Không thể kiểm tra cập nhật" subMsg:@"Vui lòng kiểm tra lại kết nối mạng và thử lại sau."];
                }
            });
            return;
        }
        
        NSError *jsonError = nil;
        id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (![object isKindOfClass:[NSDictionary class]]) {
            return;
        }
        
        NSDictionary *results = (NSDictionary *)object;
        NSDictionary *ver = [results valueForKey:@"latestVersion"];
        NSString *versionName = [ver valueForKey:@"versionName"] ?: @"";
        NSString *versionCodeString = [ver valueForKey:@"versionCode"] ?: @"0";
        NSString *downloadUrl = [ver valueForKey:@"downloadUrl"] ?: @"";
        NSString *releaseUrl = [ver valueForKey:@"releaseUrl"] ?: @"https://github.com/minhlu99/MOpenKey/releases/latest";
        NSString *changelog = [ver valueForKey:@"changelog"] ?: @"";
        
        int versionCode = (int)[versionCodeString integerValue];
        int currentVersionCode = (int)[((NSString*)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]) integerValue];
        NSString *currentVersionName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"";
        
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL hasUpdate = (versionCode > currentVersionCode);
            [self handleUpdateResult:parent
                           hasUpdate:hasUpdate
                          newVersion:versionName
                          currentVer:currentVersionName
                         currentCode:currentVersionCode
                         downloadUrl:downloadUrl
                          releaseUrl:releaseUrl
                           changelog:changelog];
        });
    }] resume];
}

+(void)handleUpdateResult:(NSWindow*)parent
                hasUpdate:(BOOL)hasUpdate
               newVersion:(NSString*)newVersion
               currentVer:(NSString*)currentVer
              currentCode:(int)currentCode
              downloadUrl:(NSString*)downloadUrl
               releaseUrl:(NSString*)releaseUrl
                changelog:(NSString*)changelog {
    if (!hasUpdate) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Bạn đang dùng phiên bản mới nhất!"];
        [alert setInformativeText:[NSString stringWithFormat:@"MOpenKey %@ (build %d) là phiên bản mới nhất hiện tại.", currentVer, currentCode]];
        [alert addButtonWithTitle:@"OK"];
        if (parent) {
            [alert beginSheetModalForWindow:parent completionHandler:nil];
        } else {
            [alert runModal];
        }
        return;
    }
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:[NSString stringWithFormat:@"Đã có bản cập nhật MOpenKey %@ mới!", newVersion]];
    
    NSMutableString *info = [NSMutableString stringWithFormat:@"Phiên bản hiện tại: %@\nPhiên bản mới: %@\n", currentVer, newVersion];
    if (changelog.length > 0) {
        [info appendFormat:@"\nNội dung cập nhật:\n%@\n", changelog];
    }
    [info appendString:@"\nBạn có muốn tự động cập nhật ngay bây giờ không?"];
    [alert setInformativeText:info];
    
    [alert addButtonWithTitle:@"Cập nhật ngay"];
    [alert addButtonWithTitle:@"Xem trên GitHub"];
    [alert addButtonWithTitle:@"Để sau"];
    
    void (^actionHandler)(NSModalResponse) = ^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            [self performInAppUpdate:downloadUrl newVersion:newVersion window:parent];
        } else if (returnCode == NSAlertSecondButtonReturn) {
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:releaseUrl]];
        }
    };
    
    if (parent) {
        [alert beginSheetModalForWindow:parent completionHandler:actionHandler];
    } else {
        NSModalResponse res = [alert runModal];
        actionHandler(res);
    }
}

+(void)performInAppUpdate:(NSString*)downloadUrl newVersion:(NSString*)newVersion window:(NSWindow*)window {
    NSString *currentAppPath = [[NSBundle mainBundle] bundlePath];
    if ([currentAppPath hasPrefix:@"/Volumes/"]) {
        [self showMessage:window
                  message:@"Không thể cập nhật từ đĩa ảo DMG"
                   subMsg:@"Vui lòng kéo MOpenKey vào thư mục /Applications (Ứng dụng) trước khi sử dụng tính năng cập nhật tự động."];
        return;
    }
    
    if (downloadUrl.length == 0) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/minhlu99/MOpenKey/releases/latest"]];
        return;
    }
    
    NSAlert *progressAlert = [[NSAlert alloc] init];
    [progressAlert setMessageText:@"Đang tải bản cập nhật MOpenKey..."];
    [progressAlert setInformativeText:[NSString stringWithFormat:@"Đang tải MOpenKey %@ từ GitHub. Vui lòng đợi trong giây lát...", newVersion]];
    
    NSProgressIndicator *indicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 300, 20)];
    [indicator setIndeterminate:YES];
    [indicator startAnimation:nil];
    [progressAlert setAccessoryView:indicator];
    
    if (window) {
        [progressAlert beginSheetModalForWindow:window completionHandler:nil];
    }
    
    NSURL *url = [NSURL URLWithString:downloadUrl];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (error != nil || ((NSHTTPURLResponse*)response).statusCode != 200 || location == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (window && window.attachedSheet) {
                    [window endSheet:window.attachedSheet];
                }
                [self showMessage:window message:@"Cập nhật thất bại" subMsg:@"Không thể tải về tệp tin cập nhật. Vui lòng thử lại sau hoặc tải thủ công trên GitHub."];
            });
            return;
        }
        
        NSString *tempDir = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"MOpenKey_Update_%@", [[NSUUID UUID] UUIDString]]];
        [[NSFileManager defaultManager] createDirectoryAtPath:tempDir withIntermediateDirectories:YES attributes:nil error:nil];
        
        NSString *zipPath = [tempDir stringByAppendingPathComponent:@"update.zip"];
        NSError *moveError = nil;
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:zipPath] error:&moveError];
        
        NSTask *unzipTask = [[NSTask alloc] init];
        [unzipTask setLaunchPath:@"/usr/bin/ditto"];
        [unzipTask setArguments:@[@"-x", @"-k", zipPath, tempDir]];
        [unzipTask launch];
        [unzipTask waitUntilExit];
        
        NSString *extractedApp = [tempDir stringByAppendingPathComponent:@"MOpenKey.app"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:extractedApp]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (window && window.attachedSheet) {
                    [window endSheet:window.attachedSheet];
                }
                [self showMessage:window message:@"Cập nhật thất bại" subMsg:@"Không tìm thấy gói ứng dụng trong bản tải về."];
            });
            return;
        }
        
        pid_t currentPID = [[NSProcessInfo processInfo] processIdentifier];
        NSString *scriptPath = [tempDir stringByAppendingPathComponent:@"update.sh"];
        NSString *scriptContent = [NSString stringWithFormat:
            @"#!/bin/bash\n"
            @"while kill -0 %d 2>/dev/null; do sleep 0.1; done\n"
            @"rm -rf \"%@\"\n"
            @"cp -R \"%@\" \"%@\"\n"
            @"xattr -cr \"%@\" 2>/dev/null || true\n"
            @"open \"%@\"\n"
            @"rm -rf \"%@\"\n",
            currentPID,
            currentAppPath,
            extractedApp,
            currentAppPath,
            currentAppPath,
            currentAppPath,
            tempDir
        ];
        
        [scriptContent writeToFile:scriptPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        chmod([scriptPath UTF8String], 0755);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSTask *runScript = [[NSTask alloc] init];
            [runScript setLaunchPath:@"/bin/bash"];
            [runScript setArguments:@[scriptPath]];
            [runScript launch];
            
            [NSApp terminate:nil];
        });
    }];
    
    [downloadTask resume];
}

+(NSString*)getApplicationSupportFolder {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths firstObject];
    return [NSString stringWithFormat:@"%@/MOpenKey", applicationSupportDirectory];
}

@end

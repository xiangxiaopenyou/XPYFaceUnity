//
//  XPYPerformanceTester.m
//  XPYFaceUnity
//
//  Created by 项林平 on 2022/2/18.
//

#import "XPYPerformanceTester.h"

#import <QuartzCore/QuartzCore.h>
#import <mach/mach.h>

@interface XPYPerformanceTester ()

/// 结果保存路径
@property (nonatomic, copy) NSString *resultPathString;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, assign) BOOL defaultTest;

@end

@implementation XPYPerformanceTester

+ (instancetype)sharedTester {
    static XPYPerformanceTester *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XPYPerformanceTester alloc] init];
    });
    return instance;
}

#pragma mark - Instance methods

- (BOOL)setup {
    return [self setupWithItems:nil fileName:nil needsDefaultItems:YES];
}

- (BOOL)setupWithItems:(NSString *)itemsString
              fileName:(NSString *)fileName
     needsDefaultItems:(BOOL)needsDefaultItems {
    _defaultTest = needsDefaultItems;
    NSString *documentPathString = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    if (!fileName) {
        // 默认保存以当前时间命名的csv文件
        self.resultPathString = [documentPathString stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.csv", [self.dateFormatter stringFromDate:[NSDate date]]]];
    } else {
        self.resultPathString = [documentPathString stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.csv", fileName]];
    }
    BOOL created = [self createResultFile];
    if (!created) {
        NSLog(@"创建文件失败，无法测试");
        return NO;
    }
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.resultPathString];
    [fileHandle seekToEndOfFile];
    NSString *testItems = @"Time";
    if (!itemsString) {
        // 默认测试
        testItems = @"Time,CPU,Memory";
    } else {
        if (needsDefaultItems) {
            // 需要默认测试项拼接自定义测试项
            testItems = [NSString stringWithFormat:@"Time,CPU,Memory,%@", itemsString];
        } else {
            // 只需要自定义测试项
            testItems = itemsString;
        }
    }
    [fileHandle writeData:[testItems dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle closeFile];
    return YES;
}

- (void)writeData:(NSString *)dataString {
    NSString *needSavedDataString = [NSString stringWithFormat:@"\n%@", [self.dateFormatter stringFromDate:[NSDate date]]];
    if (_defaultTest) {
        needSavedDataString = [NSString stringWithFormat:@"%@,%.01f,%.02f", needSavedDataString, [self usedCPU], [self usedMemory]];
    }
    if (dataString) {
        needSavedDataString = [NSString stringWithFormat:@"%@,%@", needSavedDataString, dataString];
    }
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.resultPathString];
    [fileHandle seekToEndOfFile];
    NSData *needSavedData = [needSavedDataString dataUsingEncoding:NSUTF8StringEncoding];
    [fileHandle writeData:needSavedData];
    [fileHandle closeFile];
}

#pragma mark - Private methods

- (BOOL)createResultFile {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.resultPathString]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.resultPathString error:nil];
    }
    return [[NSFileManager defaultManager] createFileAtPath:self.resultPathString contents:nil attributes:nil];
}

#pragma mark - Getters

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss:SSS";
    }
    return _dateFormatter;
}

/// 内存占用
- (double)usedMemory {
    task_vm_info_data_t vm_info_data;
    mach_msg_type_number_t vm_info_count = TASK_VM_INFO_COUNT;
    kern_return_t result = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t)&vm_info_data, &vm_info_count);
    if (result == KERN_SUCCESS) {
        return vm_info_data.phys_footprint/1024.0/1024.0;
    }
    return 0;
}

/// CPU占用
- (double)usedCPU {
    task_info_data_t task_info_data;
    mach_msg_type_number_t task_info_count = TASK_INFO_MAX;
    kern_return_t result = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t)&task_info_data, &task_info_count);
    if (result != KERN_SUCCESS) {
        return 0;
    }
    task_basic_info_t basic_info;
    thread_array_t thread_array;
    mach_msg_type_number_t thread_count;
    thread_info_data_t thread_info_data;
    mach_msg_type_number_t thread_info_count;
    thread_basic_info_t thread_basic_info;
    uint32_t thread_number = 0;
    basic_info = (task_basic_info_t)thread_info_data;
    result = task_threads(mach_task_self(), &thread_array, &thread_count);
    if (result != KERN_SUCCESS) {
        return 0;
    }
    if (thread_count > 0) {
        thread_number += thread_count;
    }
    long sec = 0;
    long msec = 0;
    float cpu = 0;
    for (int i = 0; i < thread_count; i++) {
        thread_info_count = THREAD_INFO_MAX;
        result = thread_info(thread_array[i], THREAD_BASIC_INFO, (thread_info_t)thread_info_data, &thread_info_count);
        if (result != KERN_SUCCESS) {
            return 0;
        }
        thread_basic_info = (thread_basic_info_t)thread_info_data;
        if (!(thread_basic_info->flags & TH_FLAGS_IDLE)) {
            sec = sec + thread_basic_info->user_time.seconds + thread_basic_info->system_time.seconds;
            msec = msec + thread_basic_info->system_time.microseconds + thread_basic_info->system_time.microseconds;
            cpu = cpu + thread_basic_info->cpu_usage/(float)TH_USAGE_SCALE*100.0;
        }
    }
    result = vm_deallocate(mach_task_self(), (vm_offset_t)thread_array, thread_count * sizeof(thread_t));
    assert(result == KERN_SUCCESS);
    return cpu;
}

@end

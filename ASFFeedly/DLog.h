//
//  DLog.h
//  ASFFeedly
//
//  Created by Anton Simakov on 8/1/15.
//  Copyright (c) 2015 Anton Simakov. All rights reserved.
//

#ifdef DEBUG
#   define DLog(format, ...) NSLog((@"%s (%@:%d): " format), __PRETTY_FUNCTION__, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif

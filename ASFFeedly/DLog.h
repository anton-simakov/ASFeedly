//
//  DLog.h
//  ASFFeedly
//
//  Created by Anton Simakov on 8/1/15.
//  Copyright (c) 2015 Anton Simakov. All rights reserved.
//

#ifdef DEBUG
#   define DLog(format, ...) NSLog((@"%s [Line %d] " format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif

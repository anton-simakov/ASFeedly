//
//  ASFConstants.m
//  ASFFeedly
//
//  Created by Anton Simakov on 11/5/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

NSString *const ASFEndpoint             = @"https://sandbox.feedly.com/v3";
NSString *const ASFRedirectURI          = @"http://localhost";

NSString *const ASFAuthAuthPath         = @"auth/auth";
NSString *const ASFAuthTokenPath        = @"auth/token";
NSString *const ASFCategoriesPath       = @"categories";
NSString *const ASFSubscriptionsPath    = @"subscriptions";
NSString *const ASFStreamsContentsPath  = @"streams/contents";
NSString *const ASFMarkersReadsPath     = @"markers/reads";
NSString *const ASFMarkersPath          = @"markers";

NSString *const ASFTypeKey              = @"type";
NSString *const ASFCountKey             = @"count";
NSString *const ASFActionKey            = @"action";
NSString *const ASFRankedKey            = @"ranked";
NSString *const ASFFeedIDsKey           = @"feedIds";
NSString *const ASFEntryIDsKey          = @"entryIds";
NSString *const ASFCategoryIDsKey       = @"categoryIds";
NSString *const ASFStreamIDKey          = @"streamId";
NSString *const ASFNewerThanKey         = @"newerThan";
NSString *const ASFUnreadOnlyKey        = @"unreadOnly";
NSString *const ASFContinuationKey      = @"continuation";

NSString *const ASFAuthorKey            = @"author";
NSString *const ASFOriginIDKey          = @"originId";
NSString *const ASFSummaryKey           = @"summary";
NSString *const ASFContentKey           = @"content";
NSString *const ASFUnreadKey            = @"unread";
NSString *const ASFEngagementKey        = @"engagement";
NSString *const ASFPublishedKey         = @"published";
NSString *const ASFDirectionKey         = @"direction";
NSString *const ASFItemsKey             = @"items";
NSString *const ASFVisualKey            = @"visual";
NSString *const ASFURLKey               = @"url";

NSString *const ASFIDKey                = @"id";
NSString *const ASFTitleKey             = @"title";
NSString *const ASFLabelKey             = @"label";
NSString *const ASFUpdatedKey           = @"updated";
NSString *const ASFWebsiteKey           = @"website";
NSString *const ASFCategoriesKey        = @"categories";

NSString *const ASFUserIDPrefix         = @"user/";
NSString *const ASFFeedIDPrefix         = @"feed/";

NSString *const ASFFeedsValue           = @"feeds";
NSString *const ASFEntriesValue         = @"entries";
NSString *const ASFCategoriesValue      = @"categories";

NSString *const ASFFeedTrueValue        = @"true";
NSString *const ASFFeedFalseValue       = @"false";
NSString *const ASFMarkAsReadValue      = @"markAsRead";
NSString *const ASFKeepUnreadValue      = @"keepUnread";

NSUInteger const ASFStreamCountMax      = 10000;

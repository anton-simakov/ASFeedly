//
//  AFeedlyClientConstants.m
//  AFeedlyClient
//
//  Created by Anton Simakov on 11/5/13.
//  Copyright (c) 2013 Anton Simakov. All rights reserved.
//

NSString *const kFeedlyBaseURL              = @"https://sandbox.feedly.com/v3";
NSString *const kFeedlyRedirectURI          = @"http://localhost";

NSString *const kFeedlyAuthAuthPath         = @"auth/auth";
NSString *const kFeedlyAuthTokenPath        = @"auth/token";
NSString *const kFeedlyCategoriesPath       = @"categories";
NSString *const kFeedlySubscriptionsPath    = @"subscriptions";
NSString *const kFeedlyStreamsContentsPath  = @"streams/contents";
NSString *const kFeedlyMarkersReadsPath     = @"markers/reads";
NSString *const kFeedlyMarkersPath          = @"markers";

NSString *const kFeedlyTypeKey              = @"type";
NSString *const kFeedlyCodeKey              = @"code";
NSString *const kFeedlyStateKey             = @"state";
NSString *const kFeedlyScopeKey             = @"scope";
NSString *const kFeedlyCountKey             = @"count";
NSString *const kFeedlyActionKey            = @"action";
NSString *const kFeedlyRankedKey            = @"ranked";
NSString *const kFeedlyFeedIDsKey           = @"feedIds";
NSString *const kFeedlyEntryIDsKey          = @"entryIds";
NSString *const kFeedlyCategoryIDsKey       = @"categoryIds";
NSString *const kFeedlyStreamIDKey          = @"streamId";
NSString *const kFeedlyClientIDKey          = @"client_id";
NSString *const kFeedlyNewerThanKey         = @"newerThan";
NSString *const kFeedlyUnreadOnlyKey        = @"unreadOnly";
NSString *const kFeedlyGrantTypeKey         = @"grant_type";
NSString *const kFeedlyAccessTokenKey       = @"access_token";
NSString *const kFeedlyRedirectURIKey       = @"redirect_uri";
NSString *const kFeedlyContinuationKey      = @"continuation";
NSString *const kFeedlyClientSecretKey      = @"client_secret";
NSString *const kFeedlyResponseTypeKey      = @"response_type";

NSString *const kFeedlyAuthorKey            = @"author";
NSString *const kFeedlyOriginIDKey          = @"originId";
NSString *const kFeedlySummaryKey           = @"summary";
NSString *const kFeedlyContentKey           = @"content";
NSString *const kFeedlyUnreadKey            = @"unread";
NSString *const kFeedlyEngagementKey        = @"engagement";
NSString *const kFeedlyPublishedKey         = @"published";
NSString *const kFeedlyDirectionKey         = @"direction";
NSString *const kFeedlyItemsKey             = @"items";
NSString *const kFeedlyVisualKey            = @"visual";
NSString *const kFeedlyURLKey               = @"url";

NSString *const kFeedlyIDKey                = @"id";
NSString *const kFeedlyTitleKey             = @"title";
NSString *const kFeedlyLabelKey             = @"label";
NSString *const kFeedlyUpdatedKey           = @"updated";
NSString *const kFeedlyWebsiteKey           = @"website";
NSString *const kFeedlyCategoriesKey        = @"categories";

NSString *const kFeedlyPlanKey              = @"plan";
NSString *const kFeedlyExpiresInKey         = @"expires_in";
NSString *const kFeedlyTokenTypeKey         = @"token_type";
NSString *const kFeedlyRefreshTokenKey      = @"refresh_token";

NSString *const kFeedlyUserIDPrefix         = @"user/";
NSString *const kFeedlyFeedIDPrefix         = @"feed/";

NSString *const kFeedlyFeedsValue           = @"feeds";
NSString *const kFeedlyEntriesValue         = @"entries";
NSString *const kFeedlyCategoriesValue      = @"categories";

NSString *const kFeedlyFeedTrueValue        = @"true";
NSString *const kFeedlyFeedFalseValue       = @"false";
NSString *const kFeedlyMarkAsReadValue      = @"markAsRead";
NSString *const kFeedlyKeepUnreadValue      = @"keepUnread";


NSString *const kFeedlyResponseTypeCode     = @"code";

NSString *const kFeedlyGrantTypeRefreshToken      = @"refresh_token";
NSString *const kFeedlyGrantTypeAuthorizationCode = @"authorization_code";

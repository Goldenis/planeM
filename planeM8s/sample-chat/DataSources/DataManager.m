//
//  DataManager.m
//  planeM8s
//
//  Created by Quickblox Team on 9/19/12.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//

#import "DataManager.h"
#import "ServicesManager.h"
#import <MessageUI/MessageUI.h>

@interface DataManager ()
@property (strong, nonatomic) MFMailComposeViewController *mailComposer;
@property (nonatomic, strong) MCOIMAPOperation *imapCheckOp;
@property (nonatomic, strong) MCOIMAPFetchMessagesOperation *imapMessagesFetchOp;
@end

@implementation DataManager

+ (instancetype)instance
{
    static DataManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
        instance.flights = [[NSMutableArray alloc] init];
        instance.avatars = [[NSMutableDictionary alloc] init];
    });
    return instance;
}

-(void)receiveMails:(NSString*)email password:(NSString*)password completed:(void (^)())completionBlock error:(void (^)(NSError * error))errorBlock {
    
    self.imapSession = [[MCOIMAPSession alloc] init];
    
    NSDictionary *servers = @{@"gmail.com":@[@"imap.gmail.com", @993], @"outlook.com":@[@"imap-mail.outlook.com", @993], @"hotmail.com":@[@"imap-mail.outlook.com", @993], @"yahoo.com":@[@"imap.mail.yahoo.com", @993]};
    
    NSString *domain = [email substringFromIndex:[email rangeOfString:@"@"].location+1];
    if (servers[domain] == nil) {
        errorBlock(nil);
        return;
    }
    
    self.imapSession.hostname = servers[domain][0];
    self.imapSession.username = email;//@"adonis.j0101@gmail.com"
    self.imapSession.port = [servers[domain][1] intValue];
    self.imapSession.password = password;//@"dkfgoddlkaifqu!";
    [self.imapSession setCheckCertificateEnabled:NO];
    self.imapSession.connectionType = MCOConnectionTypeTLS;
    
    __weak __typeof(self)weakSelf = self;
    self.imapSession.connectionLogger = ^(void * connectionID, MCOConnectionLogType type, NSData * data) {
        @synchronized(weakSelf) {
            if (type != MCOConnectionLogTypeSentPrivate) {
            }
        }
    };
    
    NSLog(@"checking account");
    self.imapCheckOp = [self.imapSession checkAccountOperation];
    [self.imapCheckOp start:^(NSError *error) {
        NSLog(@"finished checking account.");
        if (error == nil) {
            [self loadLastNMessages:completionBlock error:errorBlock];
        } else {
            self.imapSession = nil;
            NSLog(@"error loading account: %@", error);
            errorBlock(error);
        }
        
        self.imapCheckOp = nil;
    }];
}

- (void)loadLastNMessages:(void (^)())completionBlock error:(void (^)(NSError * error))errorBlock
{
    MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
    (MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindStructure |
     MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindHeaderSubject |
     MCOIMAPMessagesRequestKindFlags);
    
    NSString *inboxFolder = @"INBOX";
    MCOIMAPFolderInfoOperation *inboxFolderInfo = [self.imapSession folderInfoOperation:inboxFolder];
    
    [inboxFolderInfo start:^(NSError *error, MCOIMAPFolderInfo *info)
    {
        if (error) {
            errorBlock(error);
            return;
        }
                MCOIMAPSearchExpression * expr = [MCOIMAPSearchExpression searchFrom:@""];
        MCOIMAPSearchOperation * op = [self.imapSession searchExpressionOperationWithFolder:@"INBOX" expression:expr];

         
        [op start:^(NSError * error, MCOIndexSet * searchResult) {
            if (error) {
                errorBlock(error);
                return;
            }
            NSLog(@"Count of message %d", searchResult.count);
             
             self.imapMessagesFetchOp = [self.imapSession fetchMessagesByUIDOperationWithFolder:@"INBOX" requestKind:requestKind uids:searchResult];
             [self.imapMessagesFetchOp setProgress:^(unsigned int progress) {
             }];
             
             [self.imapMessagesFetchOp start: ^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages)
             {
                 if (error) {
                     errorBlock(error);
                     return;
                 }
                  NSLog(@"fetched all messages.");
                  NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"header.date" ascending:NO];
                  NSMutableArray *combinedMessages = [NSMutableArray arrayWithArray:messages];
                  [combinedMessages addObjectsFromArray:self.messages];
                  
                  self.messages = [combinedMessages sortedArrayUsingDescriptors:@[sort]];
                  completionBlock();
              }];
             
         }];
         
     }];
}

@end
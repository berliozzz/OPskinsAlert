//
//  ViewController.m
//  OPskinsAlert
//
//  Created by Nikolay Berlioz on 01.06.16.
//  Copyright © 2016 Nikolay Berlioz. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "Item.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController ()

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *addItemField;

- (IBAction)addItemAction:(NSButton *)sender;
- (IBAction)startAction:(NSButton *)sender;
- (IBAction)stopAction:(NSButton *)sender;

@property (strong, nonatomic) NSTimer *refreshTimer;

@property (strong, nonatomic) NSMutableArray *itemsArray;
@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;
@property (assign, nonatomic) NSInteger countItemsIndex;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    
    self.itemsArray = [NSMutableArray array];
    
    self.sessionManager = [AFHTTPSessionManager manager];
    
    self.countItemsIndex = 0;
}



- (void) refreshPriceWithItem:(Item*)item
{
    if ([self.itemsArray count] > 0)
    {
        NSString *urlString = @"https://opskins.com/api/user_api.php";
        
        //StatTrak™ AK-47 | Frontside Misty (Field-Tested)
        //★ Butterfly Knife | Crimson Web (Battle-Scarred)
        
        NSString *itemsString = item.name;
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"GetLowestSalePrices", @"request",
                                @"39f9ceeb690f5a7503ccd021fdec4402", @"key",
                                @"730", @"appid",
                                @"2", @"contextid",
                                itemsString, @"names", nil];
        
        [self.sessionManager GET:urlString
                      parameters:params
                        progress:nil
                         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                             
                             NSDictionary *result = [responseObject objectForKey:@"result"];
                             
                             NSDictionary *items = [result objectForKey:@"items"];
                             
                             if ([items count] > 0)
                             {
                                 for (NSString *key in items)
                                 {
                                     item.currentPrice = [[items objectForKey:key] integerValue];
                                     
                                     if (item.currentPrice <= item.minPrice)
                                     {
                                         [self alertMethod];
                                     }
                                 }
                             }
                             
                             [self.tableView reloadData];
                             //NSLog(@"responseObject = %@", responseObject);
                             
                             
                         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                             
                             //NSLog(@"error = %@", error);
                             
                             NSString *response = [NSString stringWithUTF8String:[[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"] bytes]];
                             
                             NSLog(@"error = %@", response);
                         }];
    }
}

#pragma mark - Private Methods

- (void) launchRefreshItemInfo
{
    Item *item = [self.itemsArray objectAtIndex:self.countItemsIndex];
    
    // каждый раз при запуске таймером этого метода обновляем по порядку каждый итем
    if (self.itemsArray.count)
    {
        [self refreshPriceWithItem:item];
        
        self.countItemsIndex++;
        
        // когда индекс станет равным количеству объектов в Realm - обнуляем его
        if (self.countItemsIndex == self.itemsArray.count)
        {
            self.countItemsIndex = 0;
        }
    }
}

- (void) alertMethod
{
    SystemSoundID clickSound;
    
    AudioServicesCreateSystemSoundID(CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("sound"), CFSTR("wav"), NULL), &clickSound);
    AudioServicesPlaySystemSound(clickSound);
    
    //AudioServicesDisposeSystemSoundID(clickSound);
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    if (tableView == self.tableView)
    {
        return self.itemsArray.count;
    }
    
    return 0;
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row;
{
    if (tableView == self.tableView)
    {
        NSString *ident = tableColumn.identifier; // Получаем значение Identifier колонки
        
        Item* item = [self.itemsArray objectAtIndex:row]; // получаем объект данных для строки
        
        return [item valueForKey:ident]; // Возвращаем значение соответствующего свойства
    }
    
    return nil;
}

- (void) tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if(row != -1)
    {
        if(tableView == self.tableView)
        {
            NSString* ident = tableColumn.identifier;
            
            Item* item = [self.itemsArray objectAtIndex:row];
            
            [item setValue:object forKey:ident]; //Устанавливаем значение для соответствующего свойства
        }
    }
}




#pragma mark - Actions

- (IBAction)addItemAction:(NSButton *)sender {
    
    Item *item = [[Item alloc] init];
    
    item.name = self.addItemField.stringValue;
    
    [self.itemsArray addObject:item];
    
    self.addItemField.stringValue = @"";
    
    [self.tableView reloadData];
}

- (IBAction)startAction:(NSButton *)sender {
    
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:30 / self.itemsArray.count
                                                         target:self
                                                       selector:@selector(launchRefreshItemInfo)
                                                       userInfo:nil
                                                        repeats:YES];
    
}

- (IBAction)stopAction:(NSButton *)sender {
    
    if ([self.refreshTimer isValid])
    {
        [self.refreshTimer invalidate];
        self.refreshTimer = nil;
    }
    
}
@end














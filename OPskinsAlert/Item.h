//
//  Item.h
//  OPskinsAlert
//
//  Created by Nikolay Berlioz on 11.06.16.
//  Copyright © 2016 Nikolay Berlioz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject

@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) NSInteger currentPrice;
@property (assign, nonatomic) NSInteger minPrice;

@end

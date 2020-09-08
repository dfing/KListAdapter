//
//  QYICellProtocol.h
//  QYIphone
//
//  Created by kaylla on 2019/3/18.
//  Copyright © 2019 iQiyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QYICellProtocol <NSObject>

+ (NSString *)reuseIdentifier;
- (void)configCellWith:(id)object;

@end


@protocol QYITableViewCellProtocol <QYICellProtocol>

+ (CGFloat)cellHeight;

@end


@protocol QYICollectionViewCellProtocol <QYICellProtocol>

@optional
+ (CGFloat)cellHeight:(NSInteger)dataSourceCount;

@end

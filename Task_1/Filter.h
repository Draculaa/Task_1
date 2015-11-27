//
//  Filter.h
//  Task_1
//
//  Created by Евгений on 26.11.15.
//  Copyright © 2015 Eugene Kirtaev. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage;

@interface Filter : NSObject

+ (instancetype)sharedFilter;
/*!
 * @discussion Метод, накладывающий фильтр на изображение
 * @param image Исходное изображение
 * @return Обработанное изображение
 */
- (UIImage *)imagewithFilter: (UIImage *) image;

@end

//
//  ViewController.m
//  Task_1
//
//  Created by Евгений on 25.11.15.
//  Copyright © 2015 Eugene Kirtaev. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Filter.h"

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

/*!
 * @brief Оригинальное изображение
 */
@property (strong, nonatomic) UIImage * inputPhoto;
/*!
 * @brief Отредактированное изображение
 */

@property (strong, nonatomic) UIImage * outputPhoto;
/*!
 * @brief Ссылка на объект UIImagePickerController
 */
@property (strong, nonatomic) UIImagePickerController * imagePicker;
/*!
 * @discussion Метод открытия фотогалереи
 */
- (void)openPhotoPicker;
/*!
 * @discussion Метод, проверяющий доступна ли библиотека фотографий на целевом устройстве
 * @return ДА/НЕТ
 */
- (BOOL)isPhotoLibraryAvailable;
/*!
 * @discussion Метод, проверяющий предоставляется ли тип медиа данных источником данных
 * @param paramMediaType Тип медиа файла
 * @param paramsSourseType источник данных
 * @return ДА/НЕТ
 */
- (BOOL)cameraSupportsMedia:(NSString *)paramMediaType
                 sourceType:(UIImagePickerControllerSourceType *)paramsSourseType;
/*!
 * @discussion Метод, проверяющий, поддерживает ли библиотека изображений тип данных - Изображение
 * @return ДА/НЕТ
 */
- (BOOL)canUserPickPhotosFromLibrary;
/*!
 * @discussion Метод, сохраняющий изображение в библиотеке
 * @param image Изображение
 */
- (void)savePhoto:(UIImage *)image;
/*!
 * @discussion Метод, обрабатывающий результат сохранения изображения
 * @param paramImage Изображение
 * @param error Ошибка сохранения
 * @param paramContextInfo Контекст
 */
-(void)imageWasSavedSuccesfully:(UIImage *)paramImage
       didFinishSavingWithError:(NSError *)error
                    contextInfo:(void *)paramContextInfo;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.saveButton.hidden = YES;
    self.FilterButton.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];

    static BOOL beenHere;
    if (beenHere) {
        //do something
    } else {
        beenHere = YES;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self openPhotoPicker];
        }];
    }
}

- (void)openPhotoPicker{
    if ([self isPhotoLibraryAvailable]) {
        UIImagePickerController * controller = [[UIImagePickerController alloc]init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        NSMutableArray * mediaTypes = [[NSMutableArray alloc]init];
        
        if ([self canUserPickPhotosFromLibrary]) {
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
        }
        controller.mediaTypes = mediaTypes;
        controller.delegate = self;
        self.imagePicker = controller;
        
        [self presentViewController:controller
                           animated:YES
                         completion:nil];
    }
}

- (BOOL)isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL)cameraSupportsMedia:(NSString *)paramMediaType
                 sourceType:(UIImagePickerControllerSourceType *)paramsSourseType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    
    NSArray * availableMediaTypes = [UIImagePickerController
                                     availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [availableMediaTypes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}

- (BOOL)canUserPickPhotosFromLibrary{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage
                          sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    NSString * mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(__bridge NSString *)kUTTypeImage]) {
        NSDictionary * metaData = [info objectForKey:UIImagePickerControllerMediaMetadata];
        NSLog(@"%@", metaData);
        self.inputPhoto = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.inputImageView.image = self.inputPhoto;
        self.FilterButton.hidden = NO;
    }
    [picker dismissViewControllerAnimated:YES
                               completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES
                               completion:nil];
}

- (void)savePhoto: (UIImage *)image{
    
    SEL handler = @selector(imageWasSavedSuccesfully:
                            didFinishSavingWithError:
                                        contextInfo:);
    UIImageWriteToSavedPhotosAlbum(image,
                                   self,
                                   handler,
                                   nil);
}

-(void)imageWasSavedSuccesfully:(UIImage *)paramImage
       didFinishSavingWithError:(NSError *)error
                    contextInfo:(void *)paramContextInfo{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Message"
                                                                   message:@"Image was saved succesfully."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - IBAction

- (IBAction)pushFilterButton:(id)sender {
    self.activityIndicator.hidden = NO;
    [self.outputImageView addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    __weak typeof(self) wSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        wSelf.outputPhoto = [[Filter sharedFilter] imagewithFilter: wSelf.inputPhoto];
        wSelf.outputImageView.image = wSelf.outputPhoto;
        wSelf.saveButton.hidden = NO;
        [wSelf.activityIndicator stopAnimating];
    });
}

- (IBAction)pushSaveButton:(id)sender {
    [self savePhoto:self.outputPhoto];
}
@end

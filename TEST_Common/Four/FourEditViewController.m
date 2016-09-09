//
//  FourEditViewController.m
//  TEST_Common
//
//  Created by luxiaoming on 16/8/30.
//  Copyright © 2016年 luxiaoming. All rights reserved.
//

#import "FourEditViewController.h"
#import "FourDisplayViewController.h"
#import "FourTextAttachment.h"

@interface FourEditViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) UIToolbar *toolbar;

@property (nonatomic, strong) NSDictionary *inputAttributeDict;
@property (nonatomic, strong) NSDictionary *imageAttributeDict;


@end

@implementation FourEditViewController


#pragma mark - Property

- (NSDictionary *)inputAttributeDict {
    if (!_inputAttributeDict) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.minimumLineHeight = 20;
        style.alignment = NSTextAlignmentLeft;
        _inputAttributeDict = @{NSParagraphStyleAttributeName : style,
                                NSFontAttributeName : [UIFont systemFontOfSize:16],
                                NSForegroundColorAttributeName : [UIColor orangeColor]};
    }
    return _inputAttributeDict;
    
}

- (NSDictionary *)imageAttributeDict {
    if (!_imageAttributeDict) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.minimumLineHeight = 20;
        _imageAttributeDict = @{NSParagraphStyleAttributeName : style,
                                NSFontAttributeName : [UIFont systemFontOfSize:16],
                                NSForegroundColorAttributeName : [UIColor orangeColor]};
    }
    return _imageAttributeDict;
    
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupNav];
    [self setupToolbar];
    [self setupNotification];
    
    
    self.textView.text = nil;
    self.textView.delegate = self;
    self.textView.inputAccessoryView = self.toolbar;
    self.textView.typingAttributes = self.inputAttributeDict;
    self.textView.layer.cornerRadius = 4;
    self.textView.layer.borderColor = LXMColorFromHex(0xeeeeee).CGColor;
    self.textView.layer.borderWidth = 1;
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - PrivateMethod 

- (void)setupNav {
    WEAKSELF(weakSelf)
    UIBarButtonItem *displayItem = [UIBarButtonItem itemWithTitle:@"display" style:UIBarButtonItemStylePlain callback:^(UIBarButtonItem *sender) {
        FourDisplayViewController *displayViewController = [FourDisplayViewController loadFromStroyboard];
        displayViewController.displayString = weakSelf.textView.attributedText;
        [weakSelf.navigationController pushViewController:displayViewController animated:YES];
    }];
    self.navigationItem.rightBarButtonItem = displayItem;
}

- (void)setupToolbar {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, kLXMScreenWidth, 44)];
    WEAKSELF(weakSelf)
    UIBarButtonItem *pictureItem = [UIBarButtonItem itemWithBarButtonSystemItem:UIBarButtonSystemItemAdd callback:^(UIBarButtonItem *sender) {
        UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
        pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        pickerController.delegate = weakSelf;
        [weakSelf.navigationController presentViewController:pickerController animated:YES completion:^{
            
        }];
    }];
    
    
    UIBarButtonItem *spacingItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *cancelItem = [UIBarButtonItem itemWithTitle:@"隐藏" style:UIBarButtonItemStyleDone callback:^(UIBarButtonItem *sender) {
        [weakSelf.textView resignFirstResponder];
    }];
    
    
    toolbar.items = @[pictureItem, spacingItem, cancelItem];
    self.toolbar = toolbar;
}

- (void)setupNotification {
    WEAKSELF(weakSelf)
    
    [kLXMNotificationCenter addObserver:self name:UIKeyboardWillChangeFrameNotification callback:^(NSNotification *sender) {
        CGRect endFrame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat duration = [sender.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:duration animations:^{
            
            if (CGRectGetMinY(endFrame) == kLXMScreenHeight) {
                weakSelf.textView.contentInset = UIEdgeInsetsZero;
            } else {
                weakSelf.textView.contentInset = UIEdgeInsetsMake(0, 0, endFrame.size.height + 44, 0);
            }
            
        }];
    }];
}

- (void)updateBodyTextWithImage:(UIImage *)image {
    
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    if (imageWidth <= 0) {
        return;
    }
    
    //    DLog(@"range is %@", NSStringFromRange(selectedRange));

    CGFloat resizedWidth = kLXMScreenWidth - 25 * 2;
    CGFloat resizedHeight = ceil(imageHeight * resizedWidth / imageWidth);
    
    FourTextAttachment *attachment = [[FourTextAttachment alloc] init];
    attachment.image = image;
    attachment.bounds = CGRectMake(0, 0, resizedWidth, resizedHeight);
//    attachment.bounds = CGRectMake(0, 0, 100, 100);
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    NSAttributedString *newLineString = [[NSAttributedString alloc] initWithString:@"\n" attributes:self.inputAttributeDict];
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *tempString = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
    [tempString addAttributes:self.imageAttributeDict range:NSMakeRange(0, tempString.length)];
    
    [string insertAttributedString:newLineString atIndex:self.textView.selectedRange.location];
    [string insertAttributedString:tempString atIndex:self.textView.selectedRange.location];
    [string insertAttributedString:newLineString atIndex:self.textView.selectedRange.location];
    
    self.textView.attributedText = string;
    self.textView.typingAttributes = self.inputAttributeDict;
}



#pragma mark - UITextViewDelegate



#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    //    DLog(@"picked info is %@", info);
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:^{
        [self updateBodyTextWithImage:selectedImage];
        
        [self.textView becomeFirstResponder];
    }];
}



@end



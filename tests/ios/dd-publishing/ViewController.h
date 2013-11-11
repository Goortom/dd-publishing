//
//  ViewController.h
//  dd-publishing
//
//  Created by jimon on 11/5/13.
//  Copyright (c) 2013 goortom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextView * status_text;

-(IBAction)do_fb:(id)sender;
-(IBAction)do_fb_post:(id)sender;
-(IBAction)do_fb_inv_friends:(id)sender;

@end

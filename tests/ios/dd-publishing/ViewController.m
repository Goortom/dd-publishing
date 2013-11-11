//
//  ViewController.m
//  dd-publishing
//
//  Created by jimon on 11/5/13.
//  Copyright (c) 2013 goortom. All rights reserved.
//

#import "ViewController.h"
#include "dd_publishing.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize status_text;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	[NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(do_fb_process) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)do_fb:(id)sender
{
	if(dd_pbl_ios_fb_is_aviable() > 0)
	{
		dd_pbl_ios_fb_logout();
	}
	else if(dd_pbl_ios_fb_is_aviable() == 0)
	{
		dd_pbl_ios_fb_auth();
	}
	else if(dd_pbl_ios_fb_is_aviable() == -2)
	{
		dd_pbl_ios_fb_init("370546396320150");
	}
}

-(IBAction)do_fb_post:(id)sender
{
	dd_pbl_ios_fb_publish_feed("loool", NULL, NULL, NULL, NULL);
}

-(IBAction)do_fb_inv_friends:(id)sender
{
	dd_pbl_ios_fb_invite_friends("oh plz");
}

-(void)do_fb_process
{
	int8_t status = dd_pbl_ios_fb_is_aviable();
	
	if(status > 0)
		[[self status_text] setText:@"fb ok"];
	else if(status == 0)
		[[self status_text] setText:@"fb no auth"];
	else if(status == -1)
		[[self status_text] setText:@"wait for fb"];
	else if(status == -2)
		[[self status_text] setText:@"no fb"];
}

@end

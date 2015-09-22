
#import "DocumentHandler.h"
#import "AppDelegate.h"

@implementation DocumentHandler

UINavigationController *navCntrl;
- (void)HandleDocumentWithURL:(CDVInvokedUrlCommand*)command;
{
    __weak DocumentHandler* weakSelf = self;

    dispatch_queue_t asyncQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(asyncQueue, ^{

        NSDictionary* dict = [command.arguments objectAtIndex:0];

        NSString* urlStr = dict[@"url"];
        NSURL* url = [NSURL URLWithString:urlStr];
        NSData* dat = [NSData dataWithContentsOfURL:url];
        if (dat == nil) {
          CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:2];
          [weakSelf.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
          return;
        }
        NSString *urls = dict[@"url"];
        // NSArray *parts = [url componentsSeparatedByString:@"/"];
        // NSString *filename = [parts lastObject];
        //Original statement
        // NSString* fileName = [url lastPathComponent];
        NSString *fileName;
        if(dict[@"fileName"]==nil){
            NSArray *parts = [urls componentsSeparatedByString:@"+"];
            fileName = [parts lastObject];
        }else{
            fileName= dict[@"fileName"];
        }
        NSString* path = [NSTemporaryDirectory() stringByAppendingPathComponent: fileName];
        NSURL* tmpFileUrl = [[NSURL alloc] initFileURLWithPath:path];
        [dat writeToURL:tmpFileUrl atomically:YES];
        weakSelf.fileUrl = tmpFileUrl;

        dispatch_async(dispatch_get_main_queue(), ^{
            QLPreviewController* cntr = [[QLPreviewController alloc] init];
            cntr.delegate = weakSelf;
            cntr.dataSource = weakSelf;
            
            AppDelegate* root = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];
            
            navCntrl=[[UINavigationController alloc] initWithRootViewController:cntr];
            cntr.navigationItem.leftBarButtonItem=done;
            //[root.viewController addChildViewController:navCntrl];
            [root.viewController  presentViewController:navCntrl animated:YES completion:nil];
        });


        CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
        [weakSelf.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
    });
}

#pragma mark - QLPreviewController data source

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1;
}

- (id <QLPreviewItem>) previewController: (QLPreviewController *) controller previewItemAtIndex: (NSInteger) index
{
    return self;
}

#pragma mark - QLPreviewItem protocol

- (NSURL*)previewItemURL{
    return self.fileUrl;
}

- (void)doneButtonTapped:(id)sender {
    [navCntrl dismissViewControllerAnimated:YES completion:nil];
}


@end

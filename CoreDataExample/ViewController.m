//
//  ViewController.m
//  CoreDataExample
//
//  Created by Duncan Jack on 31/05/2016.
//  Copyright © 2016 Open Word. All rights reserved.
//

#import "ViewController.h"
@import CoreData;

@interface ViewController ()
@property UIManagedDocument *document;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self test];
}

- (void)viewWillDisappear:(BOOL)animated{
    // Optionally remove the listener.
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.document.managedObjectContext];
}

-(void)contextChanged:(NSNotification *)notification{
    NSLog(@"%@", notification.name);
}

- (void)test{
    
    // Get a URL for the file we want to create.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *documentName = @"MyDocument";
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
    
    // Create our instance. This does not open or create the underlying file.
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    // Optionally listen for the save notification.
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(contextChanged:) name:NSManagedObjectContextDidSaveNotification object:self.document.managedObjectContext];
    
    // If the document already exists on disk, we'll try and open it ...
    if([fileManager fileExistsAtPath:[url path]]){
        [self.document openWithCompletionHandler:^(BOOL success){
            if(success){
                [self documentIsReady];
            } else {
                NSLog(@"Could not open document at %@", url);
            }
        }];
        
    // ... else we'll try and create it.
    } else {
        [self.document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if(success){
                [self documentIsReady];
                
            } else {
                NSLog(@"Could not create document at %@", url);
            }
        }];
    }
}

- (void)documentIsReady{
    NSLog(@"documentIsReady");
    if(self.document.documentState == UIDocumentStateNormal){
        NSManagedObjectContext *context = self.document.managedObjectContext;
        
        // Insert a photo.
        NSManagedObject *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        [photo setValue:@"Photo1" forKey:@"title"];
        NSLog(@"%@", photo);
        
        NSString *title = [photo valueForKey:@"title"];
        NSLog(@"photo.title is %@", title);
    }
}

@end

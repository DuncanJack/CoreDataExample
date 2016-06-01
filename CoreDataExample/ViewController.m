//
//  ViewController.m
//  CoreDataExample
//
//  Created by Duncan Jack on 31/05/2016.
//  Copyright © 2016 Open Word. All rights reserved.
//

#import "ViewController.h"
#import "Photo.h"
#import "Photographer.h"

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
    NSString *documentName = @"MyDocument2";
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
        
        [self insertAndDeleteExample];
        
        [self queryExample];
    }
}

-(void)insertAndDeleteExample{
    NSManagedObjectContext *context = self.document.managedObjectContext;
    
    // Insert a photo.
    NSManagedObject *photo1 = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
    [photo1 setValue:@"Photo1" forKey:@"title"];
    NSLog(@"%@", photo1);
    
    NSString *title1 = [photo1 valueForKey:@"title"];
    NSLog(@"photo1.title is %@", title1);
    
    // Strongly typed.
    Photo *photo2 = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
    photo2.title = @"Photo2";
    photo2.whotook = [NSEntityDescription insertNewObjectForEntityForName:@"Photographer" inManagedObjectContext:context];
    photo2.whotook.name = @"Photographer1";
    NSLog(@"%@", photo2);
    
    NSString *title2 = [photo2 valueForKey:@"title"];
    NSLog(@"photo2.title is %@", title2);
    
    // Delete.
    [context deleteObject:photo2];
    photo2 = nil;
}

- (void)queryExample{
    NSManagedObjectContext *context = self.document.managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.fetchBatchSize = 20;
    request.fetchLimit = 100;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"title contains %@", @"1"];
    
    NSError *error;
    NSArray *photos = [context executeFetchRequest:request error:&error];
        
    NSLog(@"There are %lu photos", [photos count]);
}

@end

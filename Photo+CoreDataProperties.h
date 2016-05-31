//
//  Photo+CoreDataProperties.h
//  CoreDataExample
//
//  Created by Duncan Jack on 31/05/2016.
//  Copyright © 2016 Open Word. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Photo.h"

NS_ASSUME_NONNULL_BEGIN

@interface Photo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) Photographer *whotook;

@end

NS_ASSUME_NONNULL_END

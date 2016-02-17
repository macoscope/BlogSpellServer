//
//  main.m
//  BlogSpellServer
//
//  Created by Michał Laskowski on 07/02/16.
//  Copyright © 2016 Macoscope. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlogSpellServer.h"

NSArray<NSString *> *providedLanguages()
{
    NSArray *services = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSServices"];
    assert([services isKindOfClass:[NSArray class]]);

    NSMutableArray<NSString *> *results = [NSMutableArray array];

    for(NSDictionary *serviceDict in services) {
        assert([serviceDict isKindOfClass:[NSDictionary class]]);
        NSArray *languages = [serviceDict objectForKey:@"NSLanguages"];
        assert([languages isKindOfClass:[NSArray<NSString *> class]]);

        [results addObjectsFromArray:languages];
    }
    return results;
}

int main(int argc, const char * argv[])
{
    @autoreleasepool {

        NSArray<NSString *> *languages = providedLanguages();
        NSString *appName = [[[NSBundle mainBundle] infoDictionary]  objectForKey:(NSString *)kCFBundleNameKey];

        BlogSpellServer *spellServer = [[BlogSpellServer alloc] init];

        if (languages && languages.count > 0) {
            NSSpellServer *aServer = [[NSSpellServer alloc] init];
            NSInteger registeredLanguages = 0;
            for (NSString *language in languages) {
                if ([aServer registerLanguage:language byVendor:appName]) {
                    registeredLanguages++;
                }
                NSLog(@"Registering %@", language);
            }
            if (registeredLanguages > 0) {
                [aServer setDelegate:spellServer];
                [aServer run];
                NSLog(@"Unexpected death of BlogSpellServer!\n");
            } else {
                NSLog(@"Unable to check-in Remember BlogSpellServer.\n");
            }
        }
    }
    return 0;
}
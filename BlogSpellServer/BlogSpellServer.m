//
//  BlogSpellServer.m
//  BlogSpellServer
//
//  Created by Michał Laskowski on 07/02/16.
//  Copyright © 2016 Macoscope. All rights reserved.
//

#import "BlogSpellServer.h"

@implementation BlogSpellServer

#pragma mark - old api

- (NSRange)spellServer:(NSSpellServer *)sender findMisspelledWordInString:(NSString *)stringToCheck language:(NSString *)language wordCount:(NSInteger *)wordCount countOnly:(BOOL)countOnly{

    NSLog(@"Old api - find mispelled word in string: %@", stringToCheck);

    *wordCount = -1;
    return [stringToCheck rangeOfString:@"badword"];
}

- (nullable NSArray<NSString *> *)spellServer:(NSSpellServer *)sender suggestGuessesForWord:(NSString *)word inLanguage:(NSString *)language{

    NSLog(@"Old api - suggest guesses for word: %@", word);

    if ([word isEqualToString:@"badword"]) {
        return @[@"goodword"];
    }

    return nil;
}

-(NSString *) languageFromOthrography:(NSOrthography *)orthrography
{
    if(orthrography && orthrography.allLanguages.firstObject) {
        return orthrography.allLanguages.firstObject;
    } else {
        return [[NSLocale currentLocale] valueForKey:NSLocaleLanguageCode];
    }
}

#pragma mark - new api

-(nullable NSArray<NSTextCheckingResult *> *)spellServer:(NSSpellServer *)sender checkString:(NSString *)stringToCheck offset:(NSUInteger)offset types:(NSTextCheckingTypes)checkingTypes options:(nullable NSDictionary<NSString *, id> *)options orthography:(nullable NSOrthography *)orthography wordCount:(NSInteger *)wordCount {

    BOOL checkSpelling = (checkingTypes & NSTextCheckingTypeSpelling) > 0;
    BOOL provideCorrections = (checkingTypes & NSTextCheckingTypeCorrection) > 0;

    NSString *language = [self languageFromOthrography:orthography];
    NSLog(@"New api method, language: %@, for %@, offset: %lu, spelling: %d, corrections: %d", language, stringToCheck, (unsigned long)offset, checkSpelling, provideCorrections);

    *wordCount = -1;
    NSMutableArray<NSTextCheckingResult *> *results = [NSMutableArray new];

    NSRange range = NSMakeRange(0, stringToCheck.length);
    NSStringCompareOptions compareOptions = NSDiacriticInsensitiveSearch | NSCaseInsensitiveSearch;

    //check all strings
    while (true) {
        NSRange foundRange = [stringToCheck rangeOfString:@"badword" options:compareOptions range:range];
        if (foundRange.location != NSNotFound) {
            range.location = foundRange.location + foundRange.length;
            range.length = stringToCheck.length - range.location;

            NSRange rangeWithOffset = NSMakeRange(foundRange.location + offset, foundRange.length);

            [results addObject:[NSTextCheckingResult spellCheckingResultWithRange:rangeWithOffset]];

            //you can remove this line, if you are also providing method 'suggestGuessesForWord:...'
            [results addObject:[NSTextCheckingResult correctionCheckingResultWithRange:rangeWithOffset replacementString:@"goodword"]];
        }else {
            break;
        }
    }

    return results;
}

@end

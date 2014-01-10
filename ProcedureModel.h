//
//  ProcedureModel.h
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/5/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import <Foundation/Foundation.h>


/*
	Contains all of the plist data for a procedure in an easily-accessible form.
*/


@interface ProcedureModel : NSObject


@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *summaryPath;
@property (nonatomic, strong) NSString *diagnosticPath;
@property (nonatomic, strong) NSString *preProcedurePath;
@property (nonatomic, strong) NSString *procedurePath;
@property (nonatomic, strong) NSString *postProcedurePath;
@property (nonatomic, strong) NSString *videoPath;


+ (ProcedureModel *)procedureFromDictionary:(NSDictionary *)dictionary;


@end

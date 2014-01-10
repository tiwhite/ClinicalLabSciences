//
//  ProcedureModel.m
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/5/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import "ProcedureModel.h"


@implementation ProcedureModel


// ---------------------------------------------------------------------------------------------------------------------
+ (ProcedureModel *)procedureFromDictionary:(NSDictionary *)dictionary
{
	ProcedureModel *procedureModel = [[ProcedureModel alloc] init];
	
	procedureModel.name = [dictionary objectForKey:@"Name"];
	procedureModel.summaryPath = [dictionary objectForKey:@"SummaryPath"];
	procedureModel.diagnosticPath = [dictionary objectForKey:@"DiagnosticPath"];
	procedureModel.preProcedurePath = [dictionary objectForKey:@"PreProcPath"];
	procedureModel.procedurePath = [dictionary objectForKey:@"ProcedurePath"];
	procedureModel.postProcedurePath = [dictionary objectForKey:@"PostProcPath"];
	procedureModel.videoPath = [dictionary objectForKey:@"VideoPath"];
	
	return procedureModel;
}


@end

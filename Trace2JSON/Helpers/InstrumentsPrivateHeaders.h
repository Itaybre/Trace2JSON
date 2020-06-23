//
//  InstrumentsPrivateHeaders.h
//  Trace2JSON
//
//  Created by Itay Brenner on 6/20/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//

#import <AppKit/AppKit.h>

void DVTInitializeSharedFrameworks(void);
BOOL PFTLoadPlugins(void);
void PFTClosePlugins(void);

@interface DVTDeveloperPaths : NSObject
+ (NSString *)applicationDirectoryName;
+ (void)initializeApplicationDirectoryName:(NSString *)name;
@end

@interface XRInternalizedSettingsStore : NSObject
+ (NSDictionary *)internalizedSettings;
+ (void)configureWithAdditionalURLs:(NSArray *)urls;
@end

@interface XRCapabilityRegistry : NSObject
+ (instancetype)applicationCapabilities;
- (void)registerCapability:(NSString *)capability versions:(NSRange)versions;
@end

typedef UInt64 XRTime; // in nanoseconds
typedef struct { XRTime start, length; } XRTimeRange;

@interface XRRun : NSObject
- (SInt64)runNumber;
- (NSString *)displayName;
- (XRTimeRange)timeRange;
@end

@interface PFTInstrumentType : NSObject
- (NSString *)uuid;
- (NSString *)name;
- (NSString *)category;
@end

@protocol XRInstrumentViewController;

@interface XRInstrument : NSObject
- (PFTInstrumentType *)type;
- (id<XRInstrumentViewController>)viewController;
- (void)setViewController:(id<XRInstrumentViewController>)viewController;
- (NSArray<XRRun *> *)allRuns;
- (XRRun *)currentRun;
- (void)setCurrentRun:(XRRun *)run;
- (id)traceTemplateData;
@end

@interface PFTInstrumentList : NSObject
- (NSArray<XRInstrument *> *)allInstruments;
@end

@interface XRRunListData : NSObject
- (id)allRunsDictionary;
- (NSDictionary *)runData;
- (id)runNumbers;
- (id)dataForRunNumber:(long long)arg1;
- (id)targetDataForRunNumber:(long long)arg1;
- (void)addAllCoresData:(id)arg1 forRunNumber:(long long)arg2;
- (void)setInspectionTime:(unsigned long long)arg1 forRunNumber:(long long)arg2;
- (void)addRunningTime:(unsigned long long)arg1 forRunNumber:(long long)arg2;
- (id)stringOSVersionInfoForRunNumber:(long long)arg1;
- (id)osVersionForRunNumber:(long long)arg1;
- (unsigned long long)runningTimeForRunNumber:(long long)arg1;
- (id)processDatasForRunNumber:(long long)arg1;
- (id)startStringForRunNumber:(long long)arg1;
- (id)startDateForRunNumber:(long long)arg1;
- (unsigned long long)startTimeForRunNumber:(long long)arg1;
@end

@interface XRTrace : NSObject
- (PFTInstrumentList *)allInstrumentsList;
-(char)loadDocument:(NSURL *)arg2 error:(NSError **)arg3;
- (void)setValue:(id)arg1 forURL:(id)arg2;
- (id)valueForURL:(NSURL *)arg1;
- (XRRunListData *) runData;
@end

@interface XRDevice : NSObject
- (NSString *)deviceIdentifier;
- (NSString *)deviceDisplayName;
- (NSString *)deviceDescription;
- (NSString *)productType;
- (NSString *)productVersion;
- (NSString *)buildVersion;
@end

@interface PFTProcess : NSObject
- (NSString *)bundleIdentifier;
- (NSString *)processName;
- (NSString *)displayName;
@end

@interface PFTTraceDocument : NSDocument
- (XRTrace *)trace;
- (XRDevice *)targetDevice;
- (PFTProcess *)defaultProcess;
- (id)allInstrumentsList;
- (id)currentTargetProcess;
@end

@interface PFTDocumentController : NSDocumentController
@end

@protocol XRContextContainer;

@interface XRContext : NSObject
- (NSString *)label;
- (id<NSCoding>)value;
- (id<XRContextContainer>)container;
- (instancetype)parentContext;
- (instancetype)rootContext;
- (void)display;
- (id)initWithLabel:(id)arg1 value:(id)arg2 attributes:(id)arg3 container:(id)arg4 parentContext:(id)arg5;
@end

@protocol XRContextContainer <NSObject>
- (XRContext *)contextRepresentation;
- (NSArray<XRContext *> *)siblingsForContext:(XRContext *)context;
- (void)displayContext:(XRContext *)context;
@end

@protocol XRFilteredDataSource <NSObject>
@end

@protocol XRSearchTarget <NSObject>
@end

@protocol XRCallTreeDataSource <NSObject>
@end

@protocol XRAnalysisCoreViewSubcontroller <XRContextContainer, XRFilteredDataSource>
@end

typedef NS_ENUM(SInt32, XRAnalysisCoreDetailViewType) {
    XRAnalysisCoreDetailViewTypeProjection = 1,
    XRAnalysisCoreDetailViewTypeCallTree = 2,
    XRAnalysisCoreDetailViewTypeTabular = 3,
};

@interface XRAnalysisCoreDetailNode : NSObject
@property(readonly, nonatomic) NSString *label;
@property(readonly, nonatomic) XRAnalysisCoreDetailNode *parent;
- (instancetype)firstSibling;
- (instancetype)nextSibling;
- (XRAnalysisCoreDetailViewType)viewKind;
@end

@class XRAnalysisCoreProjectionViewController, XRAnalysisCoreCallTreeViewController, XRAnalysisCoreTableViewController;

@interface XRAnalysisCoreDetailViewController : NSViewController <XRAnalysisCoreViewSubcontroller> {
    XRAnalysisCoreDetailNode *_firstNode;
    XRAnalysisCoreProjectionViewController *_projectionViewController;
    XRAnalysisCoreCallTreeViewController *_callTreeViewController;
    XRAnalysisCoreTableViewController *_tabularViewController;
}
- (void)restoreViewState;
+ (XRContext *)_createContextForDetailNode:(id)arg1 stateMetadataBaseURL:(id)arg2 globalForkID:(unsigned long long)arg3 trackConfiguration:(id)arg4 isTrackPinned:(BOOL)arg5 trace:(id)arg6 container:(id)arg7;
@end

XRContext *XRContextFromDetailNode(XRAnalysisCoreDetailViewController *detailController, XRAnalysisCoreDetailNode *detailNode);

@protocol XRInstrumentViewController <NSObject>
- (id<XRContextContainer>)detailContextContainer;
- (id<XRFilteredDataSource>)detailFilteredDataSource;
- (id<XRSearchTarget>)detailSearchTarget;
- (void)instrumentDidChangeSwitches;
- (void)instrumentChangedTableRequirements;
- (void)instrumentWillBecomeInvalid;
@end

@interface XRAnalysisCoreStandardController : NSObject <XRInstrumentViewController>
- (instancetype)initWithInstrument:(XRInstrument *)instrument document:(PFTTraceDocument *)document;
@end

@interface XRAnalysisCoreProjectionViewController : NSViewController <XRSearchTarget>
@end

typedef void XRAnalysisCoreReadCursor;
typedef union {
    UInt32 uint32;
    UInt64 uint64;
    UInt32 iid;
} XRStoredValue;

@interface XRAnalysisCoreValue : NSObject
- (XRStoredValue)storedValue;
- (id)objectValue;
@end

BOOL XRAnalysisCoreReadCursorNext(XRAnalysisCoreReadCursor *cursor);
SInt64 XRAnalysisCoreReadCursorColumnCount(XRAnalysisCoreReadCursor *cursor);
XRStoredValue XRAnalysisCoreReadCursorGetStored(XRAnalysisCoreReadCursor *cursor, UInt8 column);
int XRAnalysisCoreReadCursorGetValue(XRAnalysisCoreReadCursor *cursor, UInt8 column, XRAnalysisCoreValue * __strong *pointer);

@interface XREngineeringTypeFormatter : NSFormatter
@end

@interface XRAnalysisCoreFullTextSearchSpec : NSObject
- (XREngineeringTypeFormatter *)formatter;
@end

@interface XRAnalysisCoreTableQuery : NSObject
- (XRAnalysisCoreFullTextSearchSpec *)fullTextSearchSpec;
@end

@interface XRAnalysisCoreRowArray : NSObject {
    XRAnalysisCoreTableQuery *_filter;
}
@end

@interface XRAnalysisCorePivotArrayAccessor : NSObject
- (UInt64)rowInDimension:(UInt8)dimension closestToTime:(XRTime)time intersects:(SInt8 *)intersects;
- (void)readRowsStartingAt:(UInt64)index dimension:(UInt8)dimension block:(void (^)(XRAnalysisCoreReadCursor *cursor))block;
@end

@interface XRAnalysisCorePivotArray : NSObject
- (XRAnalysisCoreRowArray *)source;
- (UInt64)count;
- (void)access:(void (^)(XRAnalysisCorePivotArrayAccessor *accessor))block;
@end

@interface XRAnalysisCoreTableViewControllerResponse : NSObject
- (XRAnalysisCorePivotArray *)rows;
@end

@interface DTRenderableContentResponse : NSObject
- (XRAnalysisCoreTableViewControllerResponse *)content;

@property(nonatomic) unsigned long long serialNumber; // @synthesize serialNumber=_serialNumber;
@property(readonly, nonatomic, getter=isCancelled) BOOL cancelled; // @synthesize cancelled=_cancelled;
@property(retain, nonatomic) XRAnalysisCoreTableViewControllerResponse *content; // @synthesize content=_content;
@property(nonatomic) unsigned long long status; // @synthesize status=_status;
- (BOOL)_isFinished;
- (void)_cancel;

@end

@interface XRAnalysisCoreTableViewController : NSViewController <XRFilteredDataSource, XRSearchTarget>
- (DTRenderableContentResponse *)_currentResponse;
- (void)setDocumentInspectionTime:(XRTime)inspectionTime;
- (void)_retrieveResponse;
@end

@interface XRLegacyInstrument : XRInstrument <XRInstrumentViewController, XRContextContainer>
- (NSArray<XRContext *> *)_permittedContexts;
@end

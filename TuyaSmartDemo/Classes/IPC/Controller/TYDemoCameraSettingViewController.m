//
//  TYDemoCameraSettingViewController.m
//  TuyaSmartCamera_Example
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "TYDemoCameraSettingViewController.h"
#import "TuyaSmartSwitchCell.h"
#import "TYDemoCameraSDCardViewController.h"
#import "TPDemoProgressUtils.h"

#define kTitle  @"title"
#define kValue  @"value"
#define kAction @"action"
#define kArrow  @"arrow"
#define kSwitch @"switch"

@interface TYDemoCameraSettingViewController ()<TuyaSmartCameraDPObserver, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) BOOL indicatorOn;

@property (nonatomic, assign) BOOL flipOn;

@property (nonatomic, assign) BOOL osdOn;

@property (nonatomic, assign) BOOL privateOn;

@property (nonatomic, strong) TuyaSmartCameraNightvision nightvisionState;

@property (nonatomic, strong) TuyaSmartCameraPIR pirState;

@property (nonatomic, assign) BOOL motionDetectOn;

@property (nonatomic, strong) TuyaSmartCameraMotion motionSensitivity;

@property (nonatomic, assign) BOOL decibelDetectOn;

@property (nonatomic, strong) TuyaSmartCameraDecibel decibelSensitivity;

@property (nonatomic, assign) TuyaSmartCameraSDCardStatus sdCardStatus;

@property (nonatomic, assign) BOOL sdRecordOn;

@property (nonatomic, strong) TuyaSmartCameraRecordMode recordMode;

@property (nonatomic, assign) BOOL batteryLockOn;

@property (nonatomic, strong) TuyaSmartCameraPowerMode powerMode;

@property (nonatomic, assign) NSInteger electricity;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) TuyaSmartDevice *device;

@end

@implementation TYDemoCameraSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"ipc_panel_button_settings", @"");
    [self.dpManager addObserver:self];
    [self.tableView registerClass:[TuyaSmartSwitchCell class] forCellReuseIdentifier:@"switchCell"];
    [self getDeviceInfo];
    [self setupTableFooter];
    self.topBarView.leftItem = self.leftBackItem;
    
}

- (NSString *)titleForCenterItem {
    return NSLocalizedString(@"ipc_panel_button_settings", @"");
}

- (void)setupTableFooter {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 50)];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button setTitle:NSLocalizedString(@"cancel_connect", @"") forState:UIControlStateNormal];
    [footerView addSubview:button];
    self.tableView.tableFooterView = footerView;
    [button addTarget:self action:@selector(removeAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)removeAction {
    __weak typeof(self) weakSelf = self;
    [self.device remove:^{
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        NSLog(@"&&& remove device %@", error);
    }];
}

- (void)getDeviceInfo {
    if ([self.dpManager isSupportDP:TuyaSmartCameraBasicIndicatorDPName]) {
        self.indicatorOn = [[self.dpManager valueForDP:TuyaSmartCameraBasicIndicatorDPName] tysdk_toBool];
    }
    if ([self.dpManager isSupportDP:TuyaSmartCameraBasicFlipDPName]) {
        self.flipOn = [[self.dpManager valueForDP:TuyaSmartCameraBasicFlipDPName] tysdk_toBool];
    }
    if ([self.dpManager isSupportDP:TuyaSmartCameraBasicOSDDPName]) {
        self.osdOn = [[self.dpManager valueForDP:TuyaSmartCameraBasicOSDDPName] tysdk_toBool];
    }
    if ([self.dpManager isSupportDP:TuyaSmartCameraBasicPrivateDPName]) {
        self.privateOn = [[self.dpManager valueForDP:TuyaSmartCameraBasicPrivateDPName] tysdk_toBool];
    }
    if ([self.dpManager isSupportDP:TuyaSmartCameraBasicNightvisionDPName]) {
        self.nightvisionState = [[self.dpManager valueForDP:TuyaSmartCameraBasicNightvisionDPName] tysdk_toString];
    }
    if ([self.dpManager isSupportDP:TuyaSmartCameraBasicPIRDPName]) {
        self.pirState = [[self.dpManager valueForDP:TuyaSmartCameraBasicPIRDPName] tysdk_toString];
    }
    if ([self.dpManager isSupportDP:TuyaSmartCameraMotionDetectDPName]) {
        self.motionDetectOn = [[self.dpManager valueForDP:TuyaSmartCameraMotionDetectDPName] tysdk_toBool];
    }
    if ([self.dpManager isSupportDP:TuyaSmartCameraMotionSensitivityDPName]) {
        self.motionSensitivity = [[self.dpManager valueForDP:TuyaSmartCameraMotionSensitivityDPName] tysdk_toString];
    }
    if ([self.dpManager isSupportDP:TuyaSmartCameraDecibelDetectDPName]) {
        self.decibelDetectOn = [[self.dpManager valueForDP:TuyaSmartCameraDecibelDetectDPName] tysdk_toBool];
    }
    if ([self.dpManager isSupportDP:TuyaSmartCameraDecibelSensitivityDPName]) {
        self.decibelSensitivity = [[self.dpManager valueForDP:TuyaSmartCameraDecibelSensitivityDPName] tysdk_toString];
    }
    if ([self.dpManager isSupportDP:TuyaSmartCameraSDCardStatusDPName]) {
        self.sdCardStatus = [[self.dpManager valueForDP:TuyaSmartCameraSDCardStatusDPName] tysdk_toInt];
    }
    if ([self.dpManager isSupportDP:TuyaSmartCameraSDCardRecordDPName]) {
        self.sdRecordOn = [[self.dpManager valueForDP:TuyaSmartCameraSDCardRecordDPName] tysdk_toBool];
    }
    if ([self.dpManager isSupportDP:TuyaSmartCameraRecordModeDPName]) {
        self.recordMode = [[self.dpManager valueForDP:TuyaSmartCameraRecordModeDPName] tysdk_toString];
    }
    if ([self.dpManager isSupportDP:TuyaSmartCameraWirelessBatteryLockDPName]) {
        self.batteryLockOn = [[self.dpManager valueForDP:TuyaSmartCameraWirelessBatteryLockDPName] tysdk_toBool];
    }
    if ([self.dpManager isSupportDP:TuyaSmartCameraWirelessPowerModeDPName]) {
        self.powerMode = [[self.dpManager valueForDP:TuyaSmartCameraWirelessPowerModeDPName] tysdk_toString];
    }
    if ([self.dpManager isSupportDP:TuyaSmartCameraWirelessElectricityDPName]) {
        self.electricity = [[self.dpManager valueForDP:TuyaSmartCameraWirelessElectricityDPName] tysdk_toInt];
    }
    [self reloadData];
}

- (void)reloadData {
    NSMutableArray *dataSource = [NSMutableArray new];
    NSMutableArray *section0 = [NSMutableArray new];
    if ([self.dpManager isSupportDP:TuyaSmartCameraBasicIndicatorDPName]) {
        [section0 addObject:@{kTitle:NSLocalizedString(@"ipc_basic_status_indicator", @""), kValue: @(self.indicatorOn), kAction: @"indicatorAction:", kSwitch: @"1"}];
    }
    if ([self.dpManager isSupportDP:TuyaSmartCameraBasicFlipDPName]) {
        [section0 addObject:@{kTitle: NSLocalizedString(@"ipc_basic_picture_flip", @""), kValue: @(self.flipOn), kAction: @"flipAction:", kSwitch: @"1"}];
    }
    
    if ([self.dpManager isSupportDP:TuyaSmartCameraBasicOSDDPName]) {
        [section0 addObject:@{kTitle: NSLocalizedString(@"ipc_basic_osd_watermark", @""), kValue: @(self.osdOn), kAction: @"osdAction:", kSwitch: @"1"}];
    }
    
    if ([self.dpManager isSupportDP:TuyaSmartCameraBasicPrivateDPName]) {
        [section0 addObject:@{kTitle: NSLocalizedString(@"ipc_basic_hibernate", @""), kValue: @(self.privateOn), kAction: @"privateAction:", kSwitch: @"1"}];
    }
    
    if ([self.dpManager isSupportDP:TuyaSmartCameraBasicNightvisionDPName]) {
        NSString *text = [self nightvisionText:self.nightvisionState];
        [section0 addObject:@{kTitle: NSLocalizedString(@"ipc_basic_night_vision", @""), kValue: text, kAction: @"nightvisionAction", kArrow: @"1"}];
    }
    
    if ([self.dpManager isSupportDP:TuyaSmartCameraBasicPIRDPName]) {
        NSString *text = [self pirText:self.pirState];
        [section0 addObject:@{kTitle: NSLocalizedString(@"ipc_pir_switch", @""), kValue: text, kAction: @"pirAction", kArrow: @"1"}];
    }
    
    if (section0.count > 0) {
        [dataSource addObject:@{kTitle:NSLocalizedString(@"ipc_settings_page_basic_function_txt", @""), kValue: section0.copy}];
    }
    
    NSMutableArray *section1 = [NSMutableArray new];
    if ([self.dpManager isSupportDP:TuyaSmartCameraMotionDetectDPName]) {
        [section1 addObject:@{kTitle: NSLocalizedString(@"ipc_live_page_cstorage_motion_detected", @""), kValue: @(self.motionDetectOn), kAction: @"motionDetectAction:", kSwitch: @"1"}];
    }
    
    if ([self.dpManager isSupportDP:TuyaSmartCameraMotionSensitivityDPName] && self.motionDetectOn) {
        NSString *text = [self motionSensitivityText:self.motionSensitivity];
        [section1 addObject:@{kTitle: NSLocalizedString(@"ipc_motion_sensitivity_settings", @""), kValue: text, kAction: @"motionSensitivityAction", kArrow: @"1"}];
    }
    if (section1.count > 0) {
        [dataSource addObject:@{kTitle: NSLocalizedString(@"ipc_live_page_cstorage_motion_detected", @""), kValue: section1.copy}];
    }
    
    NSMutableArray *section2 = [NSMutableArray new];
    if ([self.dpManager isSupportDP:TuyaSmartCameraDecibelDetectDPName]) {
        [section2 addObject:@{kTitle: NSLocalizedString(@"ipc_sound_detect_switch", @""), kValue: @(self.decibelDetectOn), kAction: @"decibelDetectAction:", kSwitch: @"1"}];
    }
    
    if ([self.dpManager isSupportDP:TuyaSmartCameraDecibelSensitivityDPName] && self.decibelDetectOn) {
        NSString *text = [self decibelSensitivityText:self.decibelSensitivity];
        [section2 addObject:@{kTitle: NSLocalizedString(@"ipc_motion_sensitivity_settings", @""), kValue: text, kAction: @"decibelSensitivityAction", kArrow: @"1"}];
    }
    if (section2.count > 0) {
        [dataSource addObject:@{kTitle: NSLocalizedString(@"ipc_sound_detected_switch_settings", @""), kValue: section2.copy}];
    }
    
    NSMutableArray *section3 = [NSMutableArray new];
    if ([self.dpManager isSupportDP:TuyaSmartCameraSDCardStatusDPName]) {
        NSString *text = [self sdCardStatusText:self.sdCardStatus];
        [section3 addObject:@{kTitle: NSLocalizedString(@"ipc_sdcard_settings", @""), kValue: text, kAction: @"sdCardAction", kArrow: @"1"}];
    }
    
    if ([self.dpManager isSupportDP:TuyaSmartCameraSDCardRecordDPName]) {
        [section3 addObject:@{kTitle: NSLocalizedString(@"ipc_sdcard_record_switch", @""), kValue: @(self.sdRecordOn), kAction: @"sdRecordAction:", kSwitch: @"1"}];
    }
    
    if ([self.dpManager isSupportDP:TuyaSmartCameraRecordModeDPName]) {
        NSString *text = [self recordModeText:self.recordMode];
        [section3 addObject:@{kTitle: NSLocalizedString(@"ipc_sdcard_record_mode_settings", @""), kValue: text, kAction: @"recordModeAction", kArrow: @"1"}];
    }
    if (section3.count > 0) {
        [dataSource addObject:@{kTitle: NSLocalizedString(@"ipc_sdcard_settings", @""), kValue: section3.copy}];
    }
    
    NSMutableArray *section4 = [NSMutableArray new];
    if ([self.dpManager isSupportDP:TuyaSmartCameraWirelessBatteryLockDPName]) {
        [section4 addObject:@{kTitle: NSLocalizedString(@"ipc_basic_batterylock", @""), kValue: @(self.batteryLockOn), kAction: @"batteryLockAction:", kSwitch: @"1"}];
    }
    
    if ([self.dpManager isSupportDP:TuyaSmartCameraWirelessPowerModeDPName]) {
        NSString *text = [self powerModeText:self.powerMode];
        [section4 addObject:@{kTitle: NSLocalizedString(@"ipc_electric_power_source", @""), kValue: text}];
    }
    
    if ([self.dpManager isSupportDP:TuyaSmartCameraWirelessElectricityDPName]) {
        NSString *text = [self electricityText];
        [section4 addObject:@{kTitle: NSLocalizedString(@"ipc_electric_percentage", @""), kValue: text}];
    }
    if (section4.count > 0) {
        [dataSource addObject:@{kTitle: NSLocalizedString(@"ipc_electric_title", @""), kValue: section4.copy}];
    }
    self.dataSource = [dataSource copy];
    [self.tableView reloadData];
}

- (void)indicatorAction:(UISwitch *)switchButton {
    __weak typeof(self) weakSelf = self;
    [self.dpManager setValue:@(switchButton.on) forDP:TuyaSmartCameraBasicIndicatorDPName success:^(id result) {
        weakSelf.indicatorOn = switchButton.on;
    } failure:^(NSError *error) {
        [weakSelf reloadData];
    }];
}

- (void)flipAction:(UISwitch *)switchButton {
    __weak typeof(self) weakSelf = self;
    [self.dpManager setValue:@(switchButton.on) forDP:TuyaSmartCameraBasicFlipDPName success:^(id result) {
        weakSelf.flipOn = switchButton.on;
    } failure:^(NSError *error) {
        [weakSelf reloadData];
    }];
}

- (void)osdAction:(UISwitch *)switchButton {
    __weak typeof(self) weakSelf = self;
    [self.dpManager setValue:@(switchButton.on) forDP:TuyaSmartCameraBasicOSDDPName success:^(id result) {
        weakSelf.osdOn = switchButton.on;
    } failure:^(NSError *error) {
        [weakSelf reloadData];
    }];
}

- (void)privateAction:(UISwitch *)switchButton {
    __weak typeof(self) weakSelf = self;
    [self.dpManager setValue:@(switchButton.on) forDP:TuyaSmartCameraBasicPrivateDPName success:^(id result) {
        weakSelf.privateOn = switchButton.on;
    } failure:^(NSError *error) {
        [weakSelf reloadData];
    }];
}

- (void)nightvisionAction {
    NSArray *options = @[@{kTitle: [self nightvisionText:TuyaSmartCameraNightvisionAuto],
                           kValue: TuyaSmartCameraNightvisionAuto},
                         @{kTitle: [self nightvisionText:TuyaSmartCameraNightvisionOn],
                           kValue: TuyaSmartCameraNightvisionOn},
                         @{kTitle: [self nightvisionText:TuyaSmartCameraNightvisionOff],
                           kValue: TuyaSmartCameraNightvisionOff}];
    __weak typeof(self) weakSelf = self;
    [self showActionSheet:options selectedHandler:^(id result) {
        [self.dpManager setValue:result forDP:TuyaSmartCameraBasicNightvisionDPName success:^(id result) {
            weakSelf.nightvisionState = result;
            [weakSelf reloadData];
        } failure:^(NSError *error) {
            
        }];
    }];
}

- (void)pirAction {
    NSArray *options = @[@{kTitle: [self pirText:TuyaSmartCameraPIRStateHigh],
                           kValue: TuyaSmartCameraPIRStateHigh},
                         @{kTitle: [self pirText:TuyaSmartCameraPIRStateMedium],
                           kValue: TuyaSmartCameraPIRStateMedium},
                         @{kTitle: [self pirText:TuyaSmartCameraPIRStateLow],
                           kValue: TuyaSmartCameraPIRStateLow},
                         @{kTitle: [self pirText:TuyaSmartCameraPIRStateOff],
                           kValue: TuyaSmartCameraPIRStateOff}];
    __weak typeof(self) weakSelf = self;
    [self showActionSheet:options selectedHandler:^(id result) {
        [self.dpManager setValue:result forDP:TuyaSmartCameraBasicPIRDPName success:^(id result) {
            weakSelf.pirState = result;
            [weakSelf reloadData];
        } failure:^(NSError *error) {
            
        }];
    }];
}

- (void)motionDetectAction:(UISwitch *)switchButton {
    __weak typeof(self) weakSelf = self;
    [self.dpManager setValue:@(switchButton.on) forDP:TuyaSmartCameraMotionDetectDPName success:^(id result) {
        weakSelf.motionDetectOn = switchButton.on;
        [weakSelf reloadData];
    } failure:^(NSError *error) {
        [weakSelf reloadData];
    }];
}

- (void)motionSensitivityAction {
    NSArray *options = @[@{kTitle: [self motionSensitivityText:TuyaSmartCameraMotionHigh],
                           kValue: TuyaSmartCameraMotionHigh},
                         @{kTitle: [self motionSensitivityText:TuyaSmartCameraMotionMedium],
                           kValue: TuyaSmartCameraMotionMedium},
                         @{kTitle: [self motionSensitivityText:TuyaSmartCameraMotionLow],
                           kValue: TuyaSmartCameraMotionLow}];
    __weak typeof(self) weakSelf = self;
    [self showActionSheet:options selectedHandler:^(id result) {
        [self.dpManager setValue:result forDP:TuyaSmartCameraMotionSensitivityDPName success:^(id result) {
            weakSelf.motionSensitivity = result;
            [weakSelf reloadData];
        } failure:^(NSError *error) {
            
        }];
    }];
}

- (void)decibelDetectAction:(UISwitch *)switchButton {
    __weak typeof(self) weakSelf = self;
    [self.dpManager setValue:@(switchButton.on) forDP:TuyaSmartCameraDecibelDetectDPName success:^(id result) {
        weakSelf.decibelDetectOn = switchButton.on;
        [weakSelf reloadData];
    } failure:^(NSError *error) {
        [weakSelf reloadData];
    }];
}

- (void)decibelSensitivityAction {
    NSArray *options = @[@{kTitle: [self decibelSensitivityText:TuyaSmartCameraDecibelHigh],
                           kValue: TuyaSmartCameraDecibelHigh},
                         @{kTitle: [self decibelSensitivityText:TuyaSmartCameraDecibelLow],
                           kValue: TuyaSmartCameraDecibelLow}];
    __weak typeof(self) weakSelf = self;
    [self showActionSheet:options selectedHandler:^(id result) {
        [self.dpManager setValue:result forDP:TuyaSmartCameraDecibelSensitivityDPName success:^(id result) {
            weakSelf.decibelSensitivity = result;
            [weakSelf reloadData];
        } failure:^(NSError *error) {
            
        }];
    }];
}

- (void)sdCardAction {
    TYDemoCameraSDCardViewController *vc = [TYDemoCameraSDCardViewController new];
    vc.dpManager = self.dpManager;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)sdRecordAction:(UISwitch *)switchButton {
    __weak typeof(self) weakSelf = self;
    [self.dpManager setValue:@(switchButton.on) forDP:TuyaSmartCameraSDCardRecordDPName success:^(id result) {
        weakSelf.sdRecordOn = switchButton.on;
    } failure:^(NSError *error) {
        [weakSelf reloadData];
    }];
}

- (void)recordModeAction {
    NSArray *options = @[@{kTitle: [self recordModeText:TuyaSmartCameraRecordModeEvent],
                           kValue: TuyaSmartCameraRecordModeEvent},
                         @{kTitle: [self recordModeText:TuyaSmartCameraRecordModeAlways],
                           kValue: TuyaSmartCameraRecordModeAlways}];
    __weak typeof(self) weakSelf = self;
    [self showActionSheet:options selectedHandler:^(id result) {
        
        [self.dpManager setValue:result forDP:TuyaSmartCameraRecordModeDPName success:^(id result) {
            weakSelf.recordMode = result;
            [weakSelf reloadData];
        } failure:^(NSError *error) {
            
        }];
    }];
}

- (void)batteryLockAction:(UISwitch *)switchButton {
    __weak typeof(self) weakSelf = self;
    [self.dpManager setValue:@(switchButton.on) forDP:TuyaSmartCameraWirelessBatteryLockDPName success:^(id result) {
        weakSelf.batteryLockOn = switchButton.on;
    } failure:^(NSError *error) {
        [weakSelf reloadData];
    }];
}

- (NSString *)nightvisionText:(TuyaSmartCameraNightvision)state {
    if ([state isEqualToString:TuyaSmartCameraNightvisionAuto]) {
        return NSLocalizedString(@"ipc_basic_night_vision_auto", @"");
    }
    if ([state isEqualToString:TuyaSmartCameraNightvisionOn]) {
        return NSLocalizedString(@"ipc_basic_night_vision_on", @"");
    }
    return NSLocalizedString(@"ipc_basic_night_vision_off", @"");
}

- (NSString *)pirText:(TuyaSmartCameraPIR)state {
    if ([state isEqualToString:TuyaSmartCameraPIRStateLow]) {
        return NSLocalizedString(@"ipc_settings_status_low", @"");
    }
    if ([state isEqualToString:TuyaSmartCameraPIRStateMedium]) {
        return NSLocalizedString(@"ipc_settings_status_mid", @"");
    }
    if ([state isEqualToString:TuyaSmartCameraPIRStateHigh]) {
        return NSLocalizedString(@"ipc_settings_status_high", @"");
    }
    return NSLocalizedString(@"ipc_settings_status_off", @"");
}

- (NSString *)motionSensitivityText:(TuyaSmartCameraMotion)sensitivity {
    if ([sensitivity isEqualToString:TuyaSmartCameraMotionLow]) {
        return NSLocalizedString(@"ipc_motion_sensitivity_low", @"");
    }
    if ([sensitivity isEqualToString:TuyaSmartCameraMotionMedium]) {
        return NSLocalizedString(@"ipc_motion_sensitivity_mid", @"");
    }
    if ([sensitivity isEqualToString:TuyaSmartCameraMotionHigh]) {
        return NSLocalizedString(@"ipc_motion_sensitivity_high", @"");
    }
    return @"";
}

- (NSString *)decibelSensitivityText:(TuyaSmartCameraDecibel)sensitivity {
    if ([sensitivity isEqualToString:TuyaSmartCameraDecibelLow]) {
        return NSLocalizedString(@"ipc_sound_sensitivity_low", @"");
    }
    if ([sensitivity isEqualToString:TuyaSmartCameraDecibelHigh]) {
        return NSLocalizedString(@"ipc_sound_sensitivity_high", @"");
    }
    return @"";
}

- (NSString *)sdCardStatusText:(TuyaSmartCameraSDCardStatus)status {
    switch (status) {
        case TuyaSmartCameraSDCardStatusNormal:
            return NSLocalizedString(@"Normally", @"");
        case TuyaSmartCameraSDCardStatusException:
            return NSLocalizedString(@"Abnormally", @"");
        case TuyaSmartCameraSDCardStatusMemoryLow:
            return NSLocalizedString(@"Insufficient capacity", @"");
        case TuyaSmartCameraSDCardStatusFormatting:
            return NSLocalizedString(@"ipc_status_sdcard_format", @"");
        default:
            return NSLocalizedString(@"pps_no_sdcard", @"");
    }
}

- (NSString *)recordModeText:(TuyaSmartCameraRecordMode)mode {
    if ([mode isEqualToString:TuyaSmartCameraRecordModeEvent]) {
        return NSLocalizedString(@"ipc_sdcard_record_mode_event", @"");
    }
    return NSLocalizedString(@"ipc_sdcard_record_mode_ctns", @"");
}

- (NSString *)powerModeText:(TuyaSmartCameraPowerMode)mode {
    if ([mode isEqualToString:TuyaSmartCameraPowerModePlug]) {
        return NSLocalizedString(@"ipc_electric_power_source_wire", @"");
    }
    return NSLocalizedString(@"ipc_electric_power_source_batt", @"");
}

- (NSString *)electricityText {
    return [NSString stringWithFormat:@"%@%%", @(self.electricity)];
}

- (void)showActionSheet:(NSArray *)options selectedHandler:(void(^)(id result))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    [options enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:[obj objectForKey:kTitle] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            if (handler) {
                handler([obj objectForKey:kValue]);
            }
        }];
        [alert addAction:action];
    }];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - dpmanagerobserver

- (void)cameraDPDidUpdate:(TuyaSmartCameraDPManager *)manager dps:(NSDictionary *)dpsData {
    if ([dpsData objectForKey:TuyaSmartCameraWirelessElectricityDPName]) {
        self.electricity = [[dpsData objectForKey:TuyaSmartCameraWirelessElectricityDPName] integerValue];
        [self reloadData];
    }
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self.dataSource objectAtIndex:section] objectForKey:kTitle];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.dataSource objectAtIndex:section] objectForKey:kValue] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = [[[self.dataSource objectAtIndex:indexPath.section] valueForKey:kValue] objectAtIndex:indexPath.row];
    if ([data objectForKey:kSwitch]) {
        TuyaSmartSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"switchCell"];
        BOOL value = [[data objectForKey:kValue] boolValue];
        SEL action = NSSelectorFromString([data objectForKey:kAction]);
        [cell setValueChangedTarget:self selector:action value:value];
        cell.textLabel.text = [data objectForKey:kTitle];
        return cell;
    }else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"defaultCell"];
        }
        cell.textLabel.text = [data objectForKey:kTitle];
        cell.detailTextLabel.text = [data objectForKey:kValue];
        if ([data objectForKey:kArrow]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = [[[self.dataSource objectAtIndex:indexPath.section] objectForKey:kValue] objectAtIndex:indexPath.row];
    if (![data objectForKey:kSwitch]) {
        NSString *action = [data objectForKey:kAction];
        if (action) {
            SEL selector = NSSelectorFromString(action);
            [self performSelector:selector withObject:nil afterDelay:0];
        }
    }
}

- (TuyaSmartDevice *)device {
    if (!_device) {
        _device = [TuyaSmartDevice deviceWithDeviceId:self.devId];
    }
    return _device;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, APP_TOP_BAR_HEIGHT, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT - APP_TOP_BAR_HEIGHT) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end

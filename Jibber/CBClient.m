//
//  CBClient.m
//  CBServer
//
//  Created by Matthew Cheok on 8/8/15.
//  Copyright © 2015 Matthew Cheok. All rights reserved.
//

#import "CBClient.h"
@import CoreBluetooth;

#define CBCLIENT_SERVICE_UUID @"349B8685-7684-40CE-AA80-40E2F47BD8A6"

@interface CBClient () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) NSMutableArray *peripherals;
@property (nonatomic, strong) NSMapTable *queue;
@property (nonatomic, copy, readwrite) NSString *uuid;

@end

@implementation CBClient

- (instancetype)initWithUUID:(NSString *)uuid {
    self = [super init];
    if (self) {
        self.uuid = uuid;
        self.queue = [NSMapTable strongToStrongObjectsMapTable];
        self.peripherals = [NSMutableArray array];
        
        [self setup];
    }
    return self;
}

- (void)setup {
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void)startScanning {
    NSLog(@"CBClient: Begin scanning");
    [self.manager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:CBCLIENT_SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
}

- (void)stopScanning {
    [self.manager stopScan];
}

- (void)processData:(NSData *)data {
    if ([self.delegate respondsToSelector:@selector(client:didReceiveData:)]) {
        [self.delegate client:self didReceiveData:data];
    }
}

- (void)cleanupPeripheral:(CBPeripheral *)periperhal {
    [self.queue removeObjectForKey:periperhal];
    [self.peripherals removeObject:periperhal];

    // Don't do anything if we're not connected
    if (periperhal.state != CBPeripheralStateConnected) {
        return;
    }
    
    // See if we are subscribed to a characteristic on the peripheral
    if (periperhal.services != nil) {
        for (CBService *service in periperhal.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:self.uuid]]) {
                        if (characteristic.isNotifying) {
                            // It is notifying, so unsubscribe
                            [periperhal setNotifyValue:NO forCharacteristic:characteristic];
                            
                            // And we're done.
                            return;
                        }
                    }
                }
            }
        }
    }
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self.manager cancelPeripheralConnection:periperhal];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    if (central.state == CBCentralManagerStateUnsupported) {
        NSLog(@"Warning: Could not initialize Core Bluetooth!");
    }
    
    else if (central.state == CBCentralManagerStatePoweredOn) {
        [self startScanning];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // Reject any where the value is above reasonable range
    if (RSSI.integerValue > -15) {
        return;
    }
    
    // Reject if the signal strength is too low to be close enough (Close is around -22dB)
//    if (RSSI.integerValue < -35) {
//        return;
//    }
    
    // Ok, it's in range - have we already seen it?
    if (![self.peripherals containsObject:peripheral]) {
        NSLog(@"CBClient: Discovered peripheral %@ at %@", peripheral.name, RSSI);
        [self.peripherals addObject:peripheral];
        [self.manager cancelPeripheralConnection:peripheral];
        [self.manager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(nonnull CBCentralManager *)central didDisconnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error {
    NSLog(@"CBClient: Disconnected from peripheral %@", peripheral.name);
    [self cleanupPeripheral:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"CBClient: Failed to connect to %@. (%@)", peripheral.name, [error localizedDescription]);
    [self cleanupPeripheral:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"CBClient: Connected to peripheral %@", peripheral.name);
    
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    if (peripheral.services) {
        [self peripheral:peripheral didDiscoverServices:nil]; //already discovered services, DO NOT re-discover. Just pass along the peripheral.
    }
    else {
        [peripheral discoverServices:@[[CBUUID UUIDWithString:CBCLIENT_SERVICE_UUID]]];
    }
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"CBClient: Error discovering services: %@", [error localizedDescription]);
        [self cleanupPeripheral:peripheral];
        return;
    }
    
    NSLog(@"CBClient: Discovering characteristics for peripheral %@", peripheral.name);
    
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        NSLog(@"CBClient: Initializing with UUID %@ for service %@", self.uuid, service.UUID);
        if (service.characteristics) {
            NSLog(@"CBClient: Already have service characteristics");
            [self peripheral:peripheral didDiscoverCharacteristicsForService:service error:nil];
        }
        else {
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:self.uuid]] forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Deal with errors (if any)
    if (error) {
        NSLog(@"CBClient: Error discovering characteristics: %@", [error localizedDescription]);
        [self cleanupPeripheral:peripheral];
        return;
    }
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        // And check if it's the right one
        NSLog(@"CBClient: Found characteristic %@", characteristic.UUID);
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:self.uuid]]) {
            
            // If it is, subscribe to it
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            NSLog(@"CBClient: Subscribing");
        }
    }
    
    // Once this is complete, we just need to wait for the data to come in.
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"CBClient: Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    NSData *data = characteristic.value;
    NSMutableData *buffer = [self.queue objectForKey:peripheral];
    
    if (data.length == 0) {
        if (buffer.length > 0) {
            [self processData:[buffer copy]];
        }
        else if (!buffer) {
            buffer = [NSMutableData data];
            [self.queue setObject:buffer forKey:peripheral];
        }
        [buffer setData:[NSData data]];
    }
    else {
        [buffer appendData:data];
    }
}

@end

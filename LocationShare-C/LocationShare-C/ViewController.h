//
//  ViewController.h
//  LocationShare-C
//
//  Created by sudhakkar on 07/03/17.
//  Copyright © 2017 perceptionSketch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"

@interface ViewController : UIViewController<CLLocationManagerDelegate,MKMapViewDelegate>


@property(weak, nonatomic) IBOutlet UILabel *lblTitle;

@property(weak, nonatomic) IBOutlet UIButton *btnCheckIn;

@property(weak, nonatomic) IBOutlet UIButton *btnShowAll;

@property (weak, nonatomic) IBOutlet MKMapView *Mapsview;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property(strong, nonatomic) CLLocation * currentLocation;

@property (nonatomic, retain) MKPolyline *routeLine; //your line

@property (nonatomic, retain) MKPolylineView *routeLineView; //overlay view

@property (strong, nonatomic)  NSMutableArray *longArray;

@property (strong, nonatomic)  NSMutableArray *datesArray;

@property (strong, nonatomic)  NSMutableArray *locationArray;



@property (strong, nonatomic)  NSMutableArray *latArray;

@property (strong, nonatomic)  NSMutableDictionary *DictLocation;


- (IBAction)btnCheckInClicked:(id)sender;

- (IBAction)btnShowAllCLicked:(id)sender;


@end


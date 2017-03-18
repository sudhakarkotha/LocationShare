//
//  ViewController.m
//  LocationShare-C
//
//  Created by sudhakkar on 07/03/17.
//  Copyright © 2017 perceptionSketch. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSMutableArray *arrLocation;
    MKPointAnnotation *point;
    MKPointAnnotation *showMapPin;
}

@end

@implementation ViewController
@synthesize btnCheckIn,btnShowAll,Mapsview,locationManager,currentLocation,longArray,latArray,DictLocation,datesArray,locationArray;
@synthesize routeLine,routeLineView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.navigationController setNavigationBarHidden:YES ];
    
    latArray=[[NSMutableArray alloc]init];
    latArray=[[NSMutableArray alloc]init];
    datesArray = [[NSMutableArray alloc]init];
    locationArray = [[NSMutableArray alloc]init];
    arrLocation = [[NSMutableArray alloc]init];

    
    DictLocation=[[NSMutableDictionary alloc]init];
    self.Mapsview.delegate = self;
    [self.Mapsview setShowsUserLocation: YES];
    self.Mapsview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self CurrentUserLocationIdentifier];

    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES ];

}

- (AppDelegate *)appDelegate
{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

-(void) CurrentUserLocationIdentifier
{
    locationManager =[CLLocationManager new];

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
}

-(void)addAllPins
{
    
    arrLocation = [[self appDelegate] arrayLocation];
    NSLog(@"locations to use %@", arrLocation.description);

    
        for(int i = 0; i < arrLocation.count; i++)
    {
        [self addPinWithTitle:@"location" AndCoordinate:arrLocation[i]];
    }
    
    [self drawRoutLine];
}


-(void)addPinWithTitle:(NSString *)title AndCoordinate:(NSString *)strCoordinate
{
    showMapPin = [[MKPointAnnotation alloc] init];
    
    strCoordinate = [strCoordinate stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSArray *components = [strCoordinate componentsSeparatedByString:@","];
    
    double latitude = [components[0] doubleValue];
    double longitude = [components[1] doubleValue];
    
    MKCoordinateRegion region = self.Mapsview.region;
    region.center = CLLocationCoordinate2DMake(latitude, longitude);
    region.span.longitudeDelta /= 0.01; // Bigger the value, closer the map view
        region.span.latitudeDelta /= 0.01;
    [self.Mapsview setRegion:region animated:YES];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    showMapPin.title = title;
    showMapPin.subtitle = components[2];
    showMapPin.coordinate = coordinate;
    
    [self.Mapsview addAnnotation:showMapPin];
    
    
    
}

-(void)drawRoutLine
{
    MKMapPoint* pointArr = malloc(sizeof(CLLocationCoordinate2D) * [arrLocation count]);
    
   
    for(int idx = 0; idx < [arrLocation count]; idx++)
    {
        NSString *strCoordinate = [arrLocation[idx] stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSArray *components = [strCoordinate componentsSeparatedByString:@","];
        
        double latitude = [components[0] doubleValue];
        double longitude = [components[1] doubleValue];
        
        CLLocationCoordinate2D workingCoordinate;
        workingCoordinate.latitude= latitude;
        workingCoordinate.longitude= longitude;
       
        MKMapPoint point = MKMapPointForCoordinate(workingCoordinate);
        pointArr[idx] = point;
    }
    // create the polyline based on the array of points.
    routeLine = [MKPolyline polylineWithPoints:pointArr count:[arrLocation count]];
    [Mapsview addOverlay:self.routeLine];
    free(pointArr);
}

- (IBAction)btnCheckInClicked:(id)sender {
    
    [Mapsview removeAnnotations:Mapsview.annotations];
    
    [Mapsview removeOverlays:Mapsview.overlays];

    [self.Mapsview setShowsUserLocation: YES];

    [self CurrentUserLocationIdentifier];

    
    
    
    UIAlertController * alert=[UIAlertController
                               
                               alertControllerWithTitle:@"Title" message:@"Do you want to save Location."preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* btnCancle = [UIAlertAction
                                actionWithTitle:@"Cancle"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    
                                }];
    UIAlertAction* btnOK = [UIAlertAction
                            actionWithTitle:@"OK"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                
                                float Lat = locationManager.location.coordinate.latitude;
                                float Long = locationManager.location.coordinate.longitude;
                                NSLog(@"Lat : %f  Long : %f",Lat,Long);
                                
                                
                                NSDate *todayDate = [NSDate date];                                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                [dateFormatter setDateFormat:@"MM-dd-yyyy"];
                                NSString *convertedDateString = [dateFormatter stringFromDate:todayDate];
                                NSLog(@"Today formatted date is %@",convertedDateString);
                                
                                NSString *strLocation= [NSString stringWithFormat:@"%f,%f,%@",Lat,Long,convertedDateString];
                                
                                NSLog(@"this is location %@", strLocation);
                                
                                
                                [[self appDelegate] insertUserDataIntoDatabase:strLocation];
                            }];
    
    [alert addAction:btnCancle];
    [alert addAction:btnOK];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)btnShowAllCLicked:(id)sender {
    
    
    [[self appDelegate] userLocations];
    
    [self.Mapsview setShowsUserLocation: NO];
    [self.Mapsview removeAnnotation:point];
    [self addAllPins];
    
   
    
}

#pragma Map view delegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1000, 1000);
    [self.Mapsview setRegion:[self.Mapsview regionThatFits:region] animated:YES];
    
     point = [[MKPointAnnotation alloc] init];
    point.coordinate = userLocation.coordinate;
    point.title = @"Current Location";
    point.subtitle = @"I'm here!!!";

    [self.Mapsview addAnnotation:point];

}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
       
        renderer.fillColor   = [[UIColor cyanColor] colorWithAlphaComponent:0.2];

        renderer.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.50];
         renderer.lineWidth = 3;
        return renderer;
    }
    return nil;
}
//-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
//{
//    
//    if ([overlay isKindOfClass:[MKPolyline class]]) {
//        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
//        renderer.lineWidth = 4;
//        renderer.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.50];
//        return renderer;
//    }
//    return nil;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

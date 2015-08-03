//
//  MapViewController.swift
//  ParseStarterProject
//
//  Created by Jay Ravaliya on 8/2/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // create mapview and array for all pins
    var mapView : MKMapView = MKMapView()
    var allPins : [MKPointAnnotation] = []
    
    var swiftyJSON : JSON!
    var yourLocation : [Float]!
    var yourFriendLocation : [Float]!
    var midpointCoordinates : [Float]!
    
    // create reset button
    var reset : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set title, establish viewcontroller's background color
        self.title = "Map"
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        // develop mapView
        mapView.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)
        mapView.mapType = MKMapType.Standard
        mapView.zoomEnabled = true
        mapView.scrollEnabled = true
        mapView.delegate = self
        view.addSubview(mapView)
        
        // develop reset button to set map back to original view
        reset = UIBarButtonItem(title: "Reset", style: UIBarButtonItemStyle.Plain, target: self, action: "resetPressed:")
        self.navigationItem.rightBarButtonItem = reset
        
        // for each location in the array
        for var i = 0; i < swiftyJSON["results"].count; i++
        {
            // append new point annotation to array, set the i'th coordinates to a location variable.
            // set title and coordinates to the allPins' i'th MKPointAnnotation
            // add to map!
            
            allPins.append(MKPointAnnotation())
            var location:CLLocation = CLLocation(latitude: swiftyJSON["results"][i]["geometry"]["location"]["lat"].doubleValue, longitude: swiftyJSON["results"][i]["geometry"]["location"]["lng"].doubleValue)
            allPins[i].coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            allPins[i].title = swiftyJSON["results"][i]["name"].stringValue
            mapView.addAnnotation(allPins[i])
        }
        
        // do the same as above, but for your and your friend's location
        allPins.append(MKPointAnnotation())
        allPins[allPins.count - 1].coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(yourLocation[0]), CLLocationDegrees(yourLocation[1]))
        allPins[allPins.count - 1].title = "Your Location"
        mapView.addAnnotation(allPins[allPins.count - 1])
        
        allPins.append(MKPointAnnotation())
        allPins[allPins.count - 1].coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(yourFriendLocation[0]), CLLocationDegrees(yourFriendLocation[1]))
        allPins[allPins.count - 1].title = "Your Friend's Location"
        mapView.addAnnotation(allPins[allPins.count - 1])
        
        // set the center equal to the midpoint, and set the span equal to 2 times the difference
        // between your and your friend's locations.
        // set the region for the mapView
        var location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: CLLocationDegrees(midpointCoordinates[0]), longitude: CLLocationDegrees(midpointCoordinates[1]))
        var coordinateRegion = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(abs(yourLocation[0] - yourFriendLocation[0])*2), longitudeDelta: CLLocationDegrees(abs(yourLocation[1] - yourFriendLocation[1]))*2))
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // method for when reset button is pressed/
    // purpose is to reset map back to original settings - shown below
    func resetPressed(sender: UIBarButtonItem!)
    {
        var location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: swiftyJSON["results"][0]["geometry"]["location"]["lat"].doubleValue, longitude: swiftyJSON["results"][0]["geometry"]["location"]["lng"].doubleValue)
        
        var coordinateRegion = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(abs(yourLocation[0] - yourFriendLocation[0])*2), longitudeDelta: CLLocationDegrees(abs(yourLocation[1] - yourFriendLocation[1]))*2))
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}

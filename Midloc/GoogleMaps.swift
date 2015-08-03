//
//  GoogleMaps.swift
//  Midloc
//
//  Created by Jay Ravaliya on 7/31/15.
//  Copyright (c) 2015 JRav. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GoogleMaps {
    
    var latitude : CGFloat!
    var longitude : CGFloat!
    
    /*
    *  Sends a request to Google Maps API to return a JSON list of restaurants.
    */
    func googleMapsRequest(midpointCoordinates : [Float], types : String, completion : (swiftyJSON:JSON) -> Void) {
        
        var swiftyJSON : JSON = []
        
        let parameters = [
            "location" : "\(midpointCoordinates[0]),\(midpointCoordinates[1])",
            "rankby" : "distance",
            "types" : types,
            "key" : GOOGLE_MAPS_KEY
        ];
        
        Alamofire.request(.GET, "https://maps.googleapis.com/maps/api/place/nearbysearch/json", parameters: parameters).responseJSON { (request, response, data, error) -> Void in
            if(error == nil) {
                if let responseData : AnyObject? = data {
                    swiftyJSON = JSON(responseData!)
                    completion(swiftyJSON:swiftyJSON)
                }
            }
            
        }
        
        
    }
    
    func zipToLatitudeLongitude(zipCode : String, completion: (data: JSON) -> Void) {
        var swiftyJSON : JSON = []
        
        let parameters = [
            "zip" : zipCode,
            "key" : JR_API_KEY
        ];
        
        Alamofire.request(.GET, "http://midloc.herokuapp.com/zipcode/api/v0.1", parameters: parameters).responseJSON { (request, response, data, error) -> Void in
            
            if(error == nil) {
                if let returnData : AnyObject? = data {
                    completion(data: JSON(returnData!))
                }
            }
            else {
                println(error)
            }
        }
        
    }
}
//
//  DetailsViewController.swift
//  ParseStarterProject
//
//  Created by Jay Ravaliya on 8/2/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import MessageUI
import MapKit
import SwiftyJSON
import Social

// CircleView class - subclass of UIView - that will draw the circles for Price and Ratings
class CircleView : UIView
{
    
    // property for color
    var desiredColor : UIColor = UIColor.blackColor()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // draw UIBezierPath
    override func drawRect(rect: CGRect) {
        var ovalPath = UIBezierPath(ovalInRect: CGRectMake(0, 0, 20, 20))
        desiredColor.setFill()
        ovalPath.fill()
    }
}

class DetailsViewController: UIViewController, MKMapViewDelegate {
    
    // create message composer
    let message = MessageComposer()
    
    // create all buttons and views
    var mainButton : UIButton! // opens ActionSheet
    var mapView : MKMapView! // adds map to view
    var rgn : MKCoordinateRegion! // sets up the zoomed in region
    var pin : MKPointAnnotation! // drops a pin on location
    var restaurantPic : UIImageView! // shows the resturant image
    var nameLabel : UILabel! // name of restaurant
    var resetButton : UIBarButtonItem! // resets map back to normal zoom
    var vicinityLabel : UILabel! // shows the approx. address of the restaurant
    var ratingLabel : UILabel! // stores the word "Rating"
    var priceLabel : UILabel! // stores the word "Price"
    var activityIndicator : UIActivityIndicatorView! // activityIndicator for when user texts
    
    // JSON object for later - will hold detailed information about each location
    var currentJSON : JSON = []
    
    //viewDidLoad method
    override func viewDidLoad() {
        // execute the super for this function
        super.viewDidLoad()
        
        // set background color, set nav bar title
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.title = "Midloc"
        
        // set up and add the "Midloc it!" button to the view
        mainButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        mainButton.frame = CGRect(x: UIScreen.mainScreen().bounds.width/2-100, y: UIScreen.mainScreen().bounds.height-75, width: 200, height: 50)
        mainButton.addTarget(self, action: "mainButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        mainButton.setTitle("Midloc it!", forState: UIControlState.Normal)
        mainButton.titleLabel!.font = UIFont(name: "AppleSDGothicNeo-Light", size: 30)
        view.addSubview(mainButton)
        
        // set up and add the entire map to the view
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height/2))
        mapView.mapType = MKMapType.Standard
        mapView.zoomEnabled = true
        mapView.scrollEnabled = true
        mapView.delegate = self
        view.addSubview(mapView)
        
        // establiish region based on the lat an lon coordiantes, implement on mapview
        rgn = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: CLLocationDegrees(currentJSON["geometry"]["location"]["lat"].doubleValue), longitude: CLLocationDegrees(currentJSON["geometry"]["location"]["lng"].doubleValue)), span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        mapView.setRegion(rgn, animated: true)
        
        // add pin with the location name on the view
        pin = MKPointAnnotation()
        pin.coordinate.latitude = currentJSON["geometry"]["location"]["lat"].doubleValue
        pin.coordinate.longitude = currentJSON["geometry"]["location"]["lng"].doubleValue
        pin.title = currentJSON["name"].stringValue
        mapView.addAnnotation(pin)
        
        // resturant image
        // in this section, we safely check to make sure that the restaurant image is available.
        // in the event that it isn't (not in JSON or webpage broken), we add the default icon
        // to the imageView
        restaurantPic = UIImageView(frame: CGRect(x: 20, y: UIScreen.mainScreen().bounds.height/2-40, width: 80, height: 80))
        var photoRef : String = currentJSON["photos"][0]["photo_reference"].stringValue
        var rowImage : UIImage!
        
        if count(photoRef) == 0
        {
            photoRef = currentJSON["icon"].stringValue
        }
        else
        {
            photoRef = "https://maps.googleapis.com/maps/api/place/photo?key=AIzaSyCVmEeZP5v1n59FxsMr71bETu0I0FrI_W4&maxwidth=160&photoreference=\(photoRef)"
        }
        
        var url = NSURL(string: photoRef)!
        if let data = NSData(contentsOfURL: url)
        {
            rowImage = UIImage(data: data)
        }
        else
        {
            rowImage = UIImage(data: NSData(contentsOfURL: NSURL(string: currentJSON["icon"].stringValue)!)!)!
        }
        
        restaurantPic.image = rowImage
        restaurantPic.backgroundColor = UIColor.whiteColor()
        view.addSubview(restaurantPic)
        
        // establish and add reset button to bring view's region back to normal
        resetButton = UIBarButtonItem(title: "Reset", style: UIBarButtonItemStyle.Plain, target: self, action: "resetMap:")
        self.navigationItem.rightBarButtonItem = resetButton
        
        // add name
        nameLabel = UILabel(frame: CGRect(x: 120, y: UIScreen.mainScreen().bounds.height/2+10, width: UIScreen.mainScreen().bounds.width-120-20, height: 40))
        nameLabel.text = currentJSON["name"].stringValue
        nameLabel.textAlignment = NSTextAlignment.Left
        nameLabel.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 30)
        nameLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(nameLabel)
        
        // add vicinity
        vicinityLabel = UILabel(frame: CGRect(x: 120, y: UIScreen.mainScreen().bounds.height/2+10+40, width: UIScreen.mainScreen().bounds.width-120-20, height: 10))
        vicinityLabel.text = currentJSON["vicinity"].stringValue
        vicinityLabel.textAlignment = NSTextAlignment.Left
        vicinityLabel.font = UIFont(name: "AppleSDGothicNeo-Light", size: 12)
        vicinityLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(vicinityLabel)
        
        // add the price label for the word "Price"
        priceLabel = UILabel(frame: CGRect(x: 0, y: UIScreen.mainScreen().bounds.height/2+100, width: UIScreen.mainScreen().bounds.width/2-50, height: 20))
        priceLabel.text = "Price"
        priceLabel.textAlignment = NSTextAlignment.Right
        priceLabel.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 20)
        view.addSubview(priceLabel)
        
        // add the rating label for the word "Rating"
        ratingLabel = UILabel(frame: CGRect(x: 0, y: UIScreen.mainScreen().bounds.height/2+130, width: UIScreen.mainScreen().bounds.width/2-50, height: 20))
        ratingLabel.text = "Rating"
        ratingLabel.textAlignment = NSTextAlignment.Right
        ratingLabel.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 20)
        view.addSubview(ratingLabel)
        
        // add an activity indicator
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: UIScreen.mainScreen().bounds.width/2-10, y: UIScreen.mainScreen().bounds.height/2+160, width: 20, height: 20))
        activityIndicator.stopAnimating()
        activityIndicator.alpha = 0
        activityIndicator.color = UIColor.blackColor()
        view.addSubview(activityIndicator)
        
        
        // programmatically add circles to the right of the "Price" and "Rating"
        // labels based on the JSON values
        if count(currentJSON["price_level"].stringValue) == 0
        {
            for x in 1...4
            {
                var circle = CircleView(frame: CGRect(x: UIScreen.mainScreen().bounds.width/2 + CGFloat(x - 1) * 30.0, y: UIScreen.mainScreen().bounds.height/2+100, width: 20, height: 20))
                circle.backgroundColor = UIColor.clearColor()
                circle.desiredColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
                view.addSubview(circle)
            }
        }
        else
        {
            for x in 1...4
            {
                var circle = CircleView(frame: CGRect(x: UIScreen.mainScreen().bounds.width/2 + CGFloat(x - 1) * 30.0, y: UIScreen.mainScreen().bounds.height/2+100, width: 20, height: 20))
                
                if Double(x-1) < currentJSON["price_level"].doubleValue
                {
                    circle.desiredColor = UIColor.redColor()
                }
                else
                {
                    circle.desiredColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.25)
                }
                
                circle.backgroundColor = UIColor.clearColor()
                view.addSubview(circle)
            }
        }
        
        if count(currentJSON["rating"].stringValue) == 0
        {
            for x in 1...5
            {
                var circle = CircleView(frame: CGRect(x: UIScreen.mainScreen().bounds.width/2 + CGFloat(x - 1) * 22.5, y: UIScreen.mainScreen().bounds.height/2+130, width: 20, height: 20))
                circle.backgroundColor = UIColor.clearColor()
                circle.desiredColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
                view.addSubview(circle)
            }
        }
        else
        {
            for x in 1...5
            {
                var circle = CircleView(frame: CGRect(x: UIScreen.mainScreen().bounds.width/2 + CGFloat(x - 1) * 22.5, y: UIScreen.mainScreen().bounds.height/2+130, width: 20, height: 20))
                
                if Double(x) <= round(currentJSON["rating"].doubleValue)
                {
                    circle.desiredColor = UIColor.redColor()
                }
                else
                {
                    circle.desiredColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.25)
                }
                
                circle.backgroundColor = UIColor.clearColor()
                view.addSubview(circle)
            }
        }
    }
    
    
    // didReceiveMemoryWarning method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // handles creation of alertviewcontroller
    func mainButtonPressed(sender: UIButton!) {
        
        // creating an action sheet
        let actionSheetController: UIAlertController = UIAlertController(title: "Midloc", message: "Select an option below.", preferredStyle: .ActionSheet)
        
        //Create and add first option action
        let openGoogleMaps: UIAlertAction = UIAlertAction(title: "Navigate", style: .Default) { action -> Void in
            
            // create string, replace spaces with "+" symbols
            var query = self.currentJSON["name"].stringValue + ",+" + self.currentJSON["vicinity"].stringValue
            query = query.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            // create url and altUrl  - url opens up the Google Maps app, altUrl opens up the directions in a web browser
            var url = "comgooglemaps://?q=" + query
            var altUrl = "https://www.maps.google.com/?q=" + query
            
            // if the user has the app installed, it will open the address within it.
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: url)!) == true
            {
                UIApplication.sharedApplication().openURL(NSURL(string: url)!)
            }
            else
            {
                UIApplication.sharedApplication().openURL(NSURL(string: altUrl)!)
            }
            
        }
        // add Google Maps to the actionSheet
        actionSheetController.addAction(openGoogleMaps)
        
        let openTextMessage: UIAlertAction = UIAlertAction(title: "Text Address", style: .Default) { action -> Void in
            
            // start animating the activityIndicator
            self.activityIndicator.alpha = 1
            self.activityIndicator.startAnimating()
            
            if(self.message.canSendText())
            {
                let messageComposeVC = self.message.configuredMessageComposeViewController(self.currentJSON["name"].stringValue + ", " + self.currentJSON["vicinity"].stringValue)
                
                // Present the configured MFMessageComposeViewController instance
                // Note that the dismissal of the VC will be handled by the messageComposer instance,
                // since it implements the appropriate delegate call-back
                self.presentViewController(messageComposeVC, animated: true, completion: { () -> Void in
                    
                    // stop animating the activity indicator
                    self.activityIndicator.alpha = 0
                    self.activityIndicator.stopAnimating()
                })
            }
            else
            {
                println("Error")
            }
            
        }
        actionSheetController.addAction(openTextMessage)
        
        /*let tweetMessage: UIAlertAction = UIAlertAction(title: "Tweet @midloc!", style: .Default) { (action) -> Void in
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                var tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                tweetSheet.setInitialText("Visiting " + self.currentJSON["name"].stringValue + " with a friend thanks to @midlocapp!")
                self.presentViewController(tweetSheet, animated: true, completion: { () -> Void in
                    
                })
            }
            else {
                println("Error")
            }
        }
        
        actionSheetController.addAction(tweetMessage)*/
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            
        }
        actionSheetController.addAction(cancelAction)
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
    }
    
    // set map zoom back to normal
    func resetMap(sender: UIBarButtonItem!)
    {
        var rgn : MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: CLLocationDegrees(currentJSON["geometry"]["location"]["lat"].doubleValue), longitude: CLLocationDegrees(currentJSON["geometry"]["location"]["lng"].doubleValue)), span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        mapView.setRegion(rgn, animated: true)
    }
    
}

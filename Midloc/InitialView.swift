//
//  InitialView.swift
//  Midloc
//
//  Created by Jay Ravaliya on 7/31/15.
//  Copyright (c) 2015 JRav. All rights reserved.
//

import UIKit

class InitialView: UIView, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    // All UI elements.
    // labels
    var mainLabel : UILabel!
    
    // zip code input
    var yourZipCode : UITextField!
    var yourFriendZipCode: UITextField!
    var yourZipCodeSwitch: UISwitch!
    var yourTemp : String = ""
    
    // main search button
    var searchButton : UIButton!
    
    // UI
    var backgroundView : UIView!
    var toolbar : UIToolbar!
    var googleImage : UIImage!
    var googleImageView : UIImageView!
    
    // UX
    var activityIndicator : UIActivityIndicatorView!
    var pickerView : UIPickerView!
    var pickerViewButton : UIButton!
    var pickerViewIsVisible : Bool!
    
    // gesture
    var gs : UITapGestureRecognizer!
    
    // buttons
    var mainInfoButton : UIButton!
    var mainEmailButton : UIButton!
    
    // data
    var currentIndex : Int = 0
    let pickerViewData : [[String:String]] = [
        [
            "view":"Amusement Park",
            "value":"amusement_park"
        ],
        [
            "view":"Aquarium",
            "value":"aquarium"
        ],
        [
            "view":"Art Gallery",
            "value":"art_gallery"
        ],
        [
            "view":"Bars",
            "value":"bar"
        ],
        [
            "view":"Bowling Alley",
            "value":"bowling_alley"
        ],
        [
            "view":"Casino",
            "value":"casino"
        ],
        [
            "view":"Movie Theater",
            "value":"movie_theater"
        ],
        [
            "view":"Night Club",
            "value":"night_club"
        ],
        [
            "view":"Restaurants",
            "value":"restaurant"
        ],
        [
            "view":"Shopping Mall",
            "value":"shopping_mall"
        ],
        [
            "view":"Spa",
            "value":"spa"
        ],
        [
            "view":"Stadium",
            "value":"stadium"
        ],
        [
            "view":"Zoo",
            "value":"zoo"
        ]
    ]
    
    /*
     * Picker View Delegate Functions
     */
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerViewData[row]["view"]!
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentIndex = row
        self.pickerViewButton.setTitle(pickerViewData[row]["view"], forState: UIControlState.Normal)
    }
    
    /*
     * UITextFieldDelegate Method
     */
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    /*
     * UITapGestureRecognizerDelegate Method
     */
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    /*
     * Init Functions
     */
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        // backgroundView
        backgroundView = UIView(frame: CGRectMake(0, 0, screenWidth, screenHeight - (screenHeight*0.35)))
        backgroundView.backgroundColor = UIColor(red: 21.0/255.0, green: 98.0/255.0, blue: 254.0/255.0, alpha: 0.9)
        self.addSubview(backgroundView)
        
        // mainLabel
        mainLabel = UILabel(frame: CGRect(x: screenWidth/2 - screenWidth/4, y: backgroundView.bounds.height*(1/16), width: screenWidth/2, height: 100))
        mainLabel.text = "midloc"
        mainLabel.font = UIFont(name: "AppleSDGothicNeo-Light", size: 56)
        mainLabel.textColor = UIColor.whiteColor()
        mainLabel.textAlignment = NSTextAlignment.Center
        self.addSubview(mainLabel)
        
        // searchButton
        searchButton = UIButton()
        searchButton.frame = CGRect(x: screenWidth/2-screenWidth/4, y: (screenHeight - (screenHeight * 0.35) - 30), width: screenWidth/2, height: 60)
        searchButton.backgroundColor = UIColor(red: 203.0/255.0, green: 5.0/255.0, blue: 0, alpha: 1)
        searchButton.layer.cornerRadius = 5
        searchButton.setTitle("search", forState: UIControlState.Normal)
        searchButton.titleLabel!.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 36)
        self.addSubview(searchButton)
        
        // activityIndicator
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: screenWidth/2-10, y: screenHeight-(screenHeight*0.35) + searchButton.bounds.height, width: 20, height: 20))
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.stopAnimating()
        activityIndicator.alpha = 0.0
        self.addSubview(activityIndicator)
        
        // zipCodeSwitch
        yourZipCodeSwitch = UISwitch(frame: CGRectMake(screenWidth/2 + screenWidth/4 + 10, backgroundView.bounds.height*(6/16) + 5, 0, 40))
        yourZipCodeSwitch.setOn(true, animated: true)
        self.addSubview(yourZipCodeSwitch)
        
        // yourZipCode text field
        yourZipCode = UITextField(frame: CGRectMake(screenWidth/2 - screenWidth/4, backgroundView.bounds.height*(6/16), screenWidth * (1/2), 40))
        yourZipCode.textAlignment = NSTextAlignment.Center
        yourZipCode.borderStyle = UITextBorderStyle.RoundedRect
        yourZipCode.text = "Current Location"
        yourZipCode.font = UIFont(name: "Helvetica", size: 16)
        yourZipCode.enabled = false
        yourZipCode.keyboardType = UIKeyboardType.NumberPad
        self.yourZipCode.delegate = self
        self.addSubview(yourZipCode)
        
        // yourFriendZipCode text field
        yourFriendZipCode = UITextField(frame: CGRectMake(screenWidth/2 - screenWidth/4, backgroundView.bounds.height*(8/16), screenWidth * (1/2), 40))
        yourFriendZipCode.textAlignment = NSTextAlignment.Center
        yourFriendZipCode.borderStyle = UITextBorderStyle.RoundedRect
        yourFriendZipCode.font = UIFont(name: "Helvetica", size: 16)
        yourFriendZipCode.keyboardType = UIKeyboardType.NumberPad
        self.yourFriendZipCode.delegate = self
        self.addSubview(yourFriendZipCode)
        
        // bottom
        toolbar = UIToolbar(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height-50, UIScreen.mainScreen().bounds.width, 50))
        self.addSubview(toolbar)
        
        // toolbar buttons
        mainEmailButton = UIButton.buttonWithType(UIButtonType.ContactAdd) as! UIButton
        var emailBarButton = UIBarButtonItem(customView: mainEmailButton)
        
        var flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        mainInfoButton = UIButton.buttonWithType(UIButtonType.InfoLight) as! UIButton
        var infoBarButton = UIBarButtonItem(customView: mainInfoButton)
        
        var items = NSMutableArray()
        items.addObject(emailBarButton)
        items.addObject(flexSpace)
        // items.addObject(infoBarButton)
        toolbar.items = items as [AnyObject]
        
        // picker
        pickerView = UIPickerView(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: 216.0))
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.lightGrayColor()
        pickerView.alpha = 1.0
        pickerView.opaque = false
        self.addSubview(pickerView)
        
        pickerViewIsVisible = false
        
        // pickerButton
        pickerViewButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        pickerViewButton.frame = CGRectMake(screenWidth/2 - screenWidth/4, backgroundView.bounds.height*(11/16), screenWidth * (1/2), 40)
        pickerViewButton.backgroundColor = UIColor.whiteColor()
        pickerViewButton.layer.cornerRadius = 5
        pickerViewButton.titleLabel!.textAlignment = NSTextAlignment.Center
        pickerViewButton.titleLabel!.font = UIFont.boldSystemFontOfSize(16)
        pickerViewButton.setTitle(pickerViewData[0]["view"], forState: UIControlState.Normal)
        pickerViewButton.titleLabel!.textColor = UIColor.blackColor()
        self.addSubview(pickerViewButton)
        
        // tapGestureRecognizer for pickerView
        gs = UITapGestureRecognizer()
        pickerView.addGestureRecognizer(gs)
        gs.delegate = self
        
        self.userInteractionEnabled = true

        googleImage = UIImage(named: "pb_google_hs.png")
        googleImage = imageResize(googleImage, sizeChange: CGSize(width: screenWidth/2, height: ((screenWidth/2)/(googleImage.size.width))*googleImage.size.height))
        googleImageView = UIImageView()
        googleImageView.image = googleImage
        googleImageView.frame = CGRect(x: screenWidth/4, y: screenHeight - 100, width: screenWidth/2, height: googleImage.size.height)
        self.addSubview(googleImageView)
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        hidePickerView(self)
    }
    
    func showPickerView(sender: AnyObject) {
        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            
            self.googleImageView.alpha = 0.0
            self.pickerView.frame = CGRect(x: 0, y: screenHeight - 216.0, width: screenWidth, height: 216.0)
            
            }) { (myBool : Bool) -> Void in
                
                self.pickerViewIsVisible = true
                
        }
    }
    
    func hidePickerView(sender: AnyObject) {
        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            
            self.googleImageView.alpha = 1.0
            self.pickerView.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: 216.0)
            
            }) { (myBool : Bool) -> Void in
                
                self.pickerViewIsVisible = false
                
        }
    }
    
    /*
     * Resize an image - taken from http://www.jogendra.com/2014/11/image-resize-in-swift-ios8.html
     */
    func imageResize (imageObj:UIImage, sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
}
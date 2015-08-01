//
//  InitialInfoView.swift
//  Midloc
//
//  Created by Jay Ravaliya on 8/1/15.
//  Copyright (c) 2015 JRav. All rights reserved.
//

import UIKit

class InitialInfoView: UIView {

    var swipe : UISwipeGestureRecognizer!
    
    var yourZipCode : UILabel!
    var friendZipCode : UILabel!
    var locationType : UILabel!
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.blackColor()
        self.alpha = 0.5
        
        yourZipCode = UILabel(frame: CGRectMake(screenWidth/2 - screenWidth/4, screenHeight*(3/16)*0.65, screenWidth * (1/2), 25))
        yourZipCode.font = UIFont.boldSystemFontOfSize(16)
        yourZipCode.textAlignment = NSTextAlignment.Center
        yourZipCode.numberOfLines = 1
        yourZipCode.text = "Your [Current] Location"
        yourZipCode.textColor = UIColor.whiteColor()
        self.addSubview(yourZipCode)
        
        friendZipCode = UILabel(frame: CGRectMake(screenWidth/2 - screenWidth/4, screenHeight*(6/16)*0.65, screenWidth * (1/2), 25))
        friendZipCode.font = UIFont.boldSystemFontOfSize(16)
        friendZipCode.textAlignment = NSTextAlignment.Center
        friendZipCode.numberOfLines = 1
        friendZipCode.text = "Your Friend's Location"
        friendZipCode.textColor = UIColor.whiteColor()
        self.addSubview(friendZipCode)
        
        locationType = UILabel(frame: CGRectMake(screenWidth/2 - screenWidth/4, screenHeight*(9/16)*0.65, screenWidth * (1/2), 25))
        locationType.font = UIFont.boldSystemFontOfSize(16)
        locationType.textAlignment = NSTextAlignment.Center
        locationType.numberOfLines = 1
        locationType.text = "Location Type"
        locationType.textColor = UIColor.whiteColor()
        self.addSubview(locationType)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            
                self.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
            
            }) { (myBool : Bool) -> Void in
            
                self.removeFromSuperview()
                
        }
        
        
    }
    
}

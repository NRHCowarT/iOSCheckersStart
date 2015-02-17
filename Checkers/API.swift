//
//  API.swift
//  Checkers
//
//  Created by William McDuff on 2015-02-17.
//  Copyright (c) 2015 Cal. All rights reserved.
//

import Foundation

//
//  API.swift
//  RailsRequest
//
//  Created by William McDuff on 2015-02-17.
//  Copyright (c) 2015 William McDuff. All rights reserved.
//

import Foundation


// token: "zYJSzpJeu4iSze41HzkV"

// taken from the postman app, next to post
let API_URL = "https://pure-anchorage-3070.herokuapp.com/"

class APIRequest {
    
    
    // (responseInfo: [String:AnyObject]) -> ()
    
    // that class func gets called in the user class
    
    //from options, take the body string, change it in json and the nchange the json to data
    
    // USEFULNESS OF BLOCKS VS CREATING A FUNCTION AT THE END: WITH BLOCK, CAN DO SOMETHING SPECIFIC AT THEN END EVERYTIME WE CALL A FUNCTION
    class func requestWithOptions(options: [String: AnyObject], andCompletion completion: (responseInfo: [String:AnyObject]) -> ()) {
        
        
        // wrapping it in a parenthesis otherwise the + sign doesn't see the as String
        // the url + users
        var url = NSURL(string: API_URL + (options["endpoint"] as String))
        var request = NSMutableURLRequest(URL: url!)
        
        // method is post
        request.HTTPMethod = options["method"] as String
        
        
        let bodyInfo = options["body"] as [String: AnyObject]
        
        let requestData = NSJSONSerialization.dataWithJSONObject(bodyInfo, options: NSJSONWritingOptions.allZeros, error: nil)
        
        let jsonString = NSString(data: requestData!, encoding: NSUTF8StringEncoding)
        
        let postLength = "\(jsonString!.length)"
        
        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
        
        let postData = jsonString?.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
        
        
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postData
        
        // mainQueue is not the main thread (just a queue)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            
            if error == nil {
                
                // do something with data
                
                // mutable containers so we can change something with it
                let json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: nil) as [String:AnyObject]
                
                // WE CALL THE COMPLETION BLOCK
                completion(responseInfo: json)
            }
                
            else {
                
                println(error)
            }
            
        }
        
    }
    
    
    
    
}

// create a singleton of the user
// to do that we need an initializer: two ways, make user inherit from nsobject or create an init() function (NOTHING NEEDS TO BE IN IT SWIFT KNOWS IT IS FOR INITIALIZATION
private let _currentUser = User()
// properties like token, email, password. We pass the token to the request class and when api receive after completion resend to the user class
class User {
    
    var token: String? {
        
        didSet {
            
            // do that so we can get that token value when we open the app
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(token, forKey: "token")
            
            // synchronize = save
            defaults.synchronize()
        }
        
    }
    
    
    init() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        token = defaults.objectForKey("token") as? String
        
        
    }
    
    // getter: will return our singleton object
    class func currentUser() -> User {
        return _currentUser
    }
    
    func getUserToken() {
        
        
        // the key names are for us (we chose the name of the keynames, the values are going to be used for url request)
        let options: [String:AnyObject] = [
            
            "endpoint": "users",
            "method": "POST",
            "body": [
                
                "user": [ "email": "test15@jo.com", "password": "password" ]
                
                
            ]
        ]
        
        
        // responseInfo will be set at the end of the requestwithoptions function: (completion: requestWithoptions), then we will print responseInfo
        APIRequest.requestWithOptions(options, andCompletion: { (responseInfo) -> () in
            
            
            println(responseInfo)
            
            let dataInfo = responseInfo["data"] as [String:String]
            
            self.token = dataInfo["auth_token"]
            
            
            // do something here after request is done
            
        })
    }
    
}
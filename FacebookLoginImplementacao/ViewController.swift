//
//  ViewController.swift
//  FacebookLoginImplementacao
//
//  Created by richardleandro on 27/10/19.
//  Copyright © 2019 richardleandro. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

class ViewController: UIViewController {

    @IBOutlet weak var photoImgView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.textAlignment = .center
        photoImgView.layer.masksToBounds = true
        photoImgView.layer.cornerRadius = photoImgView.bounds.width / 2
        

    }

    @IBAction func login(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile], viewController: self){
            (LoginResult: LoginResult) in
            
            switch LoginResult{
            case .failed(let error):
                print(error.localizedDescription)
            case .cancelled:
                print("login cancelled")
            case .success(grantedPermissions: _, declinedPermissions: _, token: _):
                print("Login sucess")
                self.getDetails()
            }
        }
    }
    
    func getDetails(){
        guard let accessToken = AccessToken.current else {return}
        
        let parameters = ["fields":"name,picture.width(400).height(380)"]
        
        let graphRequest = GraphRequest(graphPath: "me", parameters: parameters, accessToken: accessToken)
        
        graphRequest.start{(URLResponse, requestResult) in
            switch requestResult{
            case .failed(let error):
                print(error.localizedDescription)
                
            case .success(response: let graphResponse):
                guard let responseDictionary = graphResponse.dictionaryValue else {return}
                
                let name = responseDictionary["name"] as? String
                self.nameLabel.text = name
                
                guard let picture = responseDictionary["picture"] as?
                    NSDictionary else {return}
                guard let data = picture["data"] as? NSDictionary else
                    {return}
                guard let urlstring = data["url"] as? String else {return}
                guard let url = URL(string: urlstring) else {return}
                DispatchQueue.global().async {
                    guard let data = try? Data(contentsOf: url) else
                        {return}
                    DispatchQueue.main.async {
                        let image = UIImage(data:data)
                        self.photoImgView.image = image
                    }
                }
                
            }
        }
        
    }
}


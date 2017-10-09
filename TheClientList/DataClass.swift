//
//  DataController.swift
//  TheClientList
//
//  Created by Johnatan Botero on 7/27/17.
//  Copyright © 2017 jb. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
public class DataClass: UIViewController
{
    // static var DataClient = [[String:AnyObject]]()
    static var jsonDataClient: JSON?
    
    static var userLat: Double?
    static var userLng: Double?
    
    static var DistanceClient = [Int]()
    
    static var maxDistance: Int?
    static var minDistance: Int?
    
    
    func LoadJson() {
        
        if let path = Bundle.main.path(forResource: "users", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let jsonObj = JSON(data: data)
                if jsonObj != JSON.null {
                    DataClass.jsonDataClient = jsonObj
                } else {
                    print("Could not get json from file, make sure that file contains valid json.")
                    
                    let alertController = UIAlertController(title: "Could not get json from file", message: "Make sure that file contains valid json.", preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default,
                                                 handler: nil)
                    alertController.addAction(OKAction)
                    OperationQueue.main.addOperation {
                        self.present(alertController, animated: true,
                                     completion:nil)
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
    }
}

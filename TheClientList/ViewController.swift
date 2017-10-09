//
//  ViewController.swift
//  TestBitGray
//
//  Created by Johnatan Botero on 7/27/17.
//  Copyright © 2017 jb. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    /*
     >>>
     
     Note:
     The sent JSON has points in remote places, therefore it was not possible to calculate travel time

     Note API:
     The exercise was performed with the local json. I leave a commented note at the end of this script how to load from an API
     <<<
     */
    
    // MARK: @IBOutlet
    @IBOutlet weak var mapContainer: GMSMapView!
    @IBOutlet weak var btnClosest: UIButton!
    @IBOutlet weak var btnFarthest: UIButton!
    @IBOutlet weak var btnAllClients: UIButton!
    @IBOutlet weak var btnClear: UIButton!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load data form Json
        DataClass().LoadJson()
        
        //Habilitate get location user
        mapContainer.isMyLocationEnabled = true
        mapContainer.delegate = self
        
        //Validate locationServices and switch menu
        if Reachability.isLocationServiceEnabled() == true {
            // Do what you want to do.
            btnClosest.isHidden = false
            btnFarthest.isHidden = false
        } else {
            btnClosest.isHidden = true
            btnFarthest.isHidden = true
            
            //Alert Location Services Disabled
            let alertController = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for enable all  modules of the app.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default,
                                         handler: nil)
            alertController.addAction(OKAction)
            OperationQueue.main.addOperation {
                self.present(alertController, animated: true,
                             completion:nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Func
    
    //With this function they are called all the clients in the map
    //If filtered by client location or point on map
    func loadmapContainer(isPointMap: Bool){
        
        for i in 0 ... (DataClass.jsonDataClient?.count)!-1{
            
            var lat : String!
            lat = String(describing: DataClass.jsonDataClient![i]["address"]["geo"]["lat"])
            var lng : String!
            lng = String(describing: DataClass.jsonDataClient![i]["address"]["geo"]["lng"])
            
            var companyname : String!
            companyname = String(describing: DataClass.jsonDataClient![i]["company"]["name"])
            
            let position = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lng)!)
            let marker = GMSMarker(position: position)
            
            marker.title = companyname!
            
            //If the location is on shows Snippet
            if Reachability.isLocationServiceEnabled() == true {
                let formattedInt = String(format: "%d", locale: Locale.current, DataClass.DistanceClient[i])
                marker.snippet = ("Distance: \(formattedInt) km")
            }
            
            //Colors of Marker
            if (i != DataClass.maxDistance! && i != DataClass.minDistance!){
                marker.icon = GMSMarker.markerImage(with: .black)
            }
            
            if i == DataClass.maxDistance! {
                marker.icon = GMSMarker.markerImage(with: .blue)
            }
            
            if i == DataClass.minDistance! {
                marker.icon = GMSMarker.markerImage(with: .green)
            }
            
            marker.tracksInfoWindowChanges = true
            marker.map = mapContainer
            
            mapContainer.isMyLocationEnabled = true
        }
        // Camera position on localization client or fixed point
        if Reachability.isLocationServiceEnabled() == true {
            let camera = GMSCameraPosition.camera(withLatitude: (mapContainer.myLocation?.coordinate.latitude)!,longitude: (mapContainer.myLocation?.coordinate.longitude)!,zoom: 2)
            mapContainer.camera = camera
        }else{
            let camera = GMSCameraPosition.camera(withLatitude:18.0000,longitude: -70.0000,zoom: 2)
            mapContainer.camera = camera
        }
        
        // User Location
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func GetDistanceAction(isPointMap: Bool) {
        DataClass.DistanceClient.removeAll()
        for i in 0 ... (DataClass.jsonDataClient?.count)!-1{
            var lat : String!
            lat = String(describing: DataClass.jsonDataClient![i]["address"]["geo"]["lat"])
            var lng : String!
            lng = String(describing: DataClass.jsonDataClient![i]["address"]["geo"]["lng"])
            
            //Filter by user location or point on map
            if (isPointMap==true){
                DataClass.DistanceClient.append(getDistanceFromLatLonInKm(latClient:DataClass.userLat!,lngClient:DataClass.userLng!,latPoint:Double(lat)!,lngPoint:Double(lng)!))
            }else{
                DataClass.DistanceClient.append(getDistanceFromLatLonInKm(latClient:(mapContainer.myLocation?.coordinate.latitude)!,lngClient:(mapContainer.myLocation?.coordinate.longitude)!,latPoint:Double(lat)!,lngPoint:Double(lng)!))
            }
        }
        //Get distance min and max of clients
        let maxDistance = DataClass.DistanceClient.map { $0 }.max()
        let minDistance = DataClass.DistanceClient.map { $0 }.min()
        
        DataClass.maxDistance = DataClass.DistanceClient.index(of: maxDistance!)
        DataClass.minDistance = DataClass.DistanceClient.index(of: minDistance!)
    }
    //func Get distance min and max of clients
    //Can filter if it is near or far
    func getMaxMinPosition(index: Int, isFar: Bool){
        var lat : String!
        lat = String(describing: DataClass.jsonDataClient![index]["address"]["geo"]["lat"])
        var lng : String!
        lng = String(describing: DataClass.jsonDataClient![index]["address"]["geo"]["lng"])
        
        var companyname : String!
        companyname = String(describing: DataClass.jsonDataClient![index]["company"]["name"])
        
        let position = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lng)!)
        let marker = GMSMarker(position: position)
        
        marker.title = companyname!
        
        if Reachability.isLocationServiceEnabled() == true {
            let formattedInt = String(format: "%d", locale: Locale.current, DataClass.DistanceClient[index])
            marker.snippet = ("Distance: \(formattedInt) km")
        }
        if isFar{
            marker.icon = GMSMarker.markerImage(with: .blue)
        }else {
            marker.icon = GMSMarker.markerImage(with: .green)
        }
        
        marker.map = mapContainer
        
        let camera = GMSCameraPosition.camera(withLatitude:Double(lat)!,longitude: Double(lng)!,zoom: 3)
        mapContainer.camera = camera
    }
    //Calculate distance between two Lat/Lng coordinates
    func getDistanceFromLatLonInKm(latClient:Double,lngClient:Double,latPoint:Double,lngPoint:Double) -> Int  {
        let R = 6371;
        
        let dLat = Measurement(value: (latPoint-latClient), unit: UnitAngle.degrees)
            .converted(to: .radians).value
        let dLon = Measurement(value: (lngPoint-lngClient), unit: UnitAngle.degrees)
            .converted(to: .radians).value
        
        let dlatClient = Measurement(value: latClient, unit: UnitAngle.degrees)
            .converted(to: .radians).value
        let dlatPoint = Measurement(value: latPoint, unit: UnitAngle.degrees)
            .converted(to: .radians).value
        
        let a = sin(dLat/2) * sin(dLat/2) + cos(dlatClient) * cos(dlatPoint) * sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        let d = Double(R) * c
        
        let e = Int(d)
        return e
    }
    
    // MARK: Map func
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        mapContainer.clear()
        
        let marker = GMSMarker(position: coordinate)
        marker.map = mapContainer
        
        DataClass.userLat = coordinate.latitude
        DataClass.userLng = coordinate.longitude
        
        if Reachability.isLocationServiceEnabled() == true {
            GetDistanceAction(isPointMap: true)
        }
        
        loadmapContainer(isPointMap: true)
        //Puts the camera at the selected point
        let camera = GMSCameraPosition.camera(withLatitude:coordinate.latitude,longitude: coordinate.longitude,zoom: 2)
        mapContainer.camera = camera
        
        //Update status buttons
        btnState(btn: btnClear, isMenu: false)
    }
    
    // MARK: Other Class
    open class Reachability {
        class func isLocationServiceEnabled() -> Bool {
            if CLLocationManager.locationServicesEnabled() {
                switch(CLLocationManager.authorizationStatus()) {
                case .notDetermined, .restricted, .denied:
                    print("Location services are not enabled")
                    return false
                case .authorizedAlways, .authorizedWhenInUse:
                    //print("Location services are enabled")
                    return true
                }
            } else {
                //print("Location services are not enabled")
                return false
            }
        }
    }
    
    // MARK: @IBAction
    @IBAction func btnClearAction(_ sender: Any) {
         //Update distanes
        if Reachability.isLocationServiceEnabled() == true {
            GetDistanceAction(isPointMap: false)
        }
        
        //clear map
        mapContainer.clear()
        
        //Update status buttons
        btnState(btn: btnClear, isMenu: false)
        
    }
    
    @IBAction func btnAllClientsActions(_ sender: Any) {
        //clear map
        mapContainer.clear()
        
        //Update distanes

        if Reachability.isLocationServiceEnabled() == true {
            GetDistanceAction(isPointMap: false)
        }
        //Load and show clients
        loadmapContainer(isPointMap: false)
        
        //Update status buttons
        btnState(btn: btnAllClients, isMenu: true)
        
    }
    
    @IBAction func btnFarthestAction(_ sender: Any) {
        //Update distanes
        if Reachability.isLocationServiceEnabled() == true {
            GetDistanceAction(isPointMap: false)
        }
        
        //clear map
        mapContainer.clear()
        
        getMaxMinPosition(index: DataClass.maxDistance!,isFar: true)
        
        //Update status buttons
        btnState(btn: btnFarthest, isMenu: true)
        
    }
    
    @IBAction func btnClosestAction(_ sender: Any) {
        //Update distanes
        if Reachability.isLocationServiceEnabled() == true {
            GetDistanceAction(isPointMap: false)
        }
        
        //clear map
        mapContainer.clear()
        
        //Get min value
        getMaxMinPosition(index: DataClass.minDistance!,isFar: false)
        
        //Update status buttons
        btnState(btn: btnClosest, isMenu: true)
    }
    
    //Menu states buttons
    func btnState(btn: UIButton, isMenu: Bool){
        btnClear.backgroundColor = #colorLiteral(red: 0.9967246652, green: 0.9775177836, blue: 0.5572156906, alpha: 1)
        btnClear.setTitleColor(#colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1), for: .normal)
        btnFarthest.backgroundColor = #colorLiteral(red: 0.9967246652, green: 0.9775177836, blue: 0.5572156906, alpha: 1)
        btnFarthest.setTitleColor(#colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1), for: .normal)
        btnClosest.backgroundColor = #colorLiteral(red: 0.9967246652, green: 0.9775177836, blue: 0.5572156906, alpha: 1)
        btnClosest.setTitleColor(#colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1), for: .normal)
        btnAllClients.backgroundColor = #colorLiteral(red: 0.9967246652, green: 0.9775177836, blue: 0.5572156906, alpha: 1)
        btnAllClients.setTitleColor(#colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1), for: .normal)
        
        if (isMenu == true){
            btn.backgroundColor = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1)
            btn.setTitleColor(#colorLiteral(red: 0.9967246652, green: 0.9775177836, blue: 0.5572156906, alpha: 1), for: .normal)
        }else{
            btn.backgroundColor = #colorLiteral(red: 0.9967246652, green: 0.9775177836, blue: 0.5572156906, alpha: 1)
            btn.setTitleColor(#colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1), for: .normal)
        }
    }
}

/*
 Note API:

 func loadDataFormServer(){
    let apiMethod = "\(ApiClass.ServerURL)api/EndPoint"
    let head: HTTPHeaders = ["Authorization": "Bearer TOKEN","Content-Type": "application/json"]
    
    Alamofire.request(apiMethod, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: head)
        .responseJSON { response in
            // print(response.request as Any)
            // print(response.response as Any)
            // print(response.result.value as Any!)
            // result of response serialization
            
            let swiftyJsonVar = JSON(response.result.value!)
            
            if let status = response.response?.statusCode {
                switch(status){
                case 200:
                    if let resData = swiftyJsonVar["dataAPI"].arrayObject {
                       DataClass.ClientsArray = resData as! [[String:AnyObject]]
                    }
                case 500:
                    print("500")
                    
                    let alertController = UIAlertController(title: "Error", message:
                        "Error de conexion", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Intentar de nuevo", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alertController, animated: true, completion: nil)

                default :
                    print("default")
                }
            }
    }
 }
 */


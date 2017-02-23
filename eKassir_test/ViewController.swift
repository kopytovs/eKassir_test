//
//  ViewController.swift
//  eKassir_test
//
//  Created by Sergey Kopytov on 23.02.17.
//  Copyright © 2017 Sergey Kopytov. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Kingfisher

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var swiftyJson: JSON = []
    let source: String = "http://careers.ekassir.com/test/orders.json"
    
    struct Adress{
        var city: String
        var adress: String
    }
    struct Price {
        var amount: Int
        var currency: String
    }
    struct Vehicle {
        var regNumber: String
        var modelNumber: String
        var photo: String
        var driverName: String
    }
    
    struct Order {
        
        var id: Int
        var startAdress: Adress
        var endAdress: Adress
        var price: Price
        var orderTime: Date
        var vehicle: Vehicle
        
    }
    
    var orders = [Order]()
    
    @IBOutlet weak var myTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Alamofire.request(source).responseData(completionHandler: {(responseData) -> Void in
            //if (responseData.result.value != nil){
                //self.swiftyJson = JSON(responseData.result.value!)
            //}
        //})
        
        refreshOrders()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return orders.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        // Configure the cell...
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "kk:mm:ss  dd/MM/yy"
        cell.textLabel?.text = orders[indexPath.row].endAdress.adress
        cell.detailTextLabel?.text = dateFormatter.string(from: orders[indexPath.row].orderTime)
        
        return cell
        
    }
    
    func refreshOrders(){
        
        Alamofire.request(source).responseJSON(completionHandler: {response in
            switch response.result {
            case .success(let value):
                self.swiftyJson = JSON(value)
                for index in 0...self.swiftyJson.count-1 {
                    //let newItem = self.swiftyJson[index]
                    let newID = self.swiftyJson[index]["id"].intValue
                    let newStAdr = Adress(city: (self.swiftyJson[index]["startAddress"]["city"]).stringValue, adress: (self.swiftyJson[index]["startAdress"]["address"]).stringValue)
                    let newEndAdr = Adress(city: (self.swiftyJson[index]["endAddress"]["city"]).stringValue, adress: (self.swiftyJson[index]["endAddress"]["address"]).stringValue)
                    let newPrice = Price(amount: (self.swiftyJson[index]["price"]["amount"]).intValue, currency: (self.swiftyJson[index]["price"]["currency"]).stringValue)
                    let dateString = (self.swiftyJson[index]["orderTime"]).stringValue
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'kk:mm:ssxxx"
                    let newDate = dateFormatter.date(from: dateString)
                    let newVehicle = Vehicle(regNumber: (self.swiftyJson[index]["vehicle"]["regNumber"]).stringValue, modelNumber: (self.swiftyJson[index]["vehicle"]["modelName"]).stringValue, photo: (self.swiftyJson[index]["vehicle"]["photo"]).stringValue, driverName: (self.swiftyJson[index]["vehicle"]["driverName"]).stringValue)
                    let newOrder = Order(id: newID, startAdress: newStAdr, endAdress: newEndAdr, price: newPrice, orderTime: newDate!, vehicle: newVehicle)
                    self.orders.append(newOrder)
                }
                self.orders = self.orders.sorted(by: { $0.orderTime > $1.orderTime })
                self.myTable.reloadData()
            case .failure(let error):
                print(error)
            }
        })
        
    }
    
    

}


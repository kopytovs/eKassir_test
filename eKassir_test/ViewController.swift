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

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var helperView: UIView!
    @IBOutlet weak var myBlur: UIVisualEffectView!
    @IBOutlet weak var helperWindow: UIView!
    @IBOutlet weak var closeB: UIButton!
    
    var myJson: JSON = []
    let source: String = "http://careers.ekassir.com/test/orders.json"
    let imgSource: String = "http://careers.ekassir.com/test/images/"
    
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
    
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    @IBOutlet weak var dataOrder: UILabel!
    @IBOutlet weak var fromOrder: UILabel!
    @IBOutlet weak var toOrder: UILabel!
    @IBOutlet weak var priceOrder: UILabel!
    @IBOutlet weak var driverOrder: UILabel!
    @IBOutlet weak var carOrder: UILabel!
    @IBOutlet weak var orderPhoto: UIImageView!
    @IBOutlet weak var orderInfo: UILabel!
    
    var cache = NSCache<NSString, UIImage>()
    
    var timers = Dictionary<String, Timer>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //refreshOrders()
        //self.myCollectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "myCell")
        //myBlur.isHidden = true
        myBlur.center.y += view.bounds.height
        helperView.center.y += view.bounds.height
        helperWindow.layer.cornerRadius = helperWindow.frame.size.width/36
        helperWindow.clipsToBounds = true
        tapGesture.numberOfTapsRequired = 2
        closeB.layer.cornerRadius = helperWindow.frame.size.width/36
        closeB.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshOrders()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return orders.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! CollectionViewCell
        
        //cell.backgroundColor = UIColor.blue
        
        // Configure the cell
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        let currency: String = findCurrency(cur: orders[indexPath.row].price.currency)
        
        cell.fromAddress?.text = " От: " + orders[indexPath.row].startAdress.adress
        cell.toAddress?.text = " До: " + orders[indexPath.row].endAdress.adress
        let price: Double = Double(orders[indexPath.row].price.amount)/100
        cell.priceOrder?.text = " " + ((Int(price*100)%100 == 0) ? String(Int(price)) : String(price)) + currency
        cell.dateOrder?.text = dateFormatter.string(from: orders[indexPath.row].orderTime) + " "
        
        cell.layer.cornerRadius = cell.frame.size.width/16
        cell.clipsToBounds = true
        
        cell.backgroundColor = UIColor.gray
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        orderInfo.text = "Заказ №" + String(self.orders.count-indexPath.row)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "'Дата: 'dd/MM/yy'   Время: 'kk:mm:ss"
        dataOrder.text = dateFormatter.string(from: orders[indexPath.row].orderTime)
        fromOrder.text = " От: " + orders[indexPath.row].startAdress.adress
        toOrder.text = " До: " + orders[indexPath.row].endAdress.adress
        let currency: String = findCurrency(cur: orders[indexPath.row].price.currency)
        let price: Double = Double(orders[indexPath.row].price.amount)/100
        priceOrder.text = " " + ((Int(price*100)%100 == 0) ? String(Int(price)) : String(price)) + currency
        driverOrder.text = orders[indexPath.row].vehicle.driverName
        carOrder.text = orders[indexPath.row].vehicle.modelNumber + "  ||  " + orders[indexPath.row].vehicle.regNumber
        let myPhotoSrc = imgSource + orders[indexPath.row].vehicle.photo
        
        let name: String = orders[indexPath.row].vehicle.photo
        
        if let cachedImg = cache.object(forKey: name as NSString){
            
            orderPhoto.image = cachedImg
            
        } else {
            Alamofire.request(myPhotoSrc).responseData(completionHandler: { response in
                switch response.result{
                case .success(let data):
                    let myData: UIImage = UIImage(data: data)!
                    self.orderPhoto.image = myData
                    self.cache.setObject(myData, forKey: name as NSString)
                    self.timers[name] = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.clearCache(timer:)), userInfo: name, repeats: false)
                    //let myTimer = Timer(timeInterval: 600, target: self, selector: #selector(self.clearCache(key: )), userInfo: name, repeats: true)
                    break
                case .failure(let error):
                    print(error)
                    break
                }
            })
        }
        
        //orderPhoto
        
        UIView.animate(withDuration: 0.3, animations: {
            self.myCollectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.clear
            self.myCollectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.gray
        })
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.9, options: .transitionFlipFromBottom, animations: {
            self.myBlur.center.y -= self.view.bounds.height
            self.helperView.center.y -= self.view.bounds.height
        }, completion: nil)
        
        
    }
    
    @IBAction func tapGesture(_ sender: Any) {
        hideInfo()
    }
    
    @IBAction func closeButton(_ sender: Any) {
        hideInfo()  
    }
    
    func clearCache(timer: Timer){
        let key = timer.userInfo as! String
        self.cache.removeObject(forKey: key as NSString)
    }
    
    func hideInfo(){
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.9, options: .transitionFlipFromTop, animations: {
            self.helperView.center.y += self.view.bounds.height
            self.myBlur.center.y += self.view.bounds.height
        }, completion: nil)
    }
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
    func refreshOrders(){
        
        Alamofire.request(source).responseJSON(completionHandler: {response in
            switch response.result {
            case .success(let value):
                self.myJson = JSON(value)
                for index in 0...self.myJson.count-1 {
                    //let newItem = self.myJson[index]
                    let newID = self.myJson[index]["id"].intValue
                    let newStAdr = Adress(city: (self.myJson[index]["startAddress"]["city"]).stringValue, adress: (self.myJson[index]["startAddress"]["address"]).stringValue)
                    let newEndAdr = Adress(city: (self.myJson[index]["endAddress"]["city"]).stringValue, adress: (self.myJson[index]["endAddress"]["address"]).stringValue)
                    let newPrice = Price(amount: (self.myJson[index]["price"]["amount"]).intValue, currency: (self.myJson[index]["price"]["currency"]).stringValue)
                    let dateString = (self.myJson[index]["orderTime"]).stringValue
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'kk:mm:ssxxx"
                    let newDate = dateFormatter.date(from: dateString)
                    let newVehicle = Vehicle(regNumber: (self.myJson[index]["vehicle"]["regNumber"]).stringValue, modelNumber: (self.myJson[index]["vehicle"]["modelName"]).stringValue, photo: (self.myJson[index]["vehicle"]["photo"]).stringValue, driverName: (self.myJson[index]["vehicle"]["driverName"]).stringValue)
                    let newOrder = Order(id: newID, startAdress: newStAdr, endAdress: newEndAdr, price: newPrice, orderTime: newDate!, vehicle: newVehicle)
                    self.orders.append(newOrder)
                }
                self.orders = self.orders.sorted(by: { $0.orderTime > $1.orderTime })
                self.myCollectionView?.reloadData()
                break
            case .failure(let error):
                print(error)
                break
            }
        })
        
    }
    
    func findCurrency(cur: String) -> String {
        
        var value: String
        
        switch cur {
            case "RUB", "643":
                value = "₽"
                break
            case "USD", "840":
                value = "$"
                break
            case "EUR", "978":
                value = "€"
                break
            case "GBR", "826":
                value = "£"
                break
            default:
                value = "₽"
                break
            
        }
        
        return value
        
    }

}


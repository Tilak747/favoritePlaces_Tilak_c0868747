//
//  PlaceListTVC.swift
//  favoritePlaces_Tilak_c0868747
//
//  Created by Tilak Acharya on 2023-01-24.
//

import Foundation
import UIKit
import CoreData

class PlaceListTVC:UIViewController{
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var managedContext : NSManagedObjectContext!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        initData()
        loadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(saveCoreData), name: UIApplication.willResignActiveNotification, object: nil)
        
    }
    
    func initData(){
        managedContext = appDelegate.persistentContainer.viewContext
    }
    
    
    func loadData(){
        PlaceManager.shared.loadPlacesData(managedContext: managedContext)
        tableView.reloadData()
    }
    
    @objc func saveCoreData(){
        PlaceManager.shared.saveCoreData(managedContext: managedContext)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tvc = segue.destination as? AddPlaceVC {
            tvc.delegate = self
        }
    }
    
    
}

extension PlaceListTVC : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PlaceManager.shared.places?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let place = PlaceManager.shared.places![indexPath.row]
        let cell  = tableView.dequeueReusableCell(withIdentifier: "PlaceCell")
        cell?.textLabel?.text = place.title
        cell?.detailTextLabel?.text = place.postalCode
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            PlaceManager.shared.places?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
    
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
}

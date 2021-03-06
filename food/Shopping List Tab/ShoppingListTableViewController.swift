//
//  ShoppingListTableViewController.swift
//  food
//
//  Created by J Lee on 7/18/18.
//  Copyright © 2018 J Lee. All rights reserved.
//

import UIKit
import PopupDialog
import CoreData

var SLArray = [NSManagedObject]() // Array of IngredInfo

// var shoppingListArray = [(Int, NSOrderedSet)]() // index of recipebook

func fetch_SL(){
    SLArray = []
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedObjectContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<IngredInfo>(entityName:"IngredInfo")
    let pred = NSPredicate(format: "isSL == %@", NSNumber(value: true))
    fetchRequest.predicate = pred
    do {
        SLArray = try managedObjectContext.fetch(fetchRequest) as [NSManagedObject]
    } catch let error as NSError {
        print("Could not fetch. \(error)")
    }
}

class ShoppingListTableViewController: UITableViewController {
    
    var addedIngredient: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetch_SL()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let navigationBar = navigationController!.navigationBar
        navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationBar.isHidden = false
        
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetch_SL()
        
        tableView.reloadData()
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor("8CD600")
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        
        self.navigationController?.toolbar.barTintColor = UIColor.white
        self.navigationController?.toolbar.tintColor = UIColor("#afafaf")
        
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [
                NSAttributedStringKey.font : UIFont(name: "HelveticaNeue-Medium", size: 16)!,
                NSAttributedStringKey.foregroundColor : UIColor("#565656"),
                ], for: .normal)
        if SLArray.count == 0 {
            TableViewHelper.EmptyMessage(message: "Your Shopping List! \n Add from any recipe page, \n or click 'add' above!", viewController: self)
        }
        else {
            TableViewHelper.EmptyMessage(message: "", viewController: self)
        }
        self.navigationController?.isToolbarHidden = false
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    var index: Int?
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return SLArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
        //TODO: how to make dynamic tableView
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int, indexPath: IndexPath) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30))
        view.backgroundColor = UIColor(red: 253.0/255.0, green: 240.0/255.0, blue: 196.0/255.0, alpha: 1)
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: 30))
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.black
        label.text = getFoodTypeString(rawValue_in: Int32(section))
        view.addSubview(label)
        return view
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListTableViewCell", for: indexPath) as? ShoppingListTableViewCell  else {
            fatalError("The dequeued cell is not an instance of IngredientTableViewCell.")
        }
        
        //fetches appropriate recipie for the data source layout
        //cell.recipeName.text = RecipeBook[shoppingListArray[indexPath.row].0].FoodName
        // MARK: TODO: how to get the ingredients needed for the recipe
        //cell.nameLabel.text = shoppingListArray[indexPath.row].1.object(at: indexPath.section) as (Ingrd, foodMeasureUnit).0.Name
        
        let image = UIImage(named: "shoppinglistbutton.jpg")
        cell.ring.image = image
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Configure the cell...
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListTableViewCell", for: indexPath) as? ShoppingListTableViewCell  else {
            fatalError("The dequeued cell is not an instance of IngredientTableViewCell.")
        }
        
        let image = UIImage(named: "filledIn.jpg")
        cell.filledInCircle.image = image
        
        performSegue(withIdentifier: "addToFridge", sender: addedIngredient)
        
        //MARK: TODO: add the checked item to fridge as an Ingrd(?) type (currently just passed as a String)
        addedIngredient = cell.nameLabel.text

//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            tableView.reloadData()
//        }
        
        deleteRecipes()
        //switch status
        tableView.reloadData()
        
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let context = AppDelegate.persistentContainer.viewContext
        if editingStyle == .delete {
            // Delete the row from the data source
            do {
                let ingredInfo = SLArray[indexPath.row]
                ingredInfo.setValue(false, forKey: "isSL")
                
            } catch let error as NSError {
                print("Could not fetch. \(error)")
            }
            SLArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            do{ try context.save() }
            catch { print("failed saving isSL == false @ tableview .delete in SLTableviewController") }
        }
    }
    
    func deleteRecipes() {
        //MARK: TODO: function that deletes the recipe from the ShoppingListArray
        //if all the ingredients are checked off (how to check this?)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        super.prepare(for: segue, sender: sender)
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let data = addedIngredient
        
        //        if let destinationViewController = segue.destination as? popupViewController {
        //            destinationViewController.addedIngredient = data
        //        }
        
    }
    
    //    @IBAction func editTapped(_ sender: Any) {
    //        print("Edit")
    //    }
    
    @IBAction func clearAllTapped(_ sender: Any) {
        print("clear")
        
        // Prepare the popup assets
        let title = "Clear All Items"
        let message = "Do you want to clear all items on the shopping list?"
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, image: nil)
        
        // Create buttons
        let buttonOne = DefaultButton(title: "Yes please !") {
            print("clear all")
            //MARK: TODO: clear all from shopping lsit
        }
        
        let buttonTwo = CancelButton(title: "Cancel") {
            print("You canceled the clear all.")
        }
        
        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo])
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
        
    }
    
    @IBAction func addToFridgeTapped(_ sender: Any) {
        print("add to fridge")
        
        // Prepare the popup assets
        let title = "Add all checked items to fridge?"
        let message = "This will also delete the items from the shopping list"
        let popup = PopupDialog(title: title, message: message, image: nil)
        
        // Create buttons
        let buttonOne = DefaultButton(title: "Yes please !") {
            print("Add to fridge and clear selected")
            //MARK: TODO: add all checked items to the ingredients list
        }
        
        let buttonTwo = CancelButton(title: "Cancel") {
            print("You canceled the clear all.")
        }
        
        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo])
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    
}



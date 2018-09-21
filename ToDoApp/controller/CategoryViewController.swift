//
//  CategoryViewController.swift
//  ToDoApp
//
//  Created by RastaOnAMission on 16/09/2018.
//  Copyright © 2018 ronyquail. All rights reserved.
//

import UIKit
import ChameleonFramework
import RealmSwift


class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var category: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        
        var text = UITextField()
        let alert = UIAlertController(title: "Add Category", message: "Add Categories like Shopping, Work or School to help sort out your tasks!", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = text.text!
            newCategory.colour = UIColor.randomFlat().hexValue()
            self.saveData(category: newCategory)
        }
        
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Enter New Category"
            text = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: TableView Data Source Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = UIColor(hexString: category?[indexPath.row].colour ?? "#ffffff")
        cell.textLabel?.text = category?[indexPath.row].name ?? "No Categories Created Yet!"
        cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn:cell.backgroundColor, isFlat:true)
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return category?.count ?? 1
        
    }
    
    
    //MARK: TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = category?[indexPath.row]
        }
    }
    
    
    //MARK: Data Manipulation Methods
    
    func saveData(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error Occured\(error)")
        }
        tableView.reloadData()
    }
    
    func loadData() {
        category = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        do {
            let item = self.category![indexPath.row]
            try self.realm.write {
                self.realm.delete(item)
            }
        } catch {
            print("Error Occured\(error)")
        }
        tableView.reloadData()
    }
}



//
//  ViewController.swift
//  ToDoApp
//
//  Created by RastaOnAMission on 08/09/2018.
//  Copyright © 2018 ronyquail. All rights reserved.
//

import UIKit
import ChameleonFramework
import RealmSwift

class ToDoViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var itemArray: Results<Item>?
    var selectedCategory: Category? {
        didSet {
            loadData()
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        loadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        title = selectedCategory!.name
        if let hexColour = selectedCategory?.colour {
            guard let navBar = navigationController?.navigationBar else {fatalError("Nav Controller Doesn't Exist")}
            if let navBarColour = UIColor(hexString: hexColour) {
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(contrastingBlackOrWhiteColorOn:navBarColour, isFlat:true) ]
                navBar.barTintColor = navBarColour
                searchBar.barTintColor = navBarColour
                navBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn:navBarColour, isFlat:true)
                searchBar.barTintColor = navBarColour
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        guard let originalColour = UIColor(hexString: "F4DBA7") else{fatalError()}
        navigationController?.navigationBar.barTintColor = originalColour
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.flatWhite()]
    }
    
    // MARK - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray!.count)) {
            cell.backgroundColor = colour
        }
        
        if let item = itemArray?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "Please Add Items"
        }
        if cell.accessoryType == .checkmark {
            cell.textLabel?.textColor = UIColor.flatLime()
        } else {
            cell.textLabel?.textColor = UIColor.white
        }
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemArray?.count ?? 1
        
    }
    
    // MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = itemArray?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error Loading\(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // MARK - Add Item Button
    
    @IBAction func addItemButton(_ sender: UIBarButtonItem) {
        
        var text = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = text.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }  catch {
                    print("Error\(error)")
                }
            }
            
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Enter New Item"
            text = alertTextField
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func loadData() {
        
        itemArray = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: false)

        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        do {
            let item = self.itemArray![indexPath.row]
            try self.realm.write {
                self.realm.delete(item)
            }
        } catch {
            print("Error Occured\(error)")
        }
        
        tableView.reloadData()
    }

}

extension ToDoViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadData()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {

        }
    }
}

//
//  TypeOptionsViewController.swift
//  UniversalDocs
//
//  Created by Kumar Muthaiah on 18/11/18.
//  Copyright © 2018 Kumar Muthaiah. All rights reserved.
//
//Copyright 2020 Kumar Muthaiah
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
import Foundation

import UIKit

public protocol PopoverViewControllerDelegate
{
    func popoverItemSelected(index: Int, switchOn: Bool)
}

public class PopoverViewController: UITableViewController {
    private var filteredObjects = [UVCPopoverNode]()
    let searchController = UISearchController(searchResultsController: nil)
    public var delegate: PopoverViewControllerDelegate?
    private var switchOn: Bool = false
    public var isLeftOptionEnabled: Bool = true
    public var isRightOptionEnabled: Bool = true
    
    @IBAction func SingularWordPressed(_ sender: UIBarButtonItem) {
        if sender.title == "Singular Word" {
            sender.title = "Plural Word"
            switchOn = true
            return
        }
        if sender.title == "Plural Word" {
            switchOn = false
            sender.title = "Singular Word"
        }
    }
    @IBOutlet weak var singularWordButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    
    @IBAction func cancelPressed(_ sender: Any) {
        print("cancel")
        self.dismiss(animated: true, completion: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Options"
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Setup the Scope Bar
        searchController.searchBar.delegate = self
        
        if !isLeftOptionEnabled {
            cancelButton.title = ""
            cancelButton.isEnabled = false
        } else {
            cancelButton.title = "Cancel"
            cancelButton.isEnabled = true
        }
        if !isRightOptionEnabled {
            singularWordButton.title = ""
            singularWordButton.isEnabled = false
        } else {
            singularWordButton.title = "Singular Word"
            singularWordButton.isEnabled = true
        }
    }
    
    var model: UVCPopoverView? {
        didSet {
            
            let screenRect: CGRect = UIScreen.main.bounds
            var width = model!.width
            var height = model!.height
            if model!.width == 0 {
                width = Int(screenRect.width)
            }
            if model!.height == 0 {
                height = Int(screenRect.height)
            }
            self.preferredContentSize = CGSize(width: width, height: height)
            tableView.reloadData()
        }
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var index = 0
        if isFiltering() {
            
            let filteredObject = filteredObjects[indexPath.item]
            for (indexn, n) in model!.uvcPopoverNode.enumerated() {
                if n.name == filteredObject.name {
                    index = indexn
                    break
                }
            }
        } else {
            index = indexPath.item
        }
        
        self.delegate?.popoverItemSelected(index: index, switchOn: switchOn)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredObjects.count
        } else {
            return model!.uvcPopoverNode.count
        }
    }
    
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let object: UVCPopoverNode?
        if isFiltering() {
            object = filteredObjects[indexPath.row]
        } else {
            object = model!.uvcPopoverNode[indexPath.row]
        }
        cell.textLabel!.text = object!.name
        cell.textLabel?.numberOfLines = 100
        cell.textLabel?.lineBreakMode = .byWordWrapping
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    public override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            model!.uvcPopoverNode.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && (!searchBarIsEmpty())
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredObjects = model!.uvcPopoverNode.filter({( node : UVCPopoverNode) -> Bool in return node.name.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
}



extension PopoverViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!)
    }
}

extension PopoverViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate {
    
    var businesses: [Business]!
    var filteredBusinesses: [Business]!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate=self
        tableView.dataSource=self
        tableView.rowHeight=UITableViewAutomaticDimension
        tableView.estimatedRowHeight=120 //scroll height
        tableView.keyboardDismissMode=UIScrollViewKeyboardDismissMode.onDrag
        
        navigationController?.navigationBar.barTintColor = UIColor(red:0.12, green:0.12, blue:0.12, alpha:0.5)
        
        Business.searchWithTerm(term: "Thai", completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            
            //search function prepare
            self.filteredBusinesses = businesses
            self.tableView.reloadData()
            }
        )
        
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.placeholder="Restaurants"
        navigationItem.titleView=searchBar
        searchBar.delegate = self
        searchBar.keyboardAppearance = .dark
        
        /* Example of Yelp search with more search options specified
         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
         self.businesses = businesses
         
         for business in businesses {
         print(business.name!)
         print(business.address!)
         }
         }
         */
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredBusinesses != nil {
            return filteredBusinesses.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        cell.business=filteredBusinesses[indexPath.row]
        
        return cell
    }
    
    /******* search bar ********/
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredBusinesses = searchText.isEmpty ? businesses : businesses.filter({ (dataBusiness: Business) -> Bool in
            let businessName = dataBusiness.name! as String
            return businessName.range(of: searchText, options: .caseInsensitive) != nil
        })
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    /******* search bar ********/
    
    /****** infinite scroll ********/
    var alreadyMadeRequestToAPI = false
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(!alreadyMadeRequestToAPI) {
            let screenHeight = tableView.contentSize.height
            let scrollLimit = screenHeight - tableView.bounds.size.height
            
            if(scrollView.contentOffset.y > scrollLimit && tableView.isDragging) {
                alreadyMadeRequestToAPI = true
                loadMoreData()
            }
        }
    }
    
    func loadMoreData() {
        
    }
    /****** infinite scroll ********/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

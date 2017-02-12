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
    var limitToLoad = 15
    var loadingMoreView:InfiniteScrollActivityView?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        tableView.delegate=self
        tableView.dataSource=self
        tableView.rowHeight=UITableViewAutomaticDimension
        tableView.estimatedRowHeight=120 //scroll height
        tableView.keyboardDismissMode=UIScrollViewKeyboardDismissMode.onDrag
        
        navigationController?.navigationBar.barTintColor = UIColor(red:0.12, green:0.12, blue:0.12, alpha:0.5)
        
        Business.searchWithTerm(term: "Asian", offset: 0, limit: limitToLoad, completion: { (businesses: [Business]?, error: Error?) -> Void in
            //search function prepare
            self.businesses = businesses
            self.filteredBusinesses = self.businesses
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
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor(red:0.12, green:0.12, blue:0.12, alpha:0.5)
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
                
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                loadMoreData()
            }
        }
    }
    
    func loadMoreData() {
        Business.searchWithTerm(term: "Asian", offset: self.businesses.count, limit: limitToLoad, completion: { (businesses: [Business]?, error: Error?) -> Void in
            if let newData = businesses {
                self.businesses.append(contentsOf: newData)
            }
            //search function prepare
            self.filteredBusinesses = self.businesses
            self.alreadyMadeRequestToAPI = false
            
            self.loadingMoreView!.stopAnimating()
            
            self.tableView.reloadData()
        }
        )
    }
    /****** infinite scroll ********/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            print("tableviewcell")
            let indexPath = tableView.indexPath(for: cell)
            let business = self.filteredBusinesses![indexPath!.row]
            
            let detailedBusinessViewController = segue.destination as! DetailedBusinessViewController
            detailedBusinessViewController.business = business
        } else {
            print("mapview")
            let mapViewController = segue.destination as! MapViewController
            mapViewController.businesses = self.filteredBusinesses
        }
    }
}

class InfiniteScrollActivityView: UIView {
    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    static let defaultHeight:CGFloat = 60.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupActivityIndicator()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupActivityIndicator()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
    }
    
    func setupActivityIndicator() {
        activityIndicatorView.activityIndicatorViewStyle = .gray
        activityIndicatorView.hidesWhenStopped = true
        self.addSubview(activityIndicatorView)
    }
    
    func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
        self.isHidden = true
    }
    
    func startAnimating() {
        self.isHidden = false
        self.activityIndicatorView.startAnimating()
    }
}

//
//  DetailViewController.swift
//  NYT Book Search v0
//
//  Created by Francisco de la Pena on 2/27/15.
//  Copyright (c) 2015 ___QuixoteLabs___. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var webView: UIWebView!
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!


    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = self.detailItem {
           
            if let urlString = detail.valueForKey("amazon_url")! as? String {
                
                if let url = NSURL(string: urlString) {
                
                    var request = NSURLRequest(URL: url)
                        
                    println(request)
                    
                    webView?.loadRequest(request)
                    
                }
                
            }
            
           
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


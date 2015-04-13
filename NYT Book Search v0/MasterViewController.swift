//
//  MasterViewController.swift
//  NYT Book Search v0
//
//  Created by Francisco de la Pena on 2/27/15.
//  Copyright (c) 2015 ___QuixoteLabs___. All rights reserved.
//

import UIKit
import CoreData

var amazonUrl: String = ""

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil


    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var context: NSManagedObjectContext = appDel.managedObjectContext!
        
        var title: String? = nil
        var author: String? = nil
        var description: String? = nil
        var coverImageURL: String? = nil
        var amazon_url: String? = nil
        var imageData: NSData? = nil
        
        var books = [[String:AnyObject]()]
        
        let listNameEncoded: String = "hardcover-fiction"
        
        let getBooksMethod: String = "http://api.nytimes.com/svc/books/v3/lists/\(listNameEncoded).json?sort-by=title&api-key=18514071cc7e91e3a9bedea6fde21184:13:71482443"
        
        var sessionURL: NSURL = NSURL(string: getBooksMethod)!
        
        let session: NSURLSession = NSURLSession.sharedSession()
        
        var task: NSURLSessionDataTask = session.dataTaskWithURL(sessionURL, completionHandler: { (data, response, error) -> Void in
            
            var deleteReq = NSFetchRequest(entityName: "Books")
            
            deleteReq.returnsObjectsAsFaults = false
            
            if let dataFetched = context.executeFetchRequest(deleteReq, error: nil) {
            
                for item in dataFetched {
                    
                    context.deleteObject(item as! NSManagedObject)
                    
                    context.save(nil)

                }
                
            } else {
                
                println("No Object Fetched to Delete")
                
            }
            
            
            if let jsonData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
            
                var results: [NSDictionary] = jsonData["results"]!["books"]! as! [NSDictionary]
        
            
                var book: NSManagedObject
            
                for var i = 0; i < results.count; i++ {
                    
///// Option A
                    books[i]["title"] = results[i]["title"]! as! String
                    
                    books[i]["author"] = results[i]["author"] as? String
                    
                    books[i]["brief"] = results[i]["description"] as? String
                    
                    books[i]["image_url"] = results[i]["book_image"] as? String

                    println(results[i]["amazon_product_url"]! as? String)
                    
                    if results[i]["amazon_product_url"]! as? String != nil {
                        
                        books[i]["amazon_url"] = results[i]["amazon_product_url"] as? String

                    } else {
                     
                        books[i]["amazon_url"] = "http://nyt.com"
                    }
                    
                    if books[i]["image_url"] != nil {
                        
                        var temURLString: String = books[i]["image_url"] as! String
                        
                        var tempURL: NSURL = NSURL(string: temURLString)!
                    
                        books[i]["image"] = NSData(contentsOfURL: tempURL)
                        
                    } else {
                        
                        books[i]["image"] = nil
                    }
                    
                    book = NSEntityDescription.insertNewObjectForEntityForName("Books", inManagedObjectContext: context) as! NSManagedObject
                    
                    
                    book.setValue(books[i]["title"]!, forKey: "title")
                    book.setValue(books[i]["author"]!, forKey: "author")
                    book.setValue(books[i]["brief"]!, forKey: "brief")
                    book.setValue(books[i]["image_url"]!, forKey: "image_url")
                    book.setValue(books[i]["amazon_url"]!, forKey: "amazon_url")
                    book.setValue(books[i]["image"]!, forKey: "image")
                        
                    if i < results.count-1 {
                        
                        books.append([String:AnyObject]())
                        
                    }
                    
                }

/*
///// Optin B
                title = results[i]["title"] as? NSString

                author = results[i]["author"] as? NSString
                
                description = results[i]["description"] as? NSString
                
                coverImageURL = results[i]["book_image"] as? NSString
                
                amazon_url = results[i]["amazon_product_url"] as? NSString
                
                book = NSEntityDescription.insertNewObjectForEntityForName("Books", inManagedObjectContext: context) as NSManagedObject
                
                
                book.setValue(title, forKey: "title")
                book.setValue(author, forKey: "author")
                book.setValue(description, forKey: "brief")
                book.setValue(coverImageURL, forKey: "image_url")
                book.setValue(amazon_url, forKey: "amazon_url")
                book.setValue(nil, forKey: "image")
                
                context.save(nil)
                println("Salvo Contexto Task 1")
*/
            }
            
            var fetchReq: NSFetchRequest = NSFetchRequest(entityName: "Books")
            
            fetchReq.returnsObjectsAsFaults = false
            
            var dataFetched2 = context.executeFetchRequest(fetchReq, error: nil)
            
            println(dataFetched2)
/*
            for book in dataFetched2! {
                
                var imageURLString = book.valueForKey("image_url") as NSString
                
                var imageURL = NSURL(string: imageURLString)!
                
                imageData = NSData(contentsOfURL: imageURL)!
                
                //println(imageData)
                
                book.setValue(imageData, forKey: "image")
                
                context.save(nil)
                
                var img: UIImage = UIImage(data: imageData!)!
                
                cellImages.append(img)
                
                println("Image Saved")
                
            }
*/
        })
        
        task.resume()
     
/*
        var fetchReq: NSFetchRequest = NSFetchRequest(entityName: "Books")

        fetchReq.returnsObjectsAsFaults = true

        var dataFetched = context.executeFetchRequest(fetchReq, error: nil)
        
        println(dataFetched!)
        
        for book in dataFetched! {
            
            var imageURLString = book.valueForKey("image_url") as NSString
            
            var imageURL = NSURL(string: imageURLString)!
            
            imageData = NSData(contentsOfURL: imageURL)
            
            book.setValue(imageData, forKey: "image")
            
            context.save(nil)
            
            println("Image Saved")
            
        }
*/
        
        //self.navigationItem.leftBarButtonItem = self.editButtonItem()
        //let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        //self.navigationItem.rightBarButtonItem = addButton
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
/*
    func insertNewObject(sender: AnyObject) {
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context) as NSManagedObject
             
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        newManagedObject.setValue(NSDate(), forKey: "timeStamp")
             
        // Save the context.
        var error: NSError? = nil
        if !context.save(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
    }
*/
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            
            println("prepareForSegue")
            
            if let indexPath = self.tableView.indexPathForSelectedRow() {
            
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
                amazonUrl = object.valueForKey("amazon_url") as! String
                println("\(amazonUrl)")
                
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //return self.fetchedResultsController.sections?.count ?? 0
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
        //return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
                
            var error: NSError? = nil
            if !context.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //println("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        //cell.textLabel!.text = object.valueForKey("title")!.description
        cell.textLabel!.text = object.valueForKey("title") as? String
        cell.detailTextLabel!.text = object.valueForKey("author") as? String

        var dataImage: NSData = object.valueForKey("image") as! NSData
        
        var miniImage: UIImage = UIImage(data: dataImage)!
        
        cell.imageView?.image = miniImage
        
        
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Books", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
    	var error: NSError? = nil
    	if !_fetchedResultsController!.performFetch(&error) {
    	     // Replace this implementation with code to handle the error appropriately.
    	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             //println("Unresolved error \(error), \(error.userInfo)")
    	     abort()
    	}
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController? = nil

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */

}


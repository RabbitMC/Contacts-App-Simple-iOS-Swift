//
//  ContactsTableViewController.swift
//  contactlist
//
//  Created by Miralem Cebic on 05/03/16.
//  Copyright © 2016 Miralem Cebic. All rights reserved.
//

import UIKit
import Alamofire

class Contact {
    var _name: String?
    var _email: String?
    var _number: String?

    init(name: String, email: String, number: String) {
        _name = name
        _email = email
        _number = number
    }

    func name() -> String {
        return _name!
    }
}

class ContactsTableViewController: UITableViewController {

    var myContacts: [Contact]?

    override func viewDidLoad() {
        super.viewDidLoad()


        // Initialize the refresh control.
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.backgroundColor = UIColor.purpleColor()
        self.refreshControl!.tintColor = UIColor.whiteColor()
        self.refreshControl!.addTarget(self, action: #selector(ContactsTableViewController.getLatestContacts), forControlEvents: .ValueChanged)
//        [self.refreshControl addTarget:self
//        action:@selector(getLatestLoans)
//        forControlEvents:UIControlEventValueChanged];


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillAppear(animated: Bool) {
        getLatestContacts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getLatestContacts() {
        fetchAllContacts { (contacts: [Contact]?) in

            if let c = contacts {
                self.myContacts = c
                self.tableView.reloadData()
                self.refreshControl!.endRefreshing()
            }
        }
    }

    func contactsBaseURL(resource: String) -> NSURL {
        return NSURL(string: "http:192.168.0.10:3000/\(resource)")!
    }

    func fetchAllContacts(contacts completion: ([Contact]?) -> Void) {
        let baseURL = contactsBaseURL("contactlist")

        // generate the request manager
        Alamofire.request(.GET, baseURL.absoluteString, parameters: nil, encoding: .JSON, headers: nil)
            .validate()
            .responseJSON { response in
                // debugPrint(response)

                // check if something comes back from server
                guard response.result.isSuccess else {
                    // print("Error while converting api token to session token: \(response.result.error).")
                    completion(nil)
                    return
                }

                // check if reposonse is not malformed
                guard let value = response.result.value as? [[String: AnyObject]] else {
                    // debugPrint(response.result.value)
                    // print("Malformed data while converting api token to session token.")
                    completion(nil)
                    return
                }

                var contacts = [Contact]()
                for contact in value {
                    let con = Contact(name: contact["name"] as! String,
                        email: contact["email"] as! String,
                        number: contact["number"] as! String)
                    contacts.append(con)
                }

                completion(contacts)
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let contacts = self.myContacts?.count {
            return (contacts*0)+1;
        } else {
            // Display a message when the table is empty
            let messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))

            messageLabel.text = "No data is currently available. Please pull down to refresh."
            messageLabel.textColor = UIColor.blackColor()
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .Center
            messageLabel.font = UIFont(name: "Palatino-Italic", size: 20)
            messageLabel.sizeToFit()

            self.tableView.backgroundView = messageLabel
            self.tableView.separatorStyle = .None
            
            return 0;
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let contacts = self.myContacts?.count else {
            return 0;
        }
        return contacts
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        if let contact = self.myContacts?[indexPath.row] {
            cell.textLabel?.text = contact.name()
        }


        // Configure the cell...

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  ViewController.swift
//  Github Users
//
//  Created by jeremie bitancor on 7/14/21.
//

import UIKit

class ViewController: UIViewController, NetworkManagerDelegate {
 
    @IBOutlet weak var usersTableView: UITableView!
    
    private let networkManager = NetworkManager()
    private var newUsers =  [User]()
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchUsers()
        networkManager.delegate = self
        usersTableView.dataSource = self
        usersTableView.refreshControl = refreshControl
        usersTableView.rowHeight = 80
        usersTableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserTableViewCell")
        refreshControl.addTarget(self, action: #selector(fetchUsers), for: .valueChanged)
    }
    
    @objc func fetchUsers(){
        networkManager.fetchUsers()
    }

    func setUsers(_ users: [User]) {
        newUsers = users
        refreshControl.endRefreshing()
        usersTableView.reloadData()
    }
    
    func limitReached() {
        let alert = UIAlertController(title: "Warning", message: "API limit exceed", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

//MARK: - User table view datasource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
       return newUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as! UserTableViewCell
        cell.userLogin.text = "@\(newUsers[indexPath.row].login)"
        cell.userAvatar.loadImage(withUrl: URL(string: newUsers[indexPath.row].avatar_url)!)
        return cell
    }
    
    
}

//MARK: - User table view delegate
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

//MARK: - UIImageView Function
/// A custom function for fetching the and setting the image to UIImageView
/// Declare cache variable
var imageCache = NSCache<NSString, NSData>()

extension UIImageView {
    func loadImage(withUrl url: URL) {
        /// Check image if already in cache
        if let img = imageCache.object(forKey: url.absoluteString as NSString) {
            self.image = UIImage(data: img as Data)
        } else {
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        imageCache.setObject(data as NSData, forKey: url.absoluteString as NSString)
                        DispatchQueue.main.async {
                            self?.image = image
                            
                        }
                    }
                }
            }
        }
    }
}

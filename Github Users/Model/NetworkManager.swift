//
//  NetworkManager.swift
//  Github Users
//
//  Created by jeremie bitancor on 7/14/21.
//

import Foundation

protocol NetworkManagerDelegate {
    func setUsers(_ users: [User])
    func limitReached()
}

class NetworkManager {
    
    var delegate: NetworkManagerDelegate?
    var users = [User]()
    
    func fetchUsers() {
        
        /// Fetch data using URLSessions
        if let url = URL(string: "https://api.github.com/users") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if error == nil {
                    let decoder = JSONDecoder()
                    if let safeData = data {
                        do {
                            let results = try decoder.decode([User].self, from: safeData)
//                            print(results)
                            if let res = response as? HTTPURLResponse {
                                let limit = res.allHeaderFields["x-ratelimit-remaining"] as? Int
                                if limit == 0 {
                                    DispatchQueue.main.async {
                                        self.delegate?.limitReached()
                                    }
                                }
                            }
                            
                            results.forEach { user in
                                self.users.append(user)
                            }
                            
                            DispatchQueue.main.async {
                                self.delegate?.setUsers(self.users)
                               
                            }
                        } catch  {
                            print("Error fetching data:\(error)")
                        }
                    }
                }
            }.resume()
        }
    }
}

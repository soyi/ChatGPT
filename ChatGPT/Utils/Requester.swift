//
//  Requester.swift
//  CodeGen
//
//  Created by Matt Thomas on 18/12/2022.
//

import Foundation
import OpenAISwift
import Alamofire
import SwiftyJSON
import Foundation


enum APIResult {
   case success(String)
   case failure(Error)
}

final class Requester {
    //api-key
//    private static let authToken = "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"
    
    private static let authToken: String = {
        var key = "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"
        let apikeys = UserDefaults.standard.object(forKey: "apikeys") as! Array<Any>
        if apikeys.count != 0 {
            let item = apikeys.first as! Dictionary<String, Any>
            let serverKey = item["key"] as! String
            return serverKey
        }
        return key
    }()
    

    private let openAPI = OpenAISwift(authToken: authToken)
    
    func sendRequest(query: String, completion: @escaping (APIResult) -> ()) {
        
        
        
        openAPI.sendCompletion(with: query, maxTokens: 512) { result in
            
            switch result {
            case .success(let openApi):

                let response = openApi.choices
                var returnString: String = ""

                DispatchQueue.main.async {
                    for choice in response {
                        returnString.append(choice.text)
                    }
                    completion(.success(returnString))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    var backgroundTaskID = UIBackgroundTaskIdentifier.invalid
    

//    let urlString = "http://rqw1qbvd3.hd-bkt.clouddn.com/authToken/keys.json?e=1677752064&token=IlnK7sx5b1XmZuHUPiHrdnpYm7tQrcMZl4evivFh:1LC80yB9hhRvmTPQFnF0ZdlhVTo="

    // 下载 JSON 并将其转换为字典
    func downloadJSON(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: "http://rqw1qbvd3.hd-bkt.clouddn.com/authToken/keys.json?e=1677752064&token=IlnK7sx5b1XmZuHUPiHrdnpYm7tQrcMZl4evivFh:1LC80yB9hhRvmTPQFnF0ZdlhVTo=") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                      completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                      return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(.success(json))
                } else {
                    completion(.failure(NSError(domain: "Invalid JSON", code: 0, userInfo: nil)))
                }
            } catch let error {
                completion(.failure(error))
            }
        }.resume()
    }
        
    
    
    func endBGTask(){
        // End the task assertion.
        UIApplication.shared.endBackgroundTask(self.backgroundTaskID)
        self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
    }
}



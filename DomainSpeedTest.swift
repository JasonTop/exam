//
//  DomainSpeedTest.swift
//  SpeedTest
//
//  Created by Jason on 2024/12/19.
//

import Foundation
import Alamofire

/**
 三方套件：Alamofire (https://github.com/Alamofire/Alamofire)
 為何使用 - 提供直覺的API來處理HTTP的request和response
 解決問題 - 降低URLSession的使用難度
 */

private let storeKey = "DomainSpeedTestResults"

// MARK: - 測速結果

struct DomainSpeedResult: Codable {
    let domain: String
    let time: Double
}

// MARK: - 測速Manager

struct DomainSpeedTestManager {
    
    let session: URLSession
    
    func get() -> [DomainSpeedResult] {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: storeKey),
              let results = try? JSONDecoder().decode([DomainSpeedResult].self, from: data) else {
            return []
        }
        return results
    }
    
    func set(results: [DomainSpeedResult]) {
        let sortedResults = results.sorted { $0.time < $1.time }
        let defaults = UserDefaults.standard
        if let encoded = try? JSONEncoder().encode(sortedResults) {
            defaults.set(encoded, forKey: storeKey)
        }
    }
    
    func downloadImg(domain: String, completion: @escaping (Double) -> Void) {
        if let url = URL(string: "https://\(domain)/test-img") {
            DispatchQueue.global(qos: .background).async {
                let startTime = Date()
                
                AF.request(url, method: .get).responseData { response in
                    let endTime = Date()
                    let elapsedTime = endTime.timeIntervalSince(startTime) * 1000.0
                    
                    if let error = response.error {
                        print("下載失敗:", error)
                        completion(-999)
                        return
                    }
                    completion(elapsedTime)
                }
            }
        } else {
            //若URL為nil用-999表示
            completion(-999)
        }
    }
    
}

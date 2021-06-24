//
//  KitcastBuild.swift
//  Kitcast Builder
//
//  Created by Alex Pawlowski on 11/24/17.
//  Copyright © 2017 Kitcast. All rights reserved.
//

import Foundation

struct KitcastBuild: Decodable {
    let latestVersion: String
    let ipa: URL
}

class KitcastBuildEndpoint {
    private let versionURL =
        URL(string: "https://kitcast.s3.us-west-1.amazonaws.com/builds/player/tvos/version.json")!
    
//    private let buildSubject = BehaviorSubject<KitcastBuild?>(value: nil)
    private let session: URLSession
    private let queue = DispatchQueue(label: "tv.kitcast.builder.endpoint.queue")
    
//    lazy var build: Observable<KitcastBuild?> = self.buildSubject
//        .asObservable()
//        .observeOn(MainScheduler.asyncInstance)
    
    init() {
        let config = URLSessionConfiguration.default
        
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        
        session = URLSession(configuration: config)
    }
    
    func fetch(completionHandler: @escaping (KitcastBuild) -> Void) {
        let task = session.dataTask(with: versionURL) { [weak self] (data, _, _) in
            guard let strongSelf = self
                else { return }
            
            guard
                let data = data,
                let build = try? JSONDecoder().decode(KitcastBuild.self, from: data)
            else { return strongSelf.retry(completionHandler: completionHandler) }
            
            let cdnedBuild = KitcastBuild(latestVersion: build.latestVersion,
                                          ipa: build.ipa.cdn)
            
            completionHandler(cdnedBuild)
        }
        
        task.resume()
    }
    
    private func retry(completionHandler: @escaping (KitcastBuild) -> Void) {
        queue.asyncAfter(deadline: .now() + 2.0) { [weak self] in self?.fetch(completionHandler: completionHandler) }
    }
}

extension URL {
    var cdn: URL {
        guard
            let host = host,
            let cdned = URL(string: absoluteString.replacingOccurrences(of: host,
                                                                        with: "d3sh2zxkpmkwjf.cloudfront.net"))
            else { return self }
        
        return cdned
    }
}

//
//  Plaid.swift
//  Spearmint
//
//  Created by Sebastian Shanus on 12/12/17.
//  Copyright © 2017 Sebastian Shanus. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift

enum Environment : String {
    case sandbox = "sandbox"
    case development = "development"
    case production = "production"
}

struct Plaid {
    private static var urlEndpoint: String {
        return "https://\(environment.rawValue).plaid.com"
    }
    private static var environment: Environment {
        guard let env = plaidConfigs["env"]?.lowercased() else {
            fatalError("Couldn't find env in plist")
        }
        guard let environment = Environment(rawValue: env) else {
            fatalError("Unknown environment provided in plist")
        }
        return environment
    }
    private static var plaidConfigs: Dictionary<String, String> {
        guard let configs = Bundle.main.infoDictionary?["PLKPlaidLinkConfiguration"] as? Dictionary<String, String> else {
            fatalError("Couldn't load PLKPlaidLinkConfiguration from plist.")
        }
        return configs
    }
    private static var secretKey: String {
        guard let secret = plaidConfigs["key"] else {
            fatalError("Couldn't find secret key in plist")
        }
        return secret
    }
    private static var clientId: String {
        guard let clientId = plaidConfigs["clientId"] else {
            fatalError("Couldn't find clientId key in p list")
        }
        return clientId
    }
    
    static func exchangeToAccessToken(with publicToken: String) -> Observable<String?> {
        let parameters : Parameters = ["client_id" : clientId,
                                       "secret" : secretKey,
                                       "public_token" : publicToken]
        let responseSubject = PublishSubject<String?>()
        Alamofire
            .request(urlEndpoint, method: .post, parameters: parameters)
            .responseJSON { response in
                let data = response.result.value as? String
                responseSubject.onNext(data)
        }
        return responseSubject.asObservable()
    }
    
    static func transactions(for accessToken: String, start_date: PlaidDate, end_date: PlaidDate) -> Observable<
}

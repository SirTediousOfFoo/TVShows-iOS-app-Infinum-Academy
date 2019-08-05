//
//  APIManagerRequest.swift
//  TVShows
//
//  Created by Infinum on 18/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import CodableAlamofire
import RxSwift

class APIManager {
    
    static func request<T: Decodable>(_ type: T.Type, path: String, method: HTTPMethod, parameters: Parameters? = nil, keyPath: String = "", encoding: ParameterEncoding = JSONEncoding.default, decoder: JSONDecoder = JSONDecoder(), headers: HTTPHeaders? = nil) -> Promise<T> {
        return Promise { promise in
            Alamofire
                .request(
                    path,
                    method: method,
                    parameters: parameters,
                    encoding: encoding,
                    headers: headers)
                .validate()
                .responseDecodableObject(
                    keyPath: keyPath,
                    decoder: decoder) { (response: DataResponse<T>) in
                        switch response.result {
                        case .success(let model):
                            promise.fulfill(model)
                        case .failure(let error):
                            promise.reject(error)
                        }
            }
        }
    }
    
    static func requestObservable<T: Decodable>(_ type: T.Type, path: String, method: HTTPMethod, parameters: Parameters? = nil, keyPath: String = "", headers: HTTPHeaders? = nil) -> Observable<T> {
        return Observable.create { observer -> Disposable in
            Alamofire.request(
                    path,
                    method: method,
                    parameters: parameters,
                    encoding: JSONEncoding.default,
                    headers: headers)
                .validate()
                .responseDecodableObject(
                    keyPath: keyPath,
                    decoder: JSONDecoder()) { (response: DataResponse<T>) in
                        switch response.result {
                        case .success(let model):
                            observer.onNext(model)
                            observer.onCompleted()
                        case .failure(let error):
                            observer.onError(error)
                        }
            }
            return Disposables.create()
        }
    }
    
}

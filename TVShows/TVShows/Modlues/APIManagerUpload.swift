//
//  APIManagerUpload.swift
//  TVShows
//
//  Created by Infinum on 29/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import Foundation
import Alamofire
import CodableAlamofire
import PromiseKit

extension APIManager {
    
    
    static func uploadImageOnAPI(fileName: String, imageByteData: Data, headers: HTTPHeaders? = nil) -> Promise<Media> {
        return Promise { promise in
        Alamofire
            .upload(multipartFormData: { multipartFormData in
                multipartFormData.append(imageByteData,
                                         withName: "file",
                                         fileName: fileName,
                                         mimeType: "image/png")
            }, to: "https://api.infinum.academy/api/media",
               method: .post,
               headers: headers)
            { result in
                switch result {
                    case .success(let uploadRequest, _, _):
                        uploadRequest
                            .responseDecodableObject(keyPath: "data") { (response: DataResponse<Media>) in
                                switch response.result {
                                case .success(let media):
                                    promise.fulfill(media)
                                case .failure(let error):
                                    promise.reject(error)
                                }
                    }
                    case .failure(let encodingError):
                        promise.reject(encodingError)
                }

            }
        }
    }
    
    static func processUploadRequest(_ uploadRequest: UploadRequest) {
        uploadRequest
            .responseDecodableObject(keyPath: "data") { (response: DataResponse<Media>) in
                switch response.result {
                case .success(let media):
                    print("DECODED: \(media)")
                    print("Proceed to add episode call...")
                case .failure(let error):
                    print("FAILURE: \(error)")

                }
            }
        }
}

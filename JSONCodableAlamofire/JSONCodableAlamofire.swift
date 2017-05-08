//
//  JSONCodable+Alamofire.swift
//  JSONCodable+Alamofire
//
//  Created by sweetman on 5/8/17.
//  Copyright © 2017 smashing boxes. All rights reserved.
//

import Foundation
import Alamofire
import JSONCodable

public enum NetworkError: Error {
    case UnexpectedResponse(message: String)
    case StatusCodeValidationFailed
    case MissingHeaderAuthData
}

extension DataRequest {
    
    /**
     * Base JSON result serialization. This result value is JSONDecodable-ified by the extensions below.
     */
    fileprivate static func makeResult(_ request: URLRequest?, _ response: HTTPURLResponse?, _ data: Data?, _ error: Error?) -> Result<Any> {
        if let error = error {
            return .failure(error)
        }
        return DataRequest
            .jsonResponseSerializer(options: .allowFragments)
            .serializeResponse(request, response, data, error)
    }
}

public extension DataRequest {
    
    /**
     * Decode a single object:
     */
    @discardableResult
    public func responseObject<T: JSONDecodable>(
        objectPath: String? = nil,
        _ completionHandler: @escaping (DataResponse<T>) -> Void)
        -> Self
    {
        let responseSerializer = DataResponseSerializer<T> { request, response, data, error in
            switch DataRequest.makeResult(request, response, data, error) {
            case .success(let value):
                return self.handleObjectSuccess(objectPath: objectPath, value: value)
            case .failure(let error):
                return .failure(error)
            }
        }
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
    
    private func handleObjectSuccess<T: JSONDecodable>(objectPath: String?, value: Any) -> Result<T> {
        do {
            guard let object = self.getObjectAt(objectPath: objectPath, from: value) else {
                throw NetworkError.UnexpectedResponse(message: "Could not find object")
            }
            return .success(try T(object: object))
        } catch (let error) {
            return .failure(error)
        }
    }
    
    private func getObjectAt(objectPath: String?, from value: Any) -> JSONObject? {
        let dict = value as? JSONObject
        if let objectPath = objectPath, !objectPath.isEmpty {
            return dict?[objectPath] as? JSONObject
        }
        return dict
    }
    
}

public extension DataRequest {
    
    /**
     * Decode an array of objects:
     */
    @discardableResult
    public func responseArray<T: JSONDecodable>(
        objectPath: String? = nil,
        completionHandler: @escaping (DataResponse<[T]>) -> Void)
        -> Self {
            let responseSerializer = DataResponseSerializer<[T]> { request, response, data, error in
                switch DataRequest.makeResult(request, response, data, error) {
                case .success(let value):
                    return self.handleArraySuccess(objectPath: objectPath, value: value)
                case .failure(let error):
                    return .failure(error)
                }
            }
            return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
    
    private func handleArraySuccess<T: JSONDecodable>(objectPath: String?, value: Any) -> Result<[T]> {
        do {
            guard let array = self.getArrayAt(objectPath: objectPath, from: value) else {
                throw NetworkError.UnexpectedResponse(message: "Could not find array")
            }
            let decoded = try array.map{ try T(object: $0) }
            return .success(decoded)
        } catch (let error) {
            return .failure(error)
        }
    }
    
    private func getArrayAt(objectPath: String?, from value: Any) -> [JSONObject]? {
        if let objectPath = objectPath, !objectPath.isEmpty {
            let dict = value as? [String: Any]
            return dict?[objectPath] as? [JSONObject]
        }
        return value as? [JSONObject]
    }
}

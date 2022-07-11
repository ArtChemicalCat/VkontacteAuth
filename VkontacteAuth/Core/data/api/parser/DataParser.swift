//
//  DataParser.swift
//  VkontacteAuth
//
//  Created by Николай Казанин on 06.07.2022.
//

import Foundation

protocol DataParserProtocol {
    func parse<T: Decodable>(data: Data) throws -> T
}

final class DataParser:DataParserProtocol {
    private var decoder: JSONDecoder
    
    init(jsonDecoder: JSONDecoder = JSONDecoder()) {
        decoder = jsonDecoder
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func parse<T: Decodable>(data: Data) throws -> T {
        try decoder.decode(T.self, from: data)
    }
}

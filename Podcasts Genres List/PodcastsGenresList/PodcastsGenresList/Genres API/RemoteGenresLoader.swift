//
//  RemoteGenresLoader.swift
//  PodcastsGenresList
//
//  Created by Alexander Nikolaychuk on 31.08.2022.
//

import Foundation

public typealias HTTPClientResult = Result<(Data, HTTPURLResponse), Error>

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteGenresLoader {
    public typealias Result = Swift.Result<[Genre], Error>
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url, completion: { result in
            switch result {
            case let .success((data, response)):
                if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.success(root.genres.map { $0.item }))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        })
    }
}

private struct Root: Decodable {
    let genres: [Item]
}

private struct Item: Decodable {
    let id: Int
    let name: String
    
    var item: Genre {
        return .init(id: id, name: name)
    }
}

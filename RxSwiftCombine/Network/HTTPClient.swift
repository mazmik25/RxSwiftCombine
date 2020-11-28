//
//  HTTPClient.swift
//  RxSwiftCombine
//
//  Created by Azmi Muhammad on 28/11/20.
//

import RxSwift
import Combine

// https://api.themoviedb.org/3

enum NetworkError: Error {
  case urlNotFound
  case responseNotFound
  case error(withStatusCode: Int)
  case failed(withError: Error)
  case failedToDecoding
}

final class HTTPClient<Element: Codable> {
  
  private let parameters: [String : Any]
  private let method: HTTPMethods
  private let url: URL?
  private var cancelable: Set<AnyCancellable> = Set<AnyCancellable>()
  
  init(parameters: [String : Any], path: String, method: HTTPMethods) {
    self.parameters = parameters
    self.method = method
    self.url = URL(string: path)
  }
  
  func requestWithRxSwift() -> Single<Element> {
    print("Requesting with RxSwift . . .")
    return Single.create { subscriber in
      if let url: URL = self.url {
        let dataTask: URLSessionTask = self.setupSession().dataTask(with: self.setupRequest(withURL: url)) { data, response, error in
          if let response: HTTPURLResponse = response as? HTTPURLResponse {
            if Array(200..<300).contains(response.statusCode) {
              do {
                let decoder: JSONDecoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let model: Element = try decoder.decode(Element.self, from: data ?? Data())
                subscriber(.success(model))
              } catch {
                subscriber(.error(NetworkError.failedToDecoding))
              }
            } else {
              subscriber(.error(NetworkError.error(withStatusCode: response.statusCode)))
            }
          } else {
            subscriber(.error(NetworkError.responseNotFound))
          }
        }
        dataTask.resume()
        return Disposables.create()
      } else {
        subscriber(.error(NetworkError.urlNotFound))
        return Disposables.create()
      }
    }
    .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    .observeOn(MainScheduler.instance)
  }
  
  func requestWithCombine(completion: @escaping (Result<Element, Error>) -> Void) {
    print("Requesting with Combine . . .")
    if let publisher: AnyPublisher<Element, Error> = setupPublisher() {
      publisher
        .subscribe(on: DispatchQueue.global(qos: .background))
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { event in
          switch event {
          case .failure(let error): completion(.failure(NetworkError.failed(withError: error)))
          default: break
          }
        }, receiveValue: { element in
          completion(.success(element))
        }).store(in: &cancelable)
    } else {
      completion(.failure(NetworkError.urlNotFound))
    }
  }
  
  private func setupPublisher() -> AnyPublisher<Element, Error>? {
    if let url: URL = url {
      let decoder: JSONDecoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      return setupSession().dataTaskPublisher(for: setupRequest(withURL: url))
        .map { $0.data }
        .decode(type: Element.self, decoder: decoder)
        .catch { _ in Fail(error: NetworkError.failedToDecoding).eraseToAnyPublisher() }
        .eraseToAnyPublisher()
    } else { return nil }
  }
  
  private func setupSession() -> URLSession {
    let configuration: URLSessionConfiguration = URLSessionConfiguration.default
    let session: URLSession = URLSession(configuration: configuration)
    return session
  }
  
  private func setupRequest(withURL url: URL) -> URLRequest {
    var request: URLRequest
    switch method {
      case .GET:
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        var queryItems: [URLQueryItem] = []
        for key in parameters.keys {
            queryItems.append(URLQueryItem(name: key, value: "\(parameters[key]!)"))
        }
        urlComponents.queryItems = queryItems
        urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        request =  URLRequest(url: urlComponents.url!)
        
      default:
        request = URLRequest(url: url)
        do {
          let httpBody: Data = try JSONSerialization.data(withJSONObject: parameters)
          request.httpBody = httpBody
          request.httpMethod = method.rawValue
        } catch {
          print(error)
        }
      }
    
    request.httpMethod = method.rawValue
    request.addValue("token", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "accept")
    return request
  }
}

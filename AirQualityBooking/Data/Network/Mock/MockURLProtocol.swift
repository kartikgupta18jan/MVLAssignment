//
//  MockURLProtocol.swift
//  AirQualityBookingApp
//
//  Created by Gupta Kartik on 31/05/26.
//

import Foundation
import Alamofire

/// Intercepts URLRequests at the transport layer and returns canned JSON.
///
/// The repositories build REAL, correct requests (POST /books with proper body,
///

final class MockURLProtocol: URLProtocol {

    struct Response {
        let statusCode: Int
        let data: Data
    }

    typealias Handler = (URLRequest) throws -> Response

    private static var handlers: [String: Handler] = [:]
    private static let lock = NSLock()

    static func register(method: HTTPMethod, pathContains path: String, handler: @escaping Handler) {
        lock.lock(); defer { lock.unlock() }
        handlers["\(method.rawValue)|\(path)"] = handler
    }

    static func reset() {
        lock.lock(); defer { lock.unlock() }
        handlers.removeAll()
    }

    /// Builds an Alamofire Session whose URLSession routes through this mock.
    static func makeSession() -> Session {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return Session(configuration: config)
    }

    private static func handler(for request: URLRequest) -> Handler? {
        lock.lock(); defer { lock.unlock() }
        guard let method = request.httpMethod,
              let path   = request.url?.path else { return nil }
        return handlers.first { key, _ in
            let parts = key.split(separator: "|", maxSplits: 1)
            return parts.count == 2
                && String(parts[0]) == method
                && path.contains(String(parts[1]))
        }?.value
    }

    // MARK: URLProtocol

    override class func canInit(with request: URLRequest) -> Bool {
        handler(for: request) != nil
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let req = Self.restoreBody(from: request)
        guard let handler = Self.handler(for: req) else {
            client?.urlProtocol(self, didFailWithError: NetworkError.noData)
            return
        }
        do {
            Thread.sleep(forTimeInterval: 0.15) // realistic latency
            let mock = try handler(req)
            let httpResponse = HTTPURLResponse(
                url: req.url!,
                statusCode: mock.statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            client?.urlProtocol(self, didReceive: httpResponse, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: mock.data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}

    // URLProtocol moves the body into a stream; read it back so handlers
    private static func restoreBody(from request: URLRequest) -> URLRequest {
        var req = request
        guard req.httpBody == nil, let stream = req.httpBodyStream else { return req }
        stream.open(); defer { stream.close() }
        var data = Data()
        let buf  = UnsafeMutablePointer<UInt8>.allocate(capacity: 4096)
        defer { buf.deallocate() }
        while stream.hasBytesAvailable {
            let n = stream.read(buf, maxLength: 4096)
            guard n > 0 else { break }
            data.append(buf, count: n)
        }
        req.httpBody = data
        return req
    }
}

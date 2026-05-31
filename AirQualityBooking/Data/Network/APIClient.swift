import Foundation
import Alamofire

// MARK: - Protocol

protocol APIClient {
    func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T
}

// MARK: - Alamofire implementation

/// Concrete APIClient backed by Alamofire.
/// Repositories receive this via DI and depend only on the protocol —
/// switching to a mock transport requires zero changes in any repository.
final class AlamofireAPIClient: APIClient {
    private let session: Session

    init(session: Session = .default) {
        self.session = session
    }

    func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        // Build URL with query items
        guard var components = URLComponents(
            url: endpoint.baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: false
        ) else { throw NetworkError.invalidURL }

        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }

        guard let url = components.url else { throw NetworkError.invalidURL }

        // Build URLRequest
        var urlRequest        = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue

        if let body = endpoint.body {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(AnyEncodable(body))
        }

        // Execute via Alamofire
        let response = await session
            .request(urlRequest)
            .validate()
            .serializingData()
            .response

        switch response.result {
        case .success(let data):
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingFailed
            }
        case .failure(let afError):
            if let code = response.response?.statusCode, !(200..<300).contains(code) {
                throw NetworkError.invalidResponse(statusCode: code)
            }
            throw NetworkError.transport(afError.localizedDescription)
        }
    }
}

// Type-erased Encodable wrapper so Endpoint.body can stay protocol-typed.
private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    init(_ wrapped: any Encodable) { _encode = wrapped.encode }
    func encode(to encoder: Encoder) throws { try _encode(encoder) }
}

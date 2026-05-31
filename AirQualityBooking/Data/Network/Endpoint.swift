import Foundation

enum HTTPMethod: String {
    case get  = "GET"
    case post = "POST"
}

/// Transport-agnostic description of one API request.
/// Repositories build these; APIClient executes them.
/// Swapping Alamofire for URLSession (or a mock) never touches the repositories.
struct Endpoint {
    let baseURL: URL
    let path: String
    let method: HTTPMethod
    var queryItems: [URLQueryItem] = []
    var body: (any Encodable)?     = nil
}

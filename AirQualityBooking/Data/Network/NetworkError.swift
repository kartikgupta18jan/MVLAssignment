import Foundation

enum NetworkError: Error, LocalizedError {
    case missingToken
    case invalidURL
    case invalidResponse(statusCode: Int)
    case decodingFailed
    case noData
    case transport(String)
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .missingToken:                return "AQICN API token not configured."
        case .invalidURL:                  return "Invalid request URL."
        case .invalidResponse(let code):   return "Server responded with \(code)."
        case .decodingFailed:              return "Could not parse the server response."
        case .noData:                      return "No data was returned."
        case .transport(let msg):          return msg
        case .apiError(let msg):           return msg
        }
    }
}

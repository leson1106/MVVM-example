import MVVMDomain
import Foundation

public enum WeatherAPIError: LocalizedError, Equatable {
    case missingAccessKey
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case api(message: String)

    public var errorDescription: String? {
        switch self {
        case .missingAccessKey:
            return "Missing WeatherAPI key"
        case .invalidURL:
            return "Invalid weather API URL"
        case .invalidResponse:
            return "Invalid weather API response"
        case .httpStatus(let code):
            return "Weather API HTTP error \(code)"
        case .api(let message):
            return message
        }
    }
}

public struct WeatherAPIConfiguration {
    public static let defaultAPIKey = "951c52e884644ba0a0592333261007"

    public let apiKey: String
    public let baseURL: URL
    public let locationQuery: String

    public init() {
        apiKey = Self.defaultAPIKey
        baseURL = URL(string: "https://api.weatherapi.com/v1")!
        locationQuery = MVVMDomain.weatherLocationQuery
    }

    public init(
        apiKey: String = defaultAPIKey,
        baseURL: URL = URL(string: "https://api.weatherapi.com/v1")!,
        locationQuery: String = MVVMDomain.weatherLocationQuery
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.locationQuery = locationQuery
    }
}

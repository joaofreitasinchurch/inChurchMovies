import Foundation

struct APIError: LocalizedError {
    let errorDescription: String
    let type: ErrorType
    var code: Int?

    enum ErrorType {
        case request
        case decode
        case unauthorized
        case generic
        case noConnection
    }

    init(_ error: NSError) {
        self.errorDescription = error.domain
        self.code = error.userInfo["error_code"] as? Int

        switch error.code {
        case 0:
            self.type = .noConnection
        case 400:
            self.type = .request
        case 401:
            self.type = .unauthorized
        default:
            self.type = .generic
        }
    }

    init(type: ErrorType, description: String) {
        self.type = type
        self.errorDescription = description
        self.code = nil
    }
}

extension APIError {
    static var decode: Self {
        .init(type: .decode, description: "error_internet_generic".localizedLowercase)
    }

    static var generic: Self {
        .init(type: .generic, description: "error_internet_generic".localizedLowercase)
    }
}

// Copyright © 2022 Jamit Labs GmbH. All rights reserved.

import Foundation
import Jetworking

/// This is an example of an interceptor that specifically logs when one specific status code occurs.
public final class StatusCodeLoggingInterceptor: Interceptor {
    // MARK: - Properties
    private var logger: Logger

    // MARK: - Initializers
    public init(logger: Logger = DefaultLogger()) {
        self.logger = logger
    }

    // MARK: - Methods
    public func intercept(response: URLResponse?, data: Data?, error: Error?) -> URLResponse? {
        if let response = response as? HTTPURLResponse, response.statusCode == 413 {
            // This is just an example of what can be done
            logger.log("⛔️ The weird 413 status code occured!")
        }

        return response
    }
}

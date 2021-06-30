import XCTest
@testable import Jetworking

final class EndpointTests: XCTestCase {
    func testAddingSingleQueryParameter() throws {
        let endpointWithParams = Endpoints.get.addQueryParameter(
            key: "QueryParamKey",
            value: "QueryParamValue"
        )

        XCTAssertEqual(endpointWithParams.queryParameters, ["QueryParamKey": "QueryParamValue"])
    }

    func testAddingNilValueAsQueryParamter() throws {
        let endpointWithParams = Endpoints.get.addQueryParameter(key: "QueryParamKey", value: nil)
        XCTAssertEqual(endpointWithParams.queryParameters, ["QueryParamKey": nil])
    }

    func testOverridingAnExistingQueryParamter() throws {
        let endpointWithParams = Endpoints.get.addQueryParameter(key: "QueryParamKey", value: "ValueToOverride")
        XCTAssertEqual(endpointWithParams.queryParameters, ["QueryParamKey": "ValueToOverride"])

        let endpointWithOverridenParams = endpointWithParams.addQueryParameter(
            key: "QueryParamKey",
            value: "TheNewValue"
        )

        XCTAssertEqual(endpointWithOverridenParams.queryParameters, ["QueryParamKey": "TheNewValue"])
    }

    func testAddingMultipleParameters() throws {
        let parameters: [String: String?] = [
            "firstKey": "firstValue",
            "secondKey": "secondValue",
            "KeyWithoutValue": nil
        ]

        let endpointWithParameters = Endpoints.get.addQueryParameters(parameters)

        XCTAssertEqual(endpointWithParameters.queryParameters, parameters)
    }

    func testMergingParamters() throws {
        let parameters: [String: String?] = [
            "firstKey": "firstValue",
            "secondKey": "secondValue",
            "KeyWithoutValue": nil
        ]

        let parmetersToMerge: [String: String?] = [
            "firstKey": "AnotherFirstValue",
            "KeyWithoutValue": "NowItHasAValue",
            "SomeNewKey": "ANewValue"
        ]

        let endpointWithParameters = Endpoints.get.addQueryParameters(parameters)
        let endpointWithMoreParameters = endpointWithParameters.addQueryParameters(parmetersToMerge)

        XCTAssertEqual(
            endpointWithMoreParameters.queryParameters,
            [
                "firstKey": "AnotherFirstValue",
                "secondKey": "secondValue",
                "KeyWithoutValue": "NowItHasAValue",
                "SomeNewKey": "ANewValue"
            ]
        )
    }
}

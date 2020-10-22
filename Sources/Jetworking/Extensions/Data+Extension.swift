import Foundation

extension Data {
    init?(boundary: String, formData: [String: String], fileURL: URL, multipartFileContentType: MultipartContentType) {
        guard let fileData: Data = try? Data(contentsOf: fileURL) else { return nil }

        self.init()

        formData.forEach { key, value in
            append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            append("\(value)".data(using: .utf8)!)
        }

        let filename: String = fileURL.lastPathComponent
        append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"fileToUpload\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        append("Content-Type: \(multipartFileContentType.rawValue)\r\n\r\n".data(using: .utf8)!)
        append(fileData)

        append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
    }
}

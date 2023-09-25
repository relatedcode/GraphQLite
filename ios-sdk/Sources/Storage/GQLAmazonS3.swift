//
// Copyright (c) 2023 Related Code - https://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import CryptoKit

//-----------------------------------------------------------------------------------------------------------------------------------------------
class GQLAmazonS3: NSObject {

	private var regionName = ""

	private let serviceName = "s3"
	private let requestName = "aws4_request"

	private var secretKey = ""
	private var accessKey = ""

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ regionName: String, _ secretKey: String, _ accessKey: String) {

		super.init()

		self.regionName = regionName
		self.secretKey = secretKey
		self.accessKey = accessKey
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAmazonS3 {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func upload(_ bucket: String, _ key: String, _ data: Data, _ completion: @escaping (Error?) -> Void) {

		var request = URLRequest(url: url(bucket, key), timeoutInterval: Double.infinity)
		request.httpMethod = "PUT"
		request.httpBody = data

		let requestAWS = createAWSRequest(from: request, with: data)

		let task = URLSession.shared.dataTask(with: requestAWS) { data, response, error in
			if (error == nil) {
				if let response = response as? HTTPURLResponse {
					if (response.statusCode == 200) {
						completion(nil)
					} else {
						completion(GQLError("Response error.", response.statusCode))
					}
				} else {
					completion(GQLError("Unknown error.", 100))
				}
			} else {
				completion(error)
			}
		}
		task.resume()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func download(_ bucket: String, _ key: String, _ completion: @escaping (Data?, Error?) -> Void) {

		var request = URLRequest(url: url(bucket, key), timeoutInterval: Double.infinity)
		request.httpMethod = "GET"

		let requestAWS = createAWSRequest(from: request)

		let task = URLSession.shared.dataTask(with: requestAWS) { data, response, error in
			if (error == nil) {
				if let data = data, let response = response as? HTTPURLResponse {
					if (response.statusCode == 200) {
						completion(data, nil)
					} else {
						completion(nil, GQLError("Response error.", response.statusCode))
					}
				} else {
					completion(nil, GQLError("Unknown error.", 100))
				}
			} else {
				completion(nil, error)
			}
		}
		task.resume()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func delete(_ bucket: String, _ key: String, _ completion: @escaping (Error?) -> Void) {

		var request = URLRequest(url: url(bucket, key), timeoutInterval: Double.infinity)
		request.httpMethod = "DELETE"

		let requestAWS = createAWSRequest(from: request)

		let task = URLSession.shared.dataTask(with: requestAWS) { data, response, error in
			if (error == nil) {
				if let response = response as? HTTPURLResponse {
					if (response.statusCode == 204) {
						completion(nil)
					} else {
						completion(GQLError("Response error.", response.statusCode))
					}
				} else {
					completion(GQLError("Unknown error.", 100))
				}
			} else {
				completion(error)
			}
		}
		task.resume()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAmazonS3 {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func createAWSRequest(from request: URLRequest, with data: Data = Data()) -> URLRequest {

		let date = dateISO()
		var request = request

		request.addValue(sha256(data), forHTTPHeaderField: "X-Amz-Content-Sha256")
		request.addValue("\(data.count)", forHTTPHeaderField: "content-length")
		request.addValue(date.long, forHTTPHeaderField: "X-Amz-Date")
		request.addValue(request.url!.host!, forHTTPHeaderField: "Host")

		let credential = [date.short, regionName, serviceName, requestName].joined(separator: "/")
		let signedHeaders = request.allHTTPHeaderFields!.map{ $0.key.lowercased() }.sorted().joined(separator: ";")

		let canonicalRequest = createCanonicalRequest(from: request, with: signedHeaders, data: data)
		let stringToSign = createStringToSign(with: canonicalRequest, credential: credential, and: date.long)
		let signature = calculateTheSignature(with: stringToSign, and: date.short)

		let authorization = "AWS4-HMAC-SHA256 Credential=\(secretKey)/\(credential), SignedHeaders=\(signedHeaders), Signature=\(signature)"
		request.addValue(authorization, forHTTPHeaderField: "Authorization")

		return request
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func createCanonicalRequest(from request: URLRequest, with signedHeaders: String, data: Data) -> String {

		let path = request.url?.path ?? ""
		let query = request.url?.query ?? ""
		let method = request.httpMethod ?? ""

		let canonicalHeaders = request.allHTTPHeaderFields!.map{ $0.key.lowercased() + ":" + $0.value }.sorted().joined(separator: "\n")

		let canonicalRequest = [method, path, query, canonicalHeaders, "", signedHeaders, sha256(data)]

		return sha256(canonicalRequest.joined(separator: "\n"))
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func createStringToSign(with canonicalRequestHash: String, credential: String, and dateLong: String) -> String {

		let arrStringToSign = ["AWS4-HMAC-SHA256", dateLong, credential, canonicalRequestHash]
		let stringToSign = arrStringToSign.joined(separator: "\n")
		return stringToSign
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func calculateTheSignature(with stringToSign: String, and dateShort: String) -> String {

		let date = hmac(message: dateShort, key: "AWS4\(accessKey)")
		let region = hmac(message: regionName, key: date)
		let service = hmac(message: serviceName, key: region)
		let signing = hmac(message: requestName, key: service)
		let signature = hmac(message: stringToSign, key: signing)

		return signature.compactMap { String(format: "%02x", $0) }.joined()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func hmac(message: String, key: String) -> Data {

		return hmac(message: Data(message.utf8), key: Data(key.utf8))
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func hmac(message: String, key: Data) -> Data {

		return hmac(message: Data(message.utf8), key: key)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func hmac(message: Data, key keyData: Data) -> Data {

		let symmetricKey = SymmetricKey(data: keyData)
		let passwordHashDigest = HMAC<SHA256>.authenticationCode(for: message, using: symmetricKey)
		return Data(passwordHashDigest)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAmazonS3 {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func url(_ bucket: String, _ key: String) -> URL {

		let key = key.replacingOccurrences(of: "|", with: "")
		let link = "https://\(bucket).s3.amazonaws.com/\(key)"

		guard let url = URL(string: link) else {
			fatalError("URL error: \(link)")
		}

		return url
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAmazonS3 {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func dateISO() -> (long: String, short: String) {

		let formatter = DateFormatter()
		formatter.calendar = Calendar(identifier: .iso8601)
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(identifier: "UTC")
		formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"

		let dateLong = formatter.string(from: Date())
		let dateShort = String(dateLong.prefix(8))

		return (long: dateLong, short: dateShort)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAmazonS3 {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func sha256(_ data: Data) -> String {

		let hash = SHA256.hash(data: data)

		return hash.compactMap { String(format: "%02x", $0) }.joined()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func sha256(_ text: String) -> String {

		let data = Data(text.utf8)
		let hash = SHA256.hash(data: data)

		return hash.compactMap { String(format: "%02x", $0) }.joined()
	}
}

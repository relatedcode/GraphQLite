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

//-----------------------------------------------------------------------------------------------------------------------------------------------
class GQLHTTP: NSObject {

	private var url: URL!

	private var headers = ["Content-Type": "application/json", "Accept": "application/json"]

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ link: String, _ headers: [String: String]) {

		super.init()

		url = URL(string: link)

		self.headers.merge(headers) { (_, new) in new }
	}

	// MARK: - Send methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func sendAuth(_ query: String, _ variables: [String: Any], _ auth: [String: String], _ callback: @escaping GQLResultCallback) {

		send(query, variables, merge(headers, auth), callback)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func send(_ query: String, _ variables: [String: Any], _ callback: @escaping GQLResultCallback) {

		send(query, variables, headers, callback)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func send(_ query: String, _ variables: [String: Any], _ headers: [String: String], _ callback: @escaping GQLResultCallback) {

		var request = URLRequest(url: url)
		request.allHTTPHeaderFields = headers
		request.httpMethod = "POST"
		request.httpBody = convert(["query": query, "variables": variables])

		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			if (error == nil) {
				self.processResult(data, callback)
			} else {
				callback([:], error)
			}
		}

		task.resume()
	}
}

// MARK: - Result methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLHTTP {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func processResult(_ data: Data?, _ callback: @escaping GQLResultCallback) {

		if let dictionary = convert(data) {
			if let message = errorMessage(dictionary) {
				callback([:], GQLError(message, 100))
			} else {
				if let result = dictionary["data"] as? [String: Any] {
					callback(result, nil)
				} else {
					let message = "Result error. \(dictionary)"
					callback([:], GQLError(message, 100))
				}
			}
		} else {
			let text: String = convert(data)
			let message = "Result error. \(text)"
			callback([:], GQLError(message, 101))
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func errorMessage(_ dictionary: [String: Any]) -> String? {

		if let errors = dictionary["errors"] as? [[String: Any]] {
			if let error = errors.first {
				if let message = error["message"] as? String {
					return message
				}
			}
		}

		if let error = dictionary["error"] as? [String: Any] {
			if let message = error["message"] as? String {
				return message
			}
		}

		return nil
	}
}

// MARK: - Convert methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLHTTP {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func convert(_ dictionary: [String: Any]) -> Data {

		if let data = try? JSONSerialization.data(withJSONObject: dictionary) {
			return data
		}
		fatalError("JSONSerialization error. \(dictionary)")
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func convert(_ data: Data?) -> [String: Any]? {

		if let data = data {
			return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
		}
		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func convert(_ data: Data?) -> String {

		if let data = data {
			if let text = String(data: data, encoding: .utf8) {
				return text
			}
		}
		return ""
	}
}

// MARK: - Helper methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLHTTP {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func merge(_ base: [String: String], _ extra: [String: String]) -> [String: String] {

		var result = base
		result.merge(extra) { (_, new) in new }
		return result
	}
}

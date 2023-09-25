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
class GQLAppSync: NSObject {

	private var url: URL!

	private var headers: [String: String] = [:]

	private var socket: URLSessionWebSocketTask?

	private var callonce: [String: Bool] = [:]
	private var callbacks: [String: GQLResultCallback] = [:]

	private var connectCallback: GQLErrorCallback?

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ link: String, _ headers: [String: String]) {

		super.init()

		let data = try! JSONEncoder().encode(headers)
		let encoded = data.base64EncodedString()

		url = URL(string: "\(link)?header=\(encoded)&payload=e30=")

		self.headers = headers
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	deinit {

		disconnect()
	}

	// MARK: - Web Socket methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func connect(_ callback: @escaping GQLErrorCallback) {

		if (socket == nil) {
			connectCallback = callback

			var request = URLRequest(url: url)
			request.allHTTPHeaderFields = ["Sec-WebSocket-Protocol": "graphql-ws"]
			let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())

			socket = session.webSocketTask(with: request)
			socket?.resume()
		} else {
			callback(GQLError("Already connected.", 100))
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func disconnect() {

		if (socket == nil) { return }

		socket?.cancel(with: .goingAway, reason: nil)

		socket = nil
	}

	// MARK: - Connection init
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func connectionInit() {

		let dictionary = ["type": "connection_init"]

		socket?.send(message(dictionary)) { error in
			if (error != nil) {
				GQLDebug.error(error)
			}
		}
	}

	// MARK: - Subscription methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func subscription(_ query: String, _ variables: [String: Any], _ callback: @escaping GQLResultCallback) -> String {

		var query = query

		query = query.replacingOccurrences(of: "\n", with: "\\n")
		query = query.replacingOccurrences(of: "\t", with: "\\t")

		let variables = convert(variables)

		let data = "{\"query\":\"\(query)\",\"variables\":\(variables)}"
		let payload: [String: Any] = ["data": data, "extensions": ["authorization": headers]]

		let callbackId = UUID().uuidString
		let dictionary = prepare("start", callbackId, payload)

		socket?.send(message(dictionary)) { [self] error in
			if (error == nil) {
				callbackAdd(callbackId, callback)
			} else {
				callback([:], error)
			}
		}

		return callbackId
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func subscription(cancel callbackId: String, _ callback: @escaping GQLErrorCallback) {

		let dictionary = prepare("stop", callbackId)

		socket?.send(message(dictionary)) { [self] error in
			if (error == nil) {
				callbackDel(callbackId)
			}
			callback(error)
		}
	}

	// MARK: -
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func prepare(_ type: String, _ id: String, _ payload: [String: Any]) -> [String: Any] {

		return ["type": type, "id": id, "payload": payload]
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func prepare(_ type: String, _ id: String) -> [String: Any] {

		return ["type": type, "id": id]
	}
}

// MARK: - Result methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAppSync {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func receiveMessage() {

		socket?.receive { [self] result in
			switch result {
			case .success(let message):
				handleMessage(message)
				receiveMessage()
			case .failure(let error):
				if let callback = connectCallback {
					callback(error)
					connectCallback = nil
				} else {
					GQLDebug.error(error)
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func handleMessage(_ message: URLSessionWebSocketTask.Message) {

		switch message {
		case .string(let text):
			processMessage(text)
		case .data:
			GQLDebug.info("WebSocket: Data message received.")
		default:
			GQLDebug.info("WebSocket: Unknown message received.")
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func processMessage(_ text: String) {

		if let dictionary = convert(text) {
			if let type = dictionary["type"] as? String {
				switch type {
				case "connection_ack":
					GQLDebug.info(text)
					connectCallback?(nil)
					connectCallback = nil
				case "connection_error":
					let message = errorMessage(dictionary)
					connectCallback?(GQLError(message, 100))
					connectCallback = nil
				case "start_ack":
					GQLDebug.info(text)
				case "data":
					processData(dictionary)
				case "error":
					processError(dictionary)
				case "ka":
					break
				case "complete":
					GQLDebug.info(text)
				default:
					GQLDebug.info("???: \(text)")
				}
			} else {
				GQLDebug.error("Result error. \(dictionary)")
			}
		} else {
			GQLDebug.error("Result error. \(text)")
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func processData(_ dictionary: [String: Any]) {

		if let callbackId = dictionary["id"] as? String {
			if let callback = callbackGet(callbackId) {
				if let payload = dictionary["payload"] as? [String: Any] {
					if let result = payload["data"] as? [String: Any] {
						callback(result, nil)
					}
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func processError(_ dictionary: [String: Any]) {

		let message = errorMessage(dictionary)

		if let callbackId = dictionary["id"] as? String {
			if let callback = callbackGet(callbackId) {
				callback([:], GQLError(message, 100))
			}
		} else {
			GQLDebug.error(message)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func errorMessage(_ dictionary: [String: Any]) -> String {

		if let payload = dictionary["payload"] as? [String: Any] {
			if let errors = payload["errors"] as? [[String: Any]] {
				if let error = errors.first {
					if let message = error["message"] as? String {
						return message
					}
				}
			}
		}
		return "Result error. \(dictionary)"
	}
}

// MARK: - URLSessionWebSocketDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAppSync: URLSessionWebSocketDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {

		receiveMessage()
		connectionInit()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {

	}
}

// MARK: - Callback methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAppSync {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func callbackGet(_ callbackId: String) -> GQLResultCallback? {

		let result = callbacks[callbackId]

		if (callonce[callbackId] == true) {
			callbackDel(callbackId)
		}

		return result
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func callbackAdd(_ callbackId: String, _ callback: @escaping GQLResultCallback) {

		DispatchQueue.main.async {
			self.callonce[callbackId] = false
			self.callbacks[callbackId] = callback
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func callbackOne(_ callbackId: String, _ callback: @escaping GQLResultCallback) {

		DispatchQueue.main.async {
			self.callonce[callbackId] = true
			self.callbacks[callbackId] = callback
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func callbackDel(_ callbackId: String) {

		DispatchQueue.main.async {
			self.callonce.removeValue(forKey: callbackId)
			self.callbacks.removeValue(forKey: callbackId)
		}
	}
}

// MARK: - Convert methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAppSync {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func message(_ dictionary: [String: Any]) -> URLSessionWebSocketTask.Message {

		if let data = try? JSONSerialization.data(withJSONObject: dictionary) {
			if let text = String(data: data, encoding: .utf8) {
				return .string(text)
			}
		}
		fatalError("JSONSerialization error. \(dictionary)")
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func convert(_ dictionary: [String: Any]) -> String {

		if let data = try? JSONSerialization.data(withJSONObject: dictionary) {
			if let text = String(data: data, encoding: .utf8) {
				return text
			}
		}
		fatalError("JSONSerialization error. \(dictionary)")
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func convert(_ text: String) -> [String: Any]? {

		if let data = text.data(using: .utf8) {
			return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
		}
		return nil
	}
}

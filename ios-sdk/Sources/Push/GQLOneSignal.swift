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
class GQLOneSignal: NSObject {

	private var appId = ""
	private var keyAPI = ""

	private var token = ""

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: GQLOneSignal = {
		let instance = GQLOneSignal()
		return instance
	} ()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func setup(_ appId: String, _ keyAPI: String) {

		shared.appId = appId
		shared.keyAPI = keyAPI
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func token(_ deviceToken: Data) {

		shared.token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLOneSignal {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func appId() -> String {

		if (shared.appId.isEmpty) {
			fatalError("GQLPush setup must be called first.")
		}
		return shared.appId
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func keyAPI() -> String {

		if (shared.keyAPI.isEmpty) {
			fatalError("GQLPush setup must be called first.")
		}
		return shared.keyAPI
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLOneSignal {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func unregister() {

		register("")
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func register(_ userId: String) {

		var systemInfo = utsname(); uname(&systemInfo)
		let device_model = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
			return String(cString: ptr)
		}

		let timezone = NSTimeZone.local.secondsFromGMT()
		let system = ProcessInfo.processInfo.operatingSystemVersion
		let version_os = "\(system.majorVersion).\(system.minorVersion).\(system.patchVersion)"
		let version_app = Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "1.0"

		let link = "https://onesignal.com/api/v1/players"

		let dictionary: [String: Any] = ["app_id": appId(), "identifier": shared.token, "language": "en", "timezone": timezone,
										 "device_type": "0", "device_model": device_model, "device_os": version_os,
										 "game_version": version_app, "sdk": "none", "test_type": 1, "external_user_id": userId]

		if (GQLNetwork.isReachable()) {
			register(link, dictionary)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func register(_ link: String, _ dictionary: [String: Any]) {

		let url = URL(string: link)
		var request = URLRequest(url: url!)
		request.allHTTPHeaderFields = ["Content-Type": "application/json"]
		request.httpMethod = "POST"
		request.httpBody = convert(dictionary)

		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			if (error != nil) {
				GQLDebug.error(error)
			}
		}

		task.resume()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLOneSignal {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func send(_ chatId: String, _ userIds: [String], _ text: String) {

		let link = "https://onesignal.com/api/v1/notifications"

		let dictionary: [String: Any] = ["app_id": appId(), "contents": ["en": text], "data": ["chatId": chatId],
										 "include_external_user_ids": userIds, "channel_for_external_user_ids": "push"]

		if (GQLNetwork.isReachable()) {
			send(link, dictionary)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func send(_ link: String, _ dictionary: [String: Any]) {

		let url = URL(string: link)
		var request = URLRequest(url: url!)
		request.allHTTPHeaderFields = ["Content-Type": "application/json; charset=utf-8", "Authorization": "Basic \(keyAPI())"]
		request.httpMethod = "POST"
		request.httpBody = convert(dictionary)

		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			if (error != nil) {
				GQLDebug.error(error)
			}
		}

		task.resume()
	}
}

// MARK: - Convert methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLOneSignal {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func convert(_ dictionary: [String: Any]) -> Data {

		if let data = try? JSONSerialization.data(withJSONObject: dictionary) {
			return data
		}
		fatalError("JSONSerialization error. \(dictionary)")
	}
}

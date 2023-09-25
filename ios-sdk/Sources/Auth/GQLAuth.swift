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
public class GQLAuth: NSObject {

	private var link = ""

	private var userId: String = ""
	private var idtoken: String = ""
	private var refresh: String = ""
	private var expires: Double = 0

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: GQLAuth = {
		let instance = GQLAuth()
		return instance
	} ()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func setup(_ link: String) {

		shared.link	= link
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAuth {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func link() -> String {

		if (shared.link.isEmpty) {
			fatalError("GQLAuth setup must be called first.")
		}
		return shared.link
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func linkLogin() -> String	{ return link() + "/auth/login"					}
	private class func linkLogout() -> String	{ return link() + "/auth/logout"				}
	private class func linkCreate() -> String	{ return link() + "/auth/users"					}
	private class func linkUpdate() -> String	{ return link() + "/auth/users/" + userId()		}
	private class func linkRefresh() -> String	{ return link() + "/auth/refresh"				}
	private class func linkVerify() -> String	{ return link() + "/auth/verify"				}
	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func urlLogin() -> URL		{ return URL(string: linkLogin())!				}
	private class func urlLogout() -> URL		{ return URL(string: linkLogout())!				}
	private class func urlCreate() -> URL		{ return URL(string: linkCreate())!				}
	private class func urlUpdate() -> URL		{ return URL(string: linkUpdate())!				}
	private class func urlRefresh() -> URL		{ return URL(string: linkRefresh())!			}
	private class func urlVerify() -> URL		{ return URL(string: linkVerify())!				}
	//-------------------------------------------------------------------------------------------------------------------------------------------
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAuth {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func userId() -> String {

		if (shared.userId == "") {
			shared.userId = UserDefaults.standard.string(forKey: "GQLAuth_UserId") ?? ""
		}
		return shared.userId
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func idToken() -> String {

		if (shared.idtoken == "") {
			shared.idtoken = UserDefaults.standard.string(forKey: "GQLAuth_IdToken") ?? ""
		}
		return shared.idtoken
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func refreshToken() -> String {

		if (shared.refresh == "") {
			shared.refresh = UserDefaults.standard.string(forKey: "GQLAuth_Refresh") ?? ""
		}
		return shared.refresh
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func expires() -> Double {

		if (shared.expires == 0) {
			shared.expires = UserDefaults.standard.double(forKey: "GQLAuth_Expires")
		}
		return shared.expires
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAuth {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func authorization() -> [String: String] {

		return ["Authorization": "Bearer \(idToken())"]
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func content_type() -> [String: String] {

		return ["content-type": "application/x-www-form-urlencoded"]
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func content_type(_ values: [String: String]) -> [String: String] {

		var values = values
		values["content-type"] = "application/x-www-form-urlencoded"
		return values
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAuth {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func save(_ values: [String: Any]?) -> Error? {

		guard let userId = values?["uid"] as? String else {
			return GQLError("Response error (missing uid).", 101)
		}

		guard let idtoken = values?["idToken"] as? String else {
			return GQLError("Response error (missing idToken).", 102)
		}

		guard let refresh = values?["refreshToken"] as? String else {
			return GQLError("Response error (missing refreshToken).", 103)
		}

		guard let expires = values?["expires"] as? Double else {
			return GQLError("Response error (missing expires).", 104)
		}

		saveUser(userId, idtoken, refresh, expires)

		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func saveUser(_ userId: String, _ idtoken: String, _ refresh: String, _ expires: Double) {

		shared.userId = userId
		shared.idtoken = idtoken
		shared.refresh = refresh
		shared.expires = expires + Date().timeIntervalSince1970

		UserDefaults.standard.setValue(shared.userId, forKey: "GQLAuth_UserId")
		UserDefaults.standard.setValue(shared.idtoken, forKey: "GQLAuth_IdToken")
		UserDefaults.standard.setValue(shared.refresh, forKey: "GQLAuth_Refresh")
		UserDefaults.standard.setValue(shared.expires, forKey: "GQLAuth_Expires")
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func clearUser() {

		shared.userId = ""
		shared.idtoken = ""
		shared.refresh = ""
		shared.expires = 0

		UserDefaults.standard.removeObject(forKey: "GQLAuth_UserId")
		UserDefaults.standard.removeObject(forKey: "GQLAuth_IdToken")
		UserDefaults.standard.removeObject(forKey: "GQLAuth_Refresh")
		UserDefaults.standard.removeObject(forKey: "GQLAuth_Expires")
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAuth {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func login(_ email: String, _ password: String, _ completion: @escaping (Error?) -> Void) {

		let body = "email=\(email)&password=\(password)"

		var request = URLRequest(url: urlLogin())
		request.allHTTPHeaderFields = content_type()
		request.httpMethod = "POST"
		request.httpBody = body.data(using: .utf8)

		send(request) { response, error in
			if let error = check(response, error) {
				completion(error)
			} else {
				completion(save(response))
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func logout(_ completion: @escaping (Error?) -> Void) {

		refresh() { auth, error in
			if (error == nil) {
				logout(auth, completion)
			} else {
				clearUser()
				completion(error)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func logout(_ auth: [String: String], _ completion: @escaping (Error?) -> Void) {

		let body = "refreshToken=\(refreshToken())"

		var request = URLRequest(url: urlLogout())
		request.allHTTPHeaderFields = content_type(auth)
		request.httpMethod = "POST"
		request.httpBody = body.data(using: .utf8)

		send(request) { response, error in
			clearUser()
			if let error = check(response, error) {
				completion(error)
			} else {
				completion(nil)
			}
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAuth {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func create(_ email: String, _ password: String, _ completion: @escaping (Error?) -> Void) {

		let body = "email=\(email)&password=\(password)"

		var request = URLRequest(url: urlCreate())
		request.allHTTPHeaderFields = content_type()
		request.httpMethod = "POST"
		request.httpBody = body.data(using: .utf8)

		send(request) { response, error in
			if let error = check(response, error) {
				completion(error)
			} else {
				completion(save(response))
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func update(_ email: String, _ password: String, _ completion: @escaping (Error?) -> Void) {

		refresh() { auth, error in
			if (error == nil) {
				update(email, password, auth, completion)
			} else {
				completion(error)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func update(_ email: String, _ password: String, _ auth: [String: String], _ completion: @escaping (Error?) -> Void) {

		let body = "email=\(email)&password=\(password)"

		var request = URLRequest(url: urlUpdate())
		request.allHTTPHeaderFields = content_type(auth)
		request.httpMethod = "POST"
		request.httpBody = body.data(using: .utf8)

		send(request) { response, error in
			if let error = check(response, error) {
				completion(error)
			} else {
				completion(nil)
			}
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAuth {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func refresh(_ completion: @escaping ([String: String], Error?) -> Void) {

		let expireAfter = expires() - Date().timeIntervalSince1970

		if (expireAfter > 120) {
			completion(authorization(), nil)
		} else {
			refresh() { error in
				completion(authorization(), error)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func refresh(_ completion: @escaping (Error?) -> Void) {

		let body = "refreshToken=\(refreshToken())"

		var request = URLRequest(url: urlRefresh())
		request.allHTTPHeaderFields = content_type()
		request.httpMethod = "POST"
		request.httpBody = body.data(using: .utf8)

		send(request) { response, error in
			if let error = check(response, error) {
				completion(error)
			} else {
				completion(save(response))
			}
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAuth {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func verify(_ completion: @escaping (Error?) -> Void) {

		var request = URLRequest(url: urlVerify())
		request.allHTTPHeaderFields = authorization()
		request.httpMethod = "GET"

		send(request) { response, error in
			if let error = check(response, error) {
				completion(error)
			} else {
				completion(nil)
			}
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAuth {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func check(_ response: [String: Any]?, _ error: Error?) -> Error? {

		if let error = error { return error }

		if let error = response?["error"] as? [String: Any] {
			if let message = error["message"] as? String {
				return GQLError(message, 100)
			}
		}
		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func send(_ request: URLRequest, completion: @escaping ([String: Any]?, Error?) -> Void) {

		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			DispatchQueue.main.async {
				if (error == nil), let data = data {
					if let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
						completion(dictionary, nil)
						return
					}
				}
				completion(nil, GQLError("Request failed.", 100))
			}
		}
		task.resume()
	}
}

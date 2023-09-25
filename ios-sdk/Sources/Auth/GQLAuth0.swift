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
public class GQLAuth0: NSObject {

	private var baseUrl = ""
	private var clientId = ""
	private var clientSecret = ""
	private var connection = ""

	private var userId = ""

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: GQLAuth0 = {
		let instance = GQLAuth0()
		return instance
	} ()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func setup(_ domain: String, _ clientId: String, _ clientSecret: String, _ connection: String) {

		let prefix = domain.hasPrefix("https://") ? "" : "https://"

		let connection = connection.isEmpty ? "Username-Password-Authentication" : connection

		shared.baseUrl		= prefix + domain
		shared.clientId		= clientId
		shared.clientSecret	= clientSecret
		shared.connection	= connection
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAuth0 {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func baseUrl() -> String {

		if (shared.baseUrl.isEmpty) {
			fatalError("GQLAuth setup must be called first.")
		}
		return shared.baseUrl
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func clientId() -> String {

		if (shared.clientId.isEmpty) {
			fatalError("GQLAuth setup must be called first.")
		}
		return shared.clientId
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func clientSecret() -> String {

		if (shared.clientSecret.isEmpty) {
			fatalError("GQLAuth setup must be called first.")
		}
		return shared.clientSecret
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func connection() -> String {

		if (shared.connection.isEmpty) {
			fatalError("GQLAuth setup must be called first.")
		}
		return shared.connection
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func linkSignIn() -> String	{ return baseUrl() + "/oauth/token"				}
	private class func linkSignUp() -> String	{ return baseUrl() + "/dbconnections/signup"	}
	private class func linkToken() -> String	{ return baseUrl() + "/oauth/token"				}
	private class func linkUserInfo() -> String	{ return baseUrl() + "/userinfo"				}
	private class func linkAudience() -> String	{ return baseUrl() + "/api/v2"					}
	private class func linkPassword() -> String	{ return baseUrl() + "/api/v2/users"			}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAuth0 {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func userId() -> String {

		if (shared.userId == "") {
			shared.userId = UserDefaults.standard.string(forKey: "GQLAuth0_UserId") ?? ""
		}
		return shared.userId
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func email() -> String {

		return UserDefaults.standard.string(forKey: "GQLAuth0_Email") ?? ""
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func saveUser(_ userId: String, _ email: String) {

		shared.userId = userId

		UserDefaults.standard.setValue(userId, forKey: "GQLAuth0_UserId")
		UserDefaults.standard.setValue(email, forKey: "GQLAuth0_Email")
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func clearUser() {

		shared.userId = ""

		UserDefaults.standard.removeObject(forKey: "GQLAuth0_UserId")
		UserDefaults.standard.removeObject(forKey: "GQLAuth0_Email")
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAuth0 {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func signIn(_ email: String, _ password: String, _ completion: @escaping (Error?) -> Void) {

		var body = ""
		body.append("client_id=\(clientId())")
		body.append("&client_secret=\(clientSecret())")
		body.append("&username=\(email)")
		body.append("&password=\(password)")
		body.append("&grant_type=password")
		body.append("&scope=openid")

		let url = URL(string: linkSignIn())
		var request = URLRequest(url: url!)
		request.allHTTPHeaderFields = ["content-type": "application/x-www-form-urlencoded"]
		request.httpMethod = "POST"
		request.httpBody = body.data(using: .utf8)

		send(request) { response, error in
			if (error == nil) {
				if let tokenType = response?["token_type"] as? String {
					if let accessToken = response?["access_token"] as? String {
						self.userInfo(tokenType, accessToken, completion)
						return
					}
				}
			}
			completion(GQLError("Sign in failed.", 100))
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func userInfo(_ tokenType: String, _ accessToken: String, _ completion: @escaping (Error?) -> Void) {

		let url = URL(string: linkUserInfo())
		var request = URLRequest(url: url!)
		request.allHTTPHeaderFields = ["content-type": "application/x-www-form-urlencoded", "Authorization": "\(tokenType) \(accessToken)"]
		request.httpMethod = "GET"

		send(request) { response, error in
			if (error == nil) {
				if let userId = response?["sub"] as? String {
					if let email = response?["email"] as? String {
						self.saveUser(userId, email)
						completion(nil)
						return
					}
				}
			}
			completion(GQLError("Sign in failed.", 100))
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAuth0 {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func signUp(_ email: String, _ password: String, _ completion: @escaping (Error?) -> Void) {

		var body = ""
		body.append("client_id=\(clientId())")
		body.append("&connection=\(connection())")
		body.append("&email=\(email)")
		body.append("&password=\(password)")

		let url = URL(string: linkSignUp())
		var request = URLRequest(url: url!)
		request.allHTTPHeaderFields = ["content-type": "application/x-www-form-urlencoded"]
		request.httpMethod = "POST"
		request.httpBody = body.data(using: .utf8)

		send(request) { response, error in
			if (error == nil) {
				self.signIn(email, password, completion)
			} else {
				completion(GQLError("Sign up failed.", 100))
			}
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAuth0 {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func checkPassword(_ password: String, _ completion: @escaping (Error?) -> Void) {

		var body = ""
		body.append("client_id=\(clientId())")
		body.append("&client_secret=\(clientSecret())")
		body.append("&username=\(email())")
		body.append("&password=\(password)")
		body.append("&grant_type=password")
		body.append("&scope=openid")

		let url = URL(string: linkSignIn())
		var request = URLRequest(url: url!)
		request.allHTTPHeaderFields = ["content-type": "application/x-www-form-urlencoded"]
		request.httpMethod = "POST"
		request.httpBody = body.data(using: .utf8)

		send(request) { response, error in
			if (error == nil) {
				completion(nil)
			} else {
				completion(GQLError("Check password failed.", 100))
			}
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAuth0 {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func updatePassword(_ password: String, _ completion: @escaping (Error?) -> Void) {

		token { tokenType, accessToken, error in
			if (error == nil) {
				self.updatePassword(password, tokenType, accessToken, completion)
			} else {
				completion(error)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func updatePassword(_ password: String, _ tokenType: String, _ accessToken: String, _ completion: @escaping (Error?) -> Void) {

		let body = ["password": password, "connection": connection()]

		let url = URL(string: linkPassword())?.appendingPathComponent(userId())
		var request = URLRequest(url: url!)
		request.allHTTPHeaderFields = ["content-type": "application/json", "Authorization": "\(tokenType) \(accessToken)"]
		request.httpMethod = "PATCH"
		request.httpBody = try? JSONSerialization.data(withJSONObject: body)

		send(request) { response, error in
			if (error == nil) {
				completion(nil)
			} else {
				completion(GQLError("Update password failed.", 100))
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func token(completion: @escaping (String, String, Error?) -> Void) {

		var body = ""
		body.append("client_id=\(clientId())")
		body.append("&client_secret=\(clientSecret())")
		body.append("&audience=\(linkAudience())/")
		body.append("&grant_type=client_credentials")

		let url = URL(string: linkToken())
		var request = URLRequest(url: url!)
		request.allHTTPHeaderFields = ["content-type": "application/x-www-form-urlencoded"]
		request.httpMethod = "POST"
		request.httpBody = body.data(using: .utf8)

		send(request) { response, error in
			if (error == nil) {
				if let accessToken = response?["access_token"] as? String {
					if let tokenType = response?["token_type"] as? String {
						completion(tokenType, accessToken, nil)
						return
					}
				}
			}
			completion("", "", GQLError("Request token failed.", 100))
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAuth0 {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public class func signOut() {

		clearUser()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLAuth0 {

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
				completion(nil, GQLError("Auth0 request failed.", 100))
			}
		}
		task.resume()
	}
}

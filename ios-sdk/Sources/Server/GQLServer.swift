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
public typealias GQLErrorCallback = (Error?) -> Void
public typealias GQLResultCallback = ([String: Any], Error?) -> Void

//-----------------------------------------------------------------------------------------------------------------------------------------------
public class GQLServer: NSObject {

	private var link: String = ""

	private var http: GQLHTTP?
	private var apps: GQLAppSync?
	private var webs: GQLWebSocket?

	// MARK: - HTTP
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public init(HTTP linkHTTP: String, headers headersHTTP: [String: String] = [:]) {

		super.init()

		link = linkHTTP
		http = GQLHTTP(linkHTTP, headersHTTP)
	}

	// MARK: - WebSocket
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public init(WebSocket linkWebS: String, headers headersWebS: [String: String] = [:], wsprotocol: String? = nil) {

		super.init()

		link = linkWebS
		webs = GQLWebSocket(linkWebS, headersWebS, wsprotocol)
	}

	// MARK: - HTTP & WebSocket
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public init(HTTP linkHTTP: String, headers headersHTTP: [String: String] = [:],
				WebSocket linkWebS: String, headers headersWebS: [String: String] = [:], wsprotocol: String? = nil) {

		super.init()

		link = linkHTTP
		http = GQLHTTP(linkHTTP, headersHTTP)
		webs = GQLWebSocket(linkWebS, headersWebS, wsprotocol)
	}

	// MARK: - GQLite
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public init(_ linkGQLite: String) {

		super.init()

		var linkHTTP = ""
		var linkWebS = ""

		if (linkGQLite.contains("http://")) || (linkGQLite.contains("https://")) {
			if (linkGQLite.contains("http://")) {
				linkHTTP = linkGQLite
				linkWebS = linkGQLite.replacingOccurrences(of: "http://", with: "ws://")
			} else {
				linkHTTP = linkGQLite
				linkWebS = linkGQLite.replacingOccurrences(of: "https://", with: "wss://")
			}
		} else {
			fatalError("The GQLite link seems to be invalid. \(linkGQLite)")
		}

		linkHTTP += "/graphql"
		linkWebS += "/graphql"

		GQLAuth.setup(linkGQLite)

		link = linkHTTP
		http = GQLHTTP(linkHTTP, [:])
		webs = GQLWebSocket(linkWebS, [:], "graphql-transport-ws")
	}

	// MARK: - Hasura
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public init(Hasura linkHasura: String, wsprotocol: String? = nil) {

		super.init()

		setup(linkHasura, [:], wsprotocol)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public init(Hasura linkHasura: String, secret: String, wsprotocol: String? = nil) {

		super.init()

		setup(linkHasura, ["x-hasura-admin-secret": secret], wsprotocol)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public init(Hasura linkHasura: String, headers: [String: String], wsprotocol: String? = nil) {

		super.init()

		setup(linkHasura, headers, wsprotocol)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func setup(_ linkHasura: String, _ headers: [String: String], _ wsprotocol: String?) {

		var linkHTTP = ""
		var linkWebS = ""

		if (linkHasura.contains("https://")) {
			linkHTTP = linkHasura
			linkWebS = linkHasura.replacingOccurrences(of: "https://", with: "wss://")
		} else {
			fatalError("The Hasura link seems to be invalid. \(linkHasura)")
		}

		link = linkHTTP
		http = GQLHTTP(linkHTTP, headers)
		webs = GQLWebSocket(linkWebS, headers, wsprotocol)
	}

	// MARK: - AppSync
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public init(AppSync linkAppS: String, key: String) {

		super.init()

		var linkHTTP = ""
		var linkWebS = ""

		if (linkAppS.contains("https://") && linkAppS.contains(".appsync-api.")) {
			linkHTTP = linkAppS
			linkWebS = linkAppS.replacingOccurrences(of: "https://", with: "wss://")
			linkWebS = linkWebS.replacingOccurrences(of: ".appsync-api.", with: ".appsync-realtime-api.")
		}

		if (linkAppS.contains("wss://") && linkAppS.contains(".appsync-realtime-api.")) {
			linkWebS = linkAppS
			linkHTTP = linkAppS.replacingOccurrences(of: "wss://", with: "https://")
			linkHTTP = linkHTTP.replacingOccurrences(of: ".appsync-realtime-api.", with: ".appsync-api.")
		}

		if (linkHTTP.isEmpty) || (linkWebS.isEmpty) {
			fatalError("The AppSync link seems to be invalid. \(linkAppS)")
		}

		var host = linkHTTP.replacingOccurrences(of: "https://", with: "")
		host = host.replacingOccurrences(of: "/graphql", with: "")

		link = linkHTTP
		http = GQLHTTP(linkHTTP, ["x-api-key": key])
		apps = GQLAppSync(linkWebS, ["x-api-key": key, "host": host])
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	deinit {

		http = nil
		webs = nil
		apps = nil
	}

	// MARK: - Auth methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func connectAuth(_ callback: @escaping GQLErrorCallback) {

		guard let webs = webs else { fatalError("The connectAuth feature works with WebSocket connection only.") }

		GQLAuth.refresh() { auth, error in
			if (error == nil) {
				webs.connectAuth(auth, callback)
			} else {
				callback(error)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func sendAuth(_ query: String, _ variables: [String: Any], _ callback: @escaping GQLResultCallback) {

		guard let http = http else { return }

		GQLAuth.refresh() { auth, error in
			if (error == nil) {
				http.sendAuth(query, variables, auth, callback)
			} else {
				callback([:], error)
			}
		}
	}

	// MARK: - Connect methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func connect(_ callback: @escaping GQLErrorCallback) {

		if let webs = webs { webs.connect(callback); return }
		if let apps = apps { apps.connect(callback); return }

		fatalError("The subscription feature works with realtime connection only.")
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func disconnect() {

		if let webs = webs { webs.disconnect(); return }
		if let apps = apps { apps.disconnect(); return }

		fatalError("The subscription feature works with realtime connection only.")
	}

	// MARK: - Send methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func send(_ query: String, _ variables: [String: Any], _ callback: @escaping GQLResultCallback) {

		if let http = http { http.send(query, variables, callback); return }
		if let webs = webs { webs.send(query, variables, callback); return }
	}

	// MARK: - Query methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func query(_ query: String, _ variables: [String: Any], _ callback: @escaping GQLResultCallback) {

		if let http = http { http.send(query, variables, callback); return }
		if let webs = webs { webs.send(query, variables, callback); return }
	}

	// MARK: - Mutation methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func mutation(_ query: String, _ variables: [String: Any], _ callback: @escaping GQLResultCallback) {

		if let http = http { http.send(query, variables, callback); return }
		if let webs = webs { webs.send(query, variables, callback); return }
	}

	// MARK: - Subscription methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func subscription(_ query: String, _ variables: [String: Any], _ callback: @escaping GQLResultCallback) -> String {

		if let webs = webs { return webs.subscription(query, variables, callback) }
		if let apps = apps { return apps.subscription(query, variables, callback) }

		fatalError("The subscription feature works with realtime connection only.")
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func subscription(cancel callbackId: String, _ callback: @escaping GQLErrorCallback) {

		if let webs = webs { webs.subscription(cancel: callbackId, callback); return }
		if let apps = apps { apps.subscription(cancel: callbackId, callback); return }

		fatalError("The subscription feature works with realtime connection only.")
	}

	// MARK: - Helper methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func linkx() -> String {

		return link
	}
}

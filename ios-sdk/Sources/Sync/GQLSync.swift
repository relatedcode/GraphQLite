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
class GQLQueue: NSObject, GQLObject {

	@objc var objectId = ""

	@objc var link = ""
	@objc var queryName = ""
	@objc var variables = ""
	@objc var keyId = ""

	@objc var isQueued = true
	@objc var isFailed = false

	@objc var updatedAt = Date().timeIntervalSince1970

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func primaryKey() -> String {

		return "objectId"
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
public class GQLSync: NSObject {

	private var db: GQLDatabase!
	private var server: GQLServer!
	private var link: String = ""
	private var auth: Bool = false

	private var timer: Timer?
	private var updating = false

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public init(_ server: GQLServer, auth: Bool = false, interval: TimeInterval = 0.5) {

		super.init()

		db = GQLDatabase(file: "gqlsync.sqlite")

		self.server = server
		self.link = server.linkx()
		self.auth = auth

		startSync(interval)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	deinit {

		stopSync()

		db = nil
		server = nil
	}
}

// MARK: - Update methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLSync {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func startSync(_ interval: TimeInterval) {

		timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
			if (GQLNetwork.isReachable()) {
				if (self.updating == false) {
					self.updateNext()
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func stopSync() {

		timer?.invalidate()
		timer = nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func updateNext() {

		let arguments: [String: Any] = [":link": link, ":true": true, ":false": false]
		let condition = String(format: "link = :link AND isQueued = :true AND isFailed = :false")

		if let queue = GQLQueue.fetchOne(db, condition, arguments, order: "updatedAt") {
			if (auth) {
				updateAuth(queue)
			} else {
				updateBasic(queue)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func updateAuth(_ queue: GQLQueue) {

		updating = true

		let query = GQLQuery[queue.queryName]
		let variables = convert(queue.variables)

		server.sendAuth(query, variables) { [self] result, error in
			if (error == nil) {
				queue.isQueued = false
				queue.update(db)
			} else {
				GQLDebug.error(error)
			}
			updating = false
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func updateBasic(_ queue: GQLQueue) {

		updating = true

		let query = GQLQuery[queue.queryName]
		let variables = convert(queue.variables)

		server.send(query, variables) { [self] result, error in
			if (error == nil) {
				queue.isQueued = false
				queue.update(db)
			} else {
				GQLDebug.error(error)
			}
			updating = false
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLSync {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func cleanup() {

		db.cleanupDatabase()
	}
}

// MARK: - Sync methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLSync {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func lazy(_ queryName: String, _ variables: [String: Any], _ keyId: Any) {

		let queue = GQLQueue()

		queue.objectId = "\(queryName)-\(keyId)"
		queue.link = link
		queue.queryName = queryName
		queue.variables = convert(variables)
		queue.keyId = "\(keyId)"

		queue.updateInsert(db)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func steady(_ queryName: String, _ variables: [String: Any], _ keyId: Any) {

		let queue = GQLQueue()

		queue.objectId = UUID().uuidString
		queue.link = link
		queue.queryName = queryName
		queue.variables = convert(variables)
		queue.keyId = "\(keyId)"

		queue.insert(db)
	}

	// MARK - Force
	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func force(_ queryName: String, _ variables: [String: Any]) {

		if (GQLNetwork.notReachable()) { return }

		let query = GQLQuery[queryName]
		server.send(query, variables) { result, error in
			if (error != nil) {
				GQLDebug.error(error)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func forceAuth(_ queryName: String, _ variables: [String: Any]) {

		if (GQLNetwork.notReachable()) { return }

		let query = GQLQuery[queryName]
		server.sendAuth(query, variables) { result, error in
			if (error != nil) {
				GQLDebug.error(error)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func force(_ queryName: String, _ variables: [String: Any], _ callback: @escaping GQLResultCallback) {

		if (GQLNetwork.isReachable()) {
			let query = GQLQuery[queryName]
			server.send(query, variables, callback)
		} else {
			callback([:], GQLError("Network error.", 100))
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	public func forceAuth(_ queryName: String, _ variables: [String: Any], _ callback: @escaping GQLResultCallback) {

		if (GQLNetwork.isReachable()) {
			let query = GQLQuery[queryName]
			server.sendAuth(query, variables, callback)
		} else {
			callback([:], GQLError("Network error.", 100))
		}
	}
}

// MARK: - Convert methods
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension GQLSync {

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
	private func convert(_ text: String) -> [String: Any] {

		if let data = text.data(using: .utf8) {
			if let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
				return dictionary
			}
		}
		fatalError("JSONSerialization error. \(text)")
	}
}

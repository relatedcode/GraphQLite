//
// Copyright (c) 2021 Related Code - https://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import GraphQLite

//-----------------------------------------------------------------------------------------------------------------------------------------------
class ServerData: NSObject {

	private var callbackIdCreate: String?
	private var callbackIdUpdate: String?

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: ServerData = {
		let instance = ServerData()
		return instance
	} ()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func setup() {

		_ = shared
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		NotificationCenter.addObserver(self, selector: #selector(connect), name: UIApplication.didBecomeActiveNotification)
		NotificationCenter.addObserver(self, selector: #selector(disconnect), name: UIApplication.willResignActiveNotification)
		NotificationCenter.addObserver(self, selector: #selector(networkChanged), text: "GQLNetworkChanged")
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func networkChanged() {

		GQLNetwork.isReachable() ? connect() : disconnect()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func connect() {

		if (GQLNetwork.isReachable()) {
			gqlserver.connect() { error in
				if let error = error {
					print(error.localizedDescription)
				} else {
					self.initObservers()
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func disconnect() {

		stopObservers()
		DispatchQueue.main.async(after: 0.25) {
			gqlserver.disconnect()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func initObservers() {

		fetchTodos()

		if (callbackIdCreate == nil) {
			callbackIdCreate = subscribe("OnCreateTodo")
		}
		if (callbackIdUpdate == nil) {
			callbackIdUpdate = subscribe("OnUpdateTodo")
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func stopObservers() {

		if (callbackIdCreate != nil) {
			unsubscribe(callbackIdCreate)
			callbackIdCreate = nil
		}
		if (callbackIdUpdate != nil) {
			unsubscribe(callbackIdUpdate)
			callbackIdUpdate = nil
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ServerData {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func fetchTodos() {

		let query = GQLQuery["ListTodos"]
		let updatedAt = LastUpdated["Todo"]
		let variables = ["updatedAt": updatedAt]

		gqlserver.query(query, variables) { result, error in
			if let error = error {
				print(error.localizedDescription)
			} else {
				if let dictionary = result.values.first as? [String: Any] {
					if let array = dictionary["items"] as? [[String: Any]] {
						print("Todo fetch: \(array.count)")
						for values in array {
							self.updateDatabase(values)
						}
					}
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func subscribe(_ queryName: String) -> String? {

		let query = GQLQuery[queryName]

		let callbackId = gqlserver.subscription(query, [:]) { result, error in
			if let error = error {
				print(error.localizedDescription)
			} else {
				if let values = result.values.first as? [String: Any] {
					self.updateDatabase(values)
				}
			}
		}
		return callbackId
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func unsubscribe(_ callbackId: String?) {

		if let callbackId = callbackId {
			gqlserver.subscription(cancel: callbackId) { error in
				if let error = error {
					print(error.localizedDescription)
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private func updateDatabase(_ values: [String: Any]) {

		gqldb.updateInsert("Todo", values)

		LastUpdated.update("Todo", values)
	}
}

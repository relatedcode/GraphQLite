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

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func fetchTodos() {

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
	private class func updateDatabase(_ values: [String: Any]) {

		gqldb.updateInsert("Todo", values)

		LastUpdated.update("Todo", values)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ServerData {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func createTodo(_ todo: Todo) {

		let query = GQLQuery["CreateTodo"]
		let variables = ["object": todo.values()]

		gqlserver.mutation(query, variables) { result, error in
			if let error = error {
				print(error.localizedDescription)
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func updateTodo(_ todo: Todo) {

		let query = GQLQuery["UpdateTodo"]
		let variables = ["object": todo.values()]

		gqlserver.mutation(query, variables) { result, error in
			if let error = error {
				print(error.localizedDescription)
			}
		}
	}
}

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

import Foundation
import GraphQLite

//-----------------------------------------------------------------------------------------------------------------------------------------------
class ServerData: NSObject {

	static var server: GQLServer!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func setup(_ server: GQLServer) {

		self.server = server

		fetchAll()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ServerData {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func fetchAll() {

		let query = GQLQuery["GetAllData"]

		server.query(query, [:]) { result, error in
			if let error = error {
				print(error.localizedDescription)
			} else {
				if let allPeople = result["allPeople"] as? [String: Any] {
					if let people = allPeople["people"] as? [[String: Any]] {
						for values in people {
							self.updateDatabase(values)
						}
					}
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func updateDatabase(_ values: [String: Any]) {

		gqldb.updateInsert("People", values)
	}
}

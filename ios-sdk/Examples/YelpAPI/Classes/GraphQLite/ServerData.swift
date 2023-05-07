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
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func fetchObjects() {

		let query = GQLQuery["SearchRestaurants"]

		let offset = Restaurant.count(gqldb)
		let variables: [String: Any] = ["term": "Restaurants", "location": "San Francisco", "limit": 10, "offset": offset + 1]

		fetch(query, variables)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ServerData {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func fetch(_ query: String, _ variables: [String: Any]) {

		server.query(query, variables) { result, error in
			if let error = error {
				print(error.localizedDescription)
			} else {
				if let dictionary = result.values.first as? [String: Any] {
					if let array = dictionary["business"] as? [[String: Any]] {
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

		guard let restaurantId = values["id"] as? String else { return }

		if var coordinates = values["coordinates"] as? [String: Any] {
			coordinates["id"] = restaurantId
			gqldb.updateInsert(Coordinates.table(), coordinates)
		}

		if var location = values["location"] as? [String: Any] {
			location["id"] = restaurantId
			gqldb.updateInsert(Locations.table(), location)
		}

		if let reviews = values["reviews"] as? [[String: Any]] {
			for review in reviews {
				updateReview(review, restaurantId)
			}
		}

		var restaurant = values
		if let photos = values["photos"] as? [String] {
			if let photo = photos.first {
				restaurant["photo"] = photo
			}
		}
		gqldb.updateInsert("Restaurant", restaurant)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func updateReview(_ review: [String: Any], _ restaurantId: String) {

		var review = review

		review["restaurant_id"] = restaurantId

		if let user = review["user"] as? [String: Any] {
			review["user_id"] = user["id"]
			review["user_name"] = user["name"]
			review["user_profile_url"] = user["profile_url"]
			review["user_image_url"] = user["image_url"]
		}

		gqldb.updateInsert("Review", review)
	}
}

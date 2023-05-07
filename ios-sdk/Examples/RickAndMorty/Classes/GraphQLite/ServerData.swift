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
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ServerData {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func characters(_ page: Int) {

		let query = GQLQuery["GetCharacters"]
		let variables: [String: Any] = ["page": page]

		fetch(query, variables)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ServerData {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func fetch(_ query: String, _ variables: [String: Any]) {

		server.query(query, variables) { [self] result, error in
			if let error = error {
				print(error.localizedDescription)
			} else {
				if let characters = result["characters"] as? [String: Any] {
					if let results = characters["results"] as? [[String: Any]] {
						for values in results {
							updateDatabase(values)
						}
					}
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func updateDatabase(_ values: [String: Any]) {

		let character = Character.create(values)

		if let origin = values["origin"] as? [String: Any] {
			gqldb.updateInsert("Origin", origin)
			if let originId = origin["id"] as? String {
				character.originId = originId
			}
		}

		if let location = values["location"] as? [String: Any] {
			gqldb.updateInsert("Location", location)
			if let locationId = location["id"] as? String {
				character.locationId = locationId
			}
		}

		if let episodes = values["episode"] as? [[String: Any]] {
			var episodesIds: [String] = []
			for episode in episodes {
				gqldb.updateInsert("Episode", episode)
				if let episodeId = episode["id"] as? String {
					episodesIds.append(episodeId)
				}
			}
			character.episodeIds = episodesIds.joined(separator: ", ")
		}

		character.updateInsert(gqldb)
	}
}

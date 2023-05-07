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
var gqldb: GQLDatabase!
var gqlserver: GQLServer!

//-----------------------------------------------------------------------------------------------------------------------------------------------
class GraphQLite: NSObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func setup() {

		GQLNetwork.setup()

		gqldb = GQLDatabase()

		#warning("Please add your AWS AppSync API details below.")
		// Some more info -> https://graphqlite.io/simple-todo-server-configuration

		let key = "..."
		let link = "..."
		gqlserver = GQLServer(AppSync: link, key: key)

		ServerData.setup()
	}
}

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

//-----------------------------------------------------------------------------------------------------------------------------------------------
class GraphQLite: NSObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func setup() {

		initDatabase()
		initServer()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func initDatabase() {

		gqldb = GQLDatabase()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func initServer() {

		let link = "https://rickandmortyapi.com/graphql"

		let server = GQLServer(HTTP: link)

		ServerData.setup(server)
	}
}

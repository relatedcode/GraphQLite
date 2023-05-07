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
class Locations: NSObject, GQLObject {

	@objc var id = ""
	@objc var address1 = ""
	@objc var address2 = ""
	@objc var address3 = ""
	@objc var city = ""
	@objc var state = ""
	@objc var postal_code = ""
	@objc var country = ""
	@objc var formatted_address = ""

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static func primaryKey() -> String {

		return "id"
	}
}

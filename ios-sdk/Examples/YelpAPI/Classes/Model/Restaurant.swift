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
class Restaurant: NSObject, GQLObject {

	@objc var id = ""
	@objc var name = ""
	@objc var alias = ""
	@objc var rating = 0.0
	@objc var url = ""
	@objc var is_claimed = false
	@objc var is_closed = false
	@objc var phone = ""
	@objc var display_phone = ""
	@objc var review_count = 0
	@objc var price = ""
	@objc var distance = 0.0
	@objc var photo = ""

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func primaryKey() -> String {

		return "id"
	}
}

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
class Review: NSObject, GQLObject {

	@objc var id = ""
	@objc var rating = 0.0
	@objc var text = ""
	@objc var time_created = ""
	@objc var url = ""

	@objc var restaurant_id = ""

	@objc var user_id = ""
	@objc var user_name = ""
	@objc var user_profile_url = ""
	@objc var user_image_url = ""

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func primaryKey() -> String {

		return "id"
	}
}

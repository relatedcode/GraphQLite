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
class People: NSObject, GQLObject {

	@objc var id = ""
	@objc var name = ""
	@objc var gender = ""
	@objc var birthYear = ""
	@objc var eyeColor = ""
	@objc var hairColor = ""
	@objc var height = 0
	@objc var mass = 0
	@objc var skinColor = ""
	@objc var created = ""
	@objc var edited = ""

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static func primaryKey() -> String {

		return "id"
	}
}

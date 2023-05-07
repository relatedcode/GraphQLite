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
class Currency: NSObject, GQLObject {

	@objc var baseCurrency = ""
	@objc var quoteCurrency = ""

	@objc var quote = 0.0
	@objc var date = ""

	@objc var countryCode = ""
	@objc var countryName = ""
	@objc var countryFlag = ""

	@objc var currencyCode = ""
	@objc var currencyName = ""
	@objc var currencySymbol = ""

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static func primaryKey() -> String {

		return "countryCode"
	}
}

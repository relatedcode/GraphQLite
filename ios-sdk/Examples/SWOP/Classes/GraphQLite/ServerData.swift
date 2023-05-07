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

		fetchLatest()
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ServerData {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func fetchLatest() {

		let query = GQLQuery["GetLatestUpdate"]

		server.query(query, [:]) { result, error in
			if let error = error {
				print(error.localizedDescription)
			} else {
				if let latest = result["latest"] as? [[String: Any]] {
					updateDatabase(latest)
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func updateDatabase(_ latest: [[String: Any]]) {

		for countryCode in Locale.isoRegionCodes {

			let country = country(countryCode)
			let currency = currency(countryCode)

			for values in latest {
				if (values["quoteCurrency"] as? String == currency.code) {
					var values = values

					values["countryCode"] = country.code
					values["countryName"] = country.name
					values["countryFlag"] = country.flag

					values["currencyCode"] = currency.code
					values["currencyName"] = currency.name
					values["currencySymbol"] = currency.symbol

					gqldb.updateInsert("Currency", values)
				}
			}
		}
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ServerData {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func country(_ countryCode: String) -> (code: String, name: String, flag: String) {

		let countryId = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: countryCode])

		let countryName = NSLocale(localeIdentifier: "en").displayName(forKey: .identifier, value: countryId) ?? ""
		let countryFlag = countryCode.unicodeScalars.map({ 127397 + $0.value }).compactMap(UnicodeScalar.init).map(String.init).joined()

		return (countryCode, countryName, countryFlag)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	private class func currency(_ countryCode: String) -> (code: String, name: String, symbol: String) {

		let countryId = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: countryCode])

		let currencyCode = Locale(identifier: countryId).currencyCode ?? ""
		let currencyName = NSLocale(localeIdentifier: "en").displayName(forKey: .currencyCode, value: currencyCode) ?? ""
		let currencySymbol = Locale(identifier: countryId).currencySymbol ?? ""

		return (currencyCode, currencyName, currencySymbol)
	}
}

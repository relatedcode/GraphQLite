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

import UIKit

//-----------------------------------------------------------------------------------------------------------------------------------------------
class BaseCell: UITableViewCell {

	@IBOutlet var viewBackground: UIView!
	@IBOutlet var labelFlag: UILabel!
	@IBOutlet var labelCurrencyCode: UILabel!
	@IBOutlet var labelCountryName: UILabel!
	@IBOutlet var labelCurrencyRate: UILabel!
	@IBOutlet var labelCurrencyInfo: UILabel!
	@IBOutlet var labelCurrencySymbol: UILabel!
	@IBOutlet var fieldAmount: UITextField!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func setData(_ currency: Currency, _ baseCurrency: Currency, _ amount: Double) {

		let isSelectedBase = (currency.countryCode == baseCurrency.countryCode)

		viewBackground.layer.borderWidth = isSelectedBase ? 1 : 0
		viewBackground.layer.borderColor = UIColor.label.cgColor
		viewBackground.layer.cornerRadius = 10

		let rate = currency.quote / baseCurrency.quote

		labelFlag.text = currency.countryFlag
		labelCurrencyCode.text = currency.currencyCode
		labelCountryName.text = currency.countryName
		labelCurrencyRate.text = String(format: "%@ %.2f", currency.currencySymbol, rate * amount)
		labelCurrencyInfo.text = String(format: "1 %@ = %.4f %@", baseCurrency.quoteCurrency, rate, currency.quoteCurrency)

		labelCurrencySymbol.text = currency.currencySymbol
		fieldAmount.text = String(format: "%.2f", amount)

		fieldAmount.isHidden = !isSelectedBase
		labelCurrencyInfo.isHidden = isSelectedBase
		labelCurrencyRate.isHidden = isSelectedBase
		labelCurrencySymbol.isHidden = !isSelectedBase
	}
}

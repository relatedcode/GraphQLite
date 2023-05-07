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
@objc protocol CurrenciesDelegate: AnyObject {

	func didSelectCurrency(_ currencies: [Currency])
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
class CurrenciesView: UIViewController {

	@IBOutlet weak var delegate: CurrenciesDelegate?

	@IBOutlet var searchBar: UISearchBar!
	@IBOutlet var tableView: UITableView!

	private var currencies: [Currency] = []
	private var selection: [Currency] = []

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ selection: [Currency]) {

		super.init(nibName: nil, bundle: nil)

		self.selection = selection
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder: NSCoder) {

		super.init(coder: coder)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

        super.viewDidLoad()
		title = "Currencies"

		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(actionCancel))
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(actionDone))

		tableView.register(UINib(nibName: "CurrenciesCell", bundle: nil), forCellReuseIdentifier: "CurrenciesCell")

		loadCurrencies()
    }

	// MARK: - Load methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func loadCurrencies() {

		let text = searchBar.text ?? ""

		let arguments: [String: Any] = [":text": "%%\(text)%%"]
		let condition = "currencyCode LIKE :text OR currencyName LIKE :text OR countryCode LIKE :text OR countryName LIKE :text"

		currencies = Currency.fetchAll(gqldb, condition, arguments, order: "countryCode ASC")

		tableView.reloadData()
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCancel() {

		dismiss(animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDone() {

		if (selection.count > 0) {
			delegate?.didSelectCurrency(selection)
		}
		dismiss(animated: true)
	}

	// MARK: - Helper methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func isSelected(_ currency: Currency) -> Bool {

		for temp in selection {
			if (temp.countryCode == currency.countryCode) {
				return true
			}
		}
		return false
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension CurrenciesView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return currencies.count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "CurrenciesCell", for: indexPath) as! CurrenciesCell

		let currency = currencies[indexPath.section]
		cell.setData(currency)
		cell.accessoryType = isSelected(currency) ? .checkmark : .none

		return cell
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension CurrenciesView: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

		return (section == 0) ? 10 : 5
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

		return (section == currencies.count-1) ? 10 : 5
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

		return 50
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		let currency = currencies[indexPath.section]

		if (isSelected(currency)) {
			selection = selection.filter { $0.countryCode != currency.countryCode }
		} else {
			selection.append(currency)
		}

		if let cell = tableView.cellForRow(at: indexPath) {
			cell.accessoryType = isSelected(currency) ? .checkmark : .none
		}
	}
}

// MARK: - UISearchBarDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension CurrenciesView: UISearchBarDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

		loadCurrencies()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

		searchBar.setShowsCancelButton(true, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {

		searchBar.setShowsCancelButton(false, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

		searchBar.text = ""
		searchBar.resignFirstResponder()
		loadCurrencies()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

		searchBar.resignFirstResponder()
	}
}

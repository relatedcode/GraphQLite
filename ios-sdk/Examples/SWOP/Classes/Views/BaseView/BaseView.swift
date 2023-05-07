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
import GraphQLite

//-----------------------------------------------------------------------------------------------------------------------------------------------
class BaseView: UITableViewController {

	@IBOutlet var cellAddCurrency: UITableViewCell!

	private var currencies: [Currency] = []
	private var baseCurrency: Currency!

	private var observerId: String?
	private var amount = 100.0

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "SWOP"

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(actionRefresh))

		tableView.register(UINib(nibName: "BaseCell", bundle: nil), forCellReuseIdentifier: "BaseCell")
		tableView.tableFooterView = UIView()

		loadCurrencies()
		createObserver()
	}

	// MARK: - Database methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadCurrencies() {

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
			if let currency = Currency.fetchOne(gqldb, "countryCode = ?", ["US"]) { currencies.append(currency) }
			if let currency = Currency.fetchOne(gqldb, "countryCode = ?", ["CA"]) { currencies.append(currency) }
			if let currency = Currency.fetchOne(gqldb, "countryCode = ?", ["GB"]) { currencies.append(currency) }
			if let currency = Currency.fetchOne(gqldb, "countryCode = ?", ["JP"]) { currencies.append(currency) }
			baseCurrency = currencies.first
			tableView.reloadData()
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func createObserver() {

		let types: [GQLObserverType] = [.insert, .update]

		observerId = Currency.createObserver(gqldb, types) { method, objectId in
			DispatchQueue.main.async { [self] in
				if (method == "UPDATE") { refreshUpdate(objectId) }
			}
		}
	}

	// MARK: - Database methods (refresh)
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func refreshUpdate(_ objectId: Any) {

		if let object = Currency.fetchOne(gqldb, key: objectId) {
			if let index = indexOf(objectId) {
				currencies[index] = object
				tableView.reloadData()
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func indexOf(_ objectId: Any) -> Int? {

		for (index, object) in currencies.enumerated() {
			if (object.countryCode == objectId as! String) {
				return index
			}
		}
		return nil
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionRefresh() {

		ServerData.fetchLatest()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionCurrencies() {

		let currenciesView = CurrenciesView(currencies)
		currenciesView.delegate = self
		let navController = UINavigationController(rootViewController: currenciesView)
		present(navController, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionAmount() {

		let alert = UIAlertController(title: "Enter new value", message: nil, preferredStyle: .alert)

		alert.addTextField(configurationHandler: { [self] textField in
			textField.text = String(amount)
			textField.placeholder = "0.0"
			textField.autocapitalizationType = .words
		})

		alert.addAction(UIAlertAction(title: "Save", style: .default) { [self] action in
			if let textField = alert.textFields?[0] {
				if let text = textField.text {
					amount = Double(text) ?? 1.0
					tableView.reloadData()
				}
			}
		})

		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

		present(alert, animated: true)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionSelect(_ indexPath: IndexPath) {

		baseCurrency = currencies[indexPath.section]

		reloadSection(at: indexPath)
		reloadSections(but: indexPath)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func reloadSection(at indexPath: IndexPath) {

		let currency = currencies[indexPath.section]
		if let cell = tableView.cellForRow(at: indexPath) as? BaseCell {
			cell.setData(currency, baseCurrency, amount)
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func reloadSections(but indexPath: IndexPath) {

		var array: [Int] = []

		for section in 0..<tableView.numberOfSections-1 {
			if (section != indexPath.section) {
				array.append(section)
			}
		}

		tableView.reloadSections(IndexSet(array), with: .fade)
	}
}

//-----------------------------------------------------------------------------------------------------------------------------------------------
extension BaseView: CurrenciesDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func didSelectCurrency(_ currencies: [Currency]) {

		self.currencies = currencies

		baseCurrency = currencies.first

		tableView.reloadData()
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension BaseView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func numberOfSections(in tableView: UITableView) -> Int {

		return currencies.count + 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == currencies.count) { return cellAddCurrency }

		let cell = tableView.dequeueReusableCell(withIdentifier: "BaseCell", for: indexPath) as! BaseCell

		let currency = currencies[indexPath.section]
		cell.setData(currency, baseCurrency, amount)

		return cell
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension BaseView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

		return (section == 0) ? 10 : 5
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

		return 5
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

		return 60
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

		return (indexPath.section != currencies.count)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

		if (editingStyle != .delete) { return }

		let currency = currencies[indexPath.section]
		currencies.remove(at: indexPath.section)

		tableView.performBatchUpdates {
			let indexSet = IndexSet([indexPath.section])
			tableView.deleteSections(indexSet, with: .automatic)
		} completion: { [self] finished in
			if (baseCurrency == currency) {
				baseCurrency = currencies.first
				tableView.reloadData()
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		if (indexPath.section == currencies.count) {
			actionCurrencies()
			return
		}

		if (currencies[indexPath.section] != baseCurrency) {
			actionSelect(indexPath)
		} else {
			actionAmount()
		}
	}
}

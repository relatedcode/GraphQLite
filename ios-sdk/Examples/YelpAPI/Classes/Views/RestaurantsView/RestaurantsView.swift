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
class RestaurantsView: UITableViewController {

	@IBOutlet var viewFooter: UIView!
	@IBOutlet var buttonMore: UIButton!
	@IBOutlet var activityLoading: UIActivityIndicatorView!

	private var restaurants: [Restaurant] = []
	private var observerId: String?

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Restaurants"

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)

		tableView.register(UINib(nibName: "RestaurantsCell", bundle: Bundle.main), forCellReuseIdentifier: "RestaurantsCell")

		tableView.tableFooterView = viewFooter

		loadRestaurants()
		createObserver()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)

		if (Restaurant.count(gqldb) == 0) {
			actionLoadMore(0)
		}
	}

	// MARK: - Database methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadRestaurants() {

		restaurants = Restaurant.fetchAll(gqldb)
		refreshTableView()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func createObserver() {

		let types: [GQLObserverType] = [.insert, .update]

		observerId = Restaurant.createObserver(gqldb, types) { [self] (method, objectId) in
			if (method == "INSERT") { refreshInsert(objectId) }
			if (method == "UPDATE") { refreshUpdate(objectId) }
		}
	}

	// MARK: - Database methods (refresh)
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func refreshInsert(_ objectId: Any) {

		if let object = Restaurant.fetchOne(gqldb, key: objectId) {
			DispatchQueue.main.async { [self] in
				restaurants.append(object)
				refreshTableView()
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func refreshUpdate(_ objectId: Any) {

		if let object = Restaurant.fetchOne(gqldb, key: objectId) {
			let index = indexOf(objectId)
			DispatchQueue.main.async { [self] in
				if let index = index {
					restaurants[index] = object
					refreshTableView()
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func indexOf(_ objectId: Any) -> Int? {

		for (index, object) in restaurants.enumerated() {
			if (object.id == objectId as! String) {
				return index
			}
		}
		return nil
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func refreshTableView() {

		tableView.reloadData()

		buttonMore.isHidden = false
		activityLoading.isHidden = true
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionLoadMore(_ sender: Any) {

		ServerData.fetchObjects()

		buttonMore.isHidden = true
		activityLoading.isHidden = false
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RestaurantsView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func numberOfSections(in tableView: UITableView) -> Int {

		return restaurants.count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantsCell", for: indexPath) as! RestaurantsCell

		let restaurant = restaurants[indexPath.section]
		cell.setData(for: restaurant)

		return cell
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RestaurantsView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

		return (section == 0) ? 10 : 5
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

		return (section == restaurants.count-1) ? 10 :  5
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

		return 110
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		let restaurant = restaurants[indexPath.section]
		let restaurantsDetailsView = RestaurantView(restaurant)
		navigationController?.pushViewController(restaurantsDetailsView, animated: true)
	}
}

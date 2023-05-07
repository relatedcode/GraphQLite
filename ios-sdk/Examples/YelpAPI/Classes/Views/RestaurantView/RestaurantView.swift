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
import MapKit

//-----------------------------------------------------------------------------------------------------------------------------------------------
class RestaurantView: UITableViewController {

	@IBOutlet var cellRestaurantInfo: UITableViewCell!
	@IBOutlet var cellLocation: UITableViewCell!
	@IBOutlet var cellRating: UITableViewCell!
	@IBOutlet var cellPhone: UITableViewCell!

	@IBOutlet var imageView: UIImageView!
	@IBOutlet var labelPrice: UILabel!
	@IBOutlet var labelName: UILabel!
	@IBOutlet var labelClaimed: UILabel!
	@IBOutlet var labelClosed: UILabel!
	@IBOutlet var labelRating: UILabel!
	@IBOutlet var labelReviewCount: UILabel!
	@IBOutlet var labelPhone: UILabel!
	@IBOutlet var labelAddress: UILabel!
	@IBOutlet var mapView: MKMapView!

	private var restaurant: Restaurant!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ restaurant: Restaurant) {

		super.init(nibName: nil, bundle: nil)

		self.restaurant = restaurant
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder: NSCoder) {

		super.init(coder: coder)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionShare(_:)))

		loadData()
	}

	// MARK: - Private methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadData() {

		title = restaurant.name

		imageView.kf.setImage(with: URL(string: restaurant.photo))

		labelPrice.text = restaurant.price
		labelName.text = restaurant.name
		labelClaimed.text = restaurant.is_claimed ? "Claimed" : "Unclaimed"

		labelClosed.text = restaurant.is_closed ? "Closed" : "Opened"
		labelClosed.textColor = restaurant.is_closed ? UIColor.systemRed : UIColor.systemGreen

		labelRating.text = "\(restaurant.rating)"
		labelReviewCount.text = "\(restaurant.review_count) Reviews"
		labelPhone.text = restaurant.display_phone

		if let location = Locations.fetchOne(gqldb, key: restaurant.id) {
			labelAddress.text = String(format: "%@ %@", location.address1, location.city)
		}

		if let coordinates = Coordinates.fetchOne(gqldb, key: restaurant.id) {
			let annotation = MKPointAnnotation()
			annotation.title = restaurant.name
			annotation.coordinate = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
			mapView.addAnnotation(annotation)

			let region = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
			mapView.setRegion(region, animated: true)
		}
	}

	// MARK: - IBAction
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionShare(_ sender: UIBarButtonItem) {

		let content = restaurant.name + "\nView More Details on:\n" + restaurant.url
		let controller = UIActivityViewController(activityItems: [content], applicationActivities: [])
		present(controller, animated: true)
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RestaurantView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func numberOfSections(in tableView: UITableView) -> Int {

		return 4
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == 0 && indexPath.row == 0) { return cellRestaurantInfo	}
		if (indexPath.section == 1 && indexPath.row == 0) { return cellLocation			}
		if (indexPath.section == 2 && indexPath.row == 0) { return cellRating			}
		if (indexPath.section == 3 && indexPath.row == 0) { return cellPhone			}

		return UITableViewCell()
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension RestaurantView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

		return (section == 0) ? 10 : 5
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

		return (section == 3) ? 10 :  5
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

		if (indexPath.section == 0) && (indexPath.row == 0) { return 420 }
		if (indexPath.section == 1) && (indexPath.row == 0) { return 225 }
		if (indexPath.section == 2) && (indexPath.row == 0) { return 50	 }
		if (indexPath.section == 3) && (indexPath.row == 0) { return 50	 }

		return 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		if (indexPath.section == 1) && (indexPath.row == 0) {
			let mapView = MapView(restaurant: restaurant)
			let navController = UINavigationController(rootViewController: mapView)
			present(navController, animated: true)
		}

		if (indexPath.section == 2) && (indexPath.row == 0) {
			let reviewsView = ReviewsView(restaurant: restaurant)
			navigationController?.pushViewController(reviewsView, animated: true)
		}

		if (indexPath.section == 3) && (indexPath.row == 0) {
			if let url = URL(string: "tel://\(restaurant.phone)") {
				UIApplication.shared.open(url)
			}
		}
	}
}

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

import MapKit

//-----------------------------------------------------------------------------------------------------------------------------------------------
class MapView: UIViewController {

	@IBOutlet private var mapView: MKMapView!

	private var restaurant: Restaurant!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(restaurant: Restaurant) {

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
		title = restaurant.name

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(actionDismiss))
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		guard let coordinates = Coordinates.fetchOne(gqldb, key: restaurant.id) else { return }

		let coordinate = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)

		var region: MKCoordinateRegion = MKCoordinateRegion()
		region.center = coordinate
		region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
		mapView.setRegion(region, animated: true)

		let annotation = MKPointAnnotation()
		annotation.title = restaurant.name
		annotation.coordinate = coordinate
		mapView.addAnnotation(annotation)
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDismiss() {

		dismiss(animated: true)
	}
}

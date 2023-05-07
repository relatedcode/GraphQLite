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
import Kingfisher

//-----------------------------------------------------------------------------------------------------------------------------------------------
class RestaurantsCell: UITableViewCell {

	@IBOutlet var imageRestaurant: UIImageView!
	@IBOutlet var labelName: UILabel!
	@IBOutlet var labelInfo: UILabel!
	@IBOutlet var viewRate: UIView!
	@IBOutlet var labelRate: UILabel!
	@IBOutlet var viewDistance: UIView!
	@IBOutlet var labelDistance: UILabel!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func awakeFromNib() {

		super.awakeFromNib()

		viewRate.layer.borderWidth = 1
		viewRate.layer.borderColor = UIColor.tertiarySystemFill.cgColor

		viewDistance.layer.borderWidth = 1
		viewDistance.layer.borderColor = UIColor.tertiarySystemFill.cgColor
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func setData(for restaurant: Restaurant) {

		imageRestaurant.kf.setImage(with: URL(string: restaurant.photo))

		labelName.text = restaurant.name

		if let location = Locations.fetchOne(gqldb, key: restaurant.id) {
			labelInfo.text = String(format: "%@ %@", location.address1, location.city)
		}

		labelRate.text = "\(restaurant.rating)"
		labelDistance.text = String(format: "%0.2f km", restaurant.distance/1000)
	}
}

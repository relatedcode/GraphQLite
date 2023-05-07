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
class ReviewsCell: UITableViewCell {

	@IBOutlet var imageUser: UIImageView!
	@IBOutlet var labelName: UILabel!
	@IBOutlet var viewRate: RatingView!
	@IBOutlet var labelComment: UILabel!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func setData(for review: Review, for tableView: UITableView) {

		imageUser.kf.setImage(with: URL(string: review.user_image_url))
		imageUser.layer.cornerRadius = imageUser.frame.size.height/2

		labelName.text = review.user_name
		viewRate.rating = Float(review.rating)
		labelComment.text = review.text
	}
}

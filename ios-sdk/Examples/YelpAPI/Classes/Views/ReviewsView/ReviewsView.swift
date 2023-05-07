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
class ReviewsView: UITableViewController {

	private var reviews: [Review] = []
	private var observerId: String?
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
		title = "Reviews"

		tableView.register(UINib(nibName: "ReviewsCell", bundle: Bundle.main), forCellReuseIdentifier: "ReviewsCell")

		loadReviews()
	}

	// MARK: - Database methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadReviews() {

		reviews = Review.fetchAll(gqldb, "restaurant_id = ?", [restaurant.id])
		tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ReviewsView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func numberOfSections(in tableView: UITableView) -> Int {

		return reviews.count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewsCell", for: indexPath) as! ReviewsCell

		let review = reviews[indexPath.section]
		cell.setData(for: review, for: tableView)

		return cell
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension ReviewsView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

		return (section == 0) ? 10 : 5
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

		return (section == reviews.count-1) ? 10 :  5
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

		return 150
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)
	}
}

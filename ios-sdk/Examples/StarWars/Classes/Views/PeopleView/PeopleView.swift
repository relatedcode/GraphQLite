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
class PeopleView: UITableViewController {

	@IBOutlet var cellProfile: UITableViewCell!
	@IBOutlet var cellGender: UITableViewCell!
	@IBOutlet var cellEyeColor: UITableViewCell!
	@IBOutlet var cellHairColor: UITableViewCell!
	@IBOutlet var cellSkinColor: UITableViewCell!
	@IBOutlet var cellHeight: UITableViewCell!
	@IBOutlet var cellMass: UITableViewCell!

	@IBOutlet var imageView: UIImageView!
	@IBOutlet var labelAvatar: UILabel!
	@IBOutlet var labelName: UILabel!

	private var people: People!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ people: People) {

		super.init(nibName: nil, bundle: nil)

		self.people = people
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder: NSCoder) {

		super.init(coder: coder)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = people.name

		imageView.layer.cornerRadius = imageView.frame.size.height / 2

		loadData()
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadData() {

		if let character = people.name.first {
			labelAvatar.text = String(character)
		}
		labelName.text = people.name

		cellGender.detailTextLabel?.text = people.gender
		cellEyeColor.detailTextLabel?.text = people.eyeColor
		cellHairColor.detailTextLabel?.text = people.hairColor
		cellSkinColor.detailTextLabel?.text = people.skinColor
		cellHeight.detailTextLabel?.text = "\(people.height) cm"
		cellMass.detailTextLabel?.text = "\(people.mass) kg"
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PeopleView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func numberOfSections(in tableView: UITableView) -> Int {

		return 4
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if (section == 0) { return 1 }
		if (section == 1) { return 1 }
		if (section == 2) { return 3 }
		if (section == 3) { return 2 }

		return 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == 0 && indexPath.row == 0) { return cellProfile		}
		if (indexPath.section == 1 && indexPath.row == 0) { return cellGender		}
		if (indexPath.section == 2 && indexPath.row == 0) { return cellEyeColor		}
		if (indexPath.section == 2 && indexPath.row == 1) { return cellHairColor	}
		if (indexPath.section == 2 && indexPath.row == 2) { return cellSkinColor	}
		if (indexPath.section == 3 && indexPath.row == 0) { return cellHeight		}
		if (indexPath.section == 3 && indexPath.row == 1) { return cellMass			}

		return UITableViewCell()
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension PeopleView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

		if (indexPath.section == 0) { return 175 }

		return 50
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)
	}
}

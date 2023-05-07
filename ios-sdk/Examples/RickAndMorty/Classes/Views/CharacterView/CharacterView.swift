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
import Kingfisher

//-----------------------------------------------------------------------------------------------------------------------------------------------
class CharacterView: UIViewController {

	@IBOutlet var tableView: UITableView!

	@IBOutlet var viewHeader: UIView!
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var labelName: UILabel!

	@IBOutlet var cellStatus: UITableViewCell!
	@IBOutlet var cellSpecies: UITableViewCell!
	@IBOutlet var cellType: UITableViewCell!
	@IBOutlet var cellGender: UITableViewCell!

	@IBOutlet var cellOrigin: UITableViewCell!
	@IBOutlet var cellLocation: UITableViewCell!

	@IBOutlet var cellEpisodes: UITableViewCell!

	private var character: Character!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	init(_ character: Character) {

		super.init(nibName: nil, bundle: nil)

		self.character = character
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder: NSCoder) {

		super.init(coder: coder)
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {
		
        super.viewDidLoad()
		title = character.name

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)

		tableView.tableHeaderView = viewHeader

		loadData()
	}

	// MARK: - Load methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadData() {

		imageView.kf.setImage(with: URL(string: character.image))

		labelName.text = character.name

		cellStatus.detailTextLabel?.text = character.status
		cellSpecies.detailTextLabel?.text = character.species
		if (!character.type.isEmpty) {
			cellType.detailTextLabel?.text = character.type
		}
		cellGender.detailTextLabel?.text = character.gender

		if let origin = Origin.fetchOne(gqldb, key: character.originId) {
			cellOrigin.detailTextLabel?.text = origin.name
		}

		if let location = Location.fetchOne(gqldb, key: character.locationId) {
			cellLocation.detailTextLabel?.text = location.name
		}
	}

	// MARK: - User actions
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func actionEpisodes() {

		var episodes: [Episode] = []

		for episodeId in character.episodeIds.components(separatedBy: ", ") {
			if let episode = Episode.fetchOne(gqldb, key: episodeId) {
				episodes.append(episode)
			}
		}

		let episodesView = EpisodesView(episodes)
		navigationController?.pushViewController(episodesView, animated: true)
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension CharacterView: UITableViewDataSource {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 3
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if (section == 0) { return 4 }
		if (section == 1) { return 2 }
		if (section == 2) { return 1 }

		return 0
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == 0 && indexPath.row == 0) { return cellStatus	}
		if (indexPath.section == 0 && indexPath.row == 1) { return cellSpecies	}
		if (indexPath.section == 0 && indexPath.row == 2) { return cellType		}
		if (indexPath.section == 0 && indexPath.row == 3) { return cellGender	}
		if (indexPath.section == 1 && indexPath.row == 0) { return cellOrigin	}
		if (indexPath.section == 1 && indexPath.row == 1) { return cellLocation	}
		if (indexPath.section == 2 && indexPath.row == 0) { return cellEpisodes	}

		return UITableViewCell()
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension CharacterView: UITableViewDelegate {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

		if (indexPath.section == 1) { return 70 }

		return 50
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		if (indexPath.section == 2) { actionEpisodes() }
	}
}

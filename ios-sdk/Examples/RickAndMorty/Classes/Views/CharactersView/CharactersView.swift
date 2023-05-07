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
class CharactersView: UITableViewController {

	private var characters: [Character] = []
	private var observerId: String?
	private var pages: [Int] = []

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

        super.viewDidLoad()
		title = "Rick And Morty"

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)

		tableView.register(UINib(nibName: "CharactersCell", bundle: nil), forCellReuseIdentifier: "CharactersCell")

		fetchCharacters()
		loadObjects()
		createObserver()
    }

	// MARK: - Server methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func fetchCharacters() {

		let page = (characters.count/20)+1
		if (pages.contains(page) == false) {
			ServerData.characters(page)
			pages.append(page)
		}
	}

	// MARK: - Database methods
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func loadObjects() {

		characters = Character.fetchAll(gqldb, order: "created")
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func createObserver() {

		let types: [GQLObserverType] = [.insert, .update]

		observerId = Character.createObserver(gqldb, types) { [self] method, objectId in
			if (method == "INSERT") { refreshInsert(objectId) }
			if (method == "UPDATE") { refreshUpdate(objectId) }
		}
	}

	// MARK: - Database methods (refresh)
	//-------------------------------------------------------------------------------------------------------------------------------------------
	func refreshInsert(_ objectId: Any) {

		if let object = Character.fetchOne(gqldb, key: objectId) {
			DispatchQueue.main.async { [self] in
				characters.append(object)
				tableView.reloadData()
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func refreshUpdate(_ objectId: Any) {

		if let object = Character.fetchOne(gqldb, key: objectId) {
			if let index = indexOf(objectId) {
				DispatchQueue.main.async { [self] in
					characters[index] = object
					tableView.reloadData()
				}
			}
		}
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func indexOf(_ objectId: Any) -> Int? {

		for (index, object) in characters.enumerated() {
			if (object.id == objectId as! String) {
				return index
			}
		}
		return nil
	}
}

// MARK: - UITableViewDataSource
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension CharactersView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func numberOfSections(in tableView: UITableView) -> Int {

		return characters.count
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return 1
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "CharactersCell", for: indexPath) as! CharactersCell

		let character = characters[indexPath.section]
		cell.setData(character)

		if (indexPath.section == characters.count - 1) {
			fetchCharacters()
		}

		return cell
	}
}

// MARK: - UITableViewDelegate
//-----------------------------------------------------------------------------------------------------------------------------------------------
extension CharactersView {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

		return (section == 0) ? 10 : 5
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

		return (section == characters.count-1) ? 10 :  5
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

		return 90
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		let character = characters[indexPath.section]
		let characterView = CharacterView(character)
		navigationController?.pushViewController(characterView, animated: true)
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

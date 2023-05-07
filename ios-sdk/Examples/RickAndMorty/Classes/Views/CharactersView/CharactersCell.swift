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
class CharactersCell: UITableViewCell {

	@IBOutlet var imageCharacter: UIImageView!
	@IBOutlet var labelName: UILabel!
	@IBOutlet var labelSpecies: UILabel!
	@IBOutlet var labelGender: UILabel!

	//-------------------------------------------------------------------------------------------------------------------------------------------
	func setData(_ character: Character) {

		imageCharacter.kf.setImage(with: URL(string: character.image))

		labelName.text = character.name
		labelSpecies.text = character.species
		labelGender.text = character.gender
	}
}

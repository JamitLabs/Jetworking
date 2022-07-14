// Copyright © 2022 Jamit Labs GmbH. All rights reserved.

import UIKit

protocol MainViewControllerDelegate: AnyObject {
    // TODO: not yet implemented
}

final class MainViewController: UIViewController {
    weak var delegate: MainViewControllerDelegate?

    @IBOutlet private var titleLabel: UILabel!
}

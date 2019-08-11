//
//  ShowPinsViewController.swift
//  360iDev AR Navigation
//
//  Created by Eric Internicola on 8/11/19.
//  Copyright © 2019 Eric Internicola. All rights reserved.
//

import ARCL
import Cartography
import CoreLocation
import UIKit

class ShowPinsViewController: UIViewController {

    let sceneLocationView = SceneLocationView()
    let activityView = UIActivityIndicatorView(style: .whiteLarge)

    var currentLocation: CLLocation? {
        return sceneLocationView.sceneLocationManager.currentLocation
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(sceneLocationView)
        view.addSubview(activityView)

        constrain(view, sceneLocationView, activityView) { view, sceneLocationView, activityView in
            sceneLocationView.left == view.left
            sceneLocationView.top == view.top
            sceneLocationView.right == view.right
            sceneLocationView.bottom == view.bottom

            activityView.centerX == view.centerX
            activityView.centerY == view.centerY
        }

        showActivityControl()
        addPins()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneLocationView.run()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneLocationView.pause()
    }

    /// Adds the pins to the ARCL Scene
    func addPins() {
        guard let currentLocation = currentLocation,
            currentLocation.horizontalAccuracy < 15 else {
                return DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.addPins()
                }
        }

        hideActivityControl()

        Action.all.forEach { action in
            guard action.isLocation else {
                return
            }
            guard let location = action.location else {
                return assertionFailure()
            }
            guard let image = action.image else {
                return assertionFailure()
            }

            let node = LocationAnnotationNode(location: location, image: image)

            sceneLocationView.addLocationNodeWithConfirmedLocation(
                locationNode: node)
        }
    }
}

// MARK: - Implementation

extension ShowPinsViewController {

    func showActivityControl() {
        activityView.isHidden = false
        activityView.startAnimating()
    }

    func hideActivityControl() {
        activityView.isHidden = false
        activityView.stopAnimating()
    }

}

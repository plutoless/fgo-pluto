//
// Created by Zhang, Qianze on 10/06/2017.
// Copyright (c) 2017 Zhang, Qianze. All rights reserved.
//

import Foundation
import UIKit


class NavigationController : UINavigationController {
    override var childViewControllerForStatusBarHidden: UIViewController? {
        if let vc = self.topViewController {
            return vc
        }
        return super.childViewControllerForStatusBarHidden
    }

    override var childViewControllerForStatusBarStyle: UIViewController? {
        if let vc = self.topViewController {
            return vc
        }
        return super.childViewControllerForStatusBarStyle
    }

}
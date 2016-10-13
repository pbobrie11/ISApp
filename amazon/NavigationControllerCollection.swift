//
//  NavigationControllerCollection.swift
//  amazon
//
//  Created by O'Brien, Patrick (Synchrony Financial) on 10/7/16.
//  Copyright © 2016 O'Brien, Patrick (Synchrony Financial). All rights reserved.
//

import Foundation
import UIKit

class CustomNavViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.barStyle = UIBarStyle.Default
        self.navigationBar.tintColor = UIColor.charcoalGray()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
}
}

class customAddNavigationController : UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = UIColor.synchronyGreen()
        self.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 18)!]
    }
}

class customNavigationController : UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = UIColor.synchronyGreen()
        self.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 18)!]
    }
}

class infoNavController : UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 18)!]
    }
}

class searchNavController : UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 18)!]
    }
}

class signUpNavController : UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 18)!]
        self.view.tintColor = UIColor.synchronyGreen()
    }
}

class signNavController : UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 18)!]
        self.view.tintColor = UIColor.synchronyGreen()
    }
}

class searchTableNavController : UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 18)!]
        self.view.tintColor = UIColor.synchronyGreen()
    }
}

class detailEventNavController : UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 18)!]
        self.view.tintColor = UIColor.synchronyGreen()
    }
}

class setReminderNavController : UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 18)!]
        self.view.tintColor = UIColor.synchronyGreen()
    }
}
// Copyright © 2022 Almost Engineer. All rights reserved.

import UIKit

public extension UITableView {
    func dequeueAndRegisterCell<Cell>(indexPath: IndexPath) -> Cell where Cell: UITableViewCell & Reusable {
        registerCell(type: Cell.self)
        return dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
    }
    
    func registerCell<Cell>(type: Cell.Type) where Cell: UITableViewCell & Reusable {
        register(UINib(nibName: Cell.reuseIdentifier, bundle: Bundle(for: Cell.self)), forCellReuseIdentifier: Cell.reuseIdentifier)
    }
    
    func dequeueAndRegisterReusableView<ReusableView>() -> ReusableView where ReusableView: UITableViewHeaderFooterView & Reusable {
        registerReusableView(type: ReusableView.self)
        return dequeueReusableHeaderFooterView(withIdentifier: ReusableView.reuseIdentifier) as! ReusableView
    }
    
    func registerReusableView<ReusableView>(type: ReusableView.Type) where ReusableView: UITableViewHeaderFooterView & Reusable {
        register(UINib(nibName: String(describing: ReusableView.self), bundle: Bundle(for: ReusableView.self)),
                 forHeaderFooterViewReuseIdentifier: ReusableView.reuseIdentifier)
    }
}

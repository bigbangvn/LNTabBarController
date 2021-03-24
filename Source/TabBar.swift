//
//  TabBar.swift
//  LNTabBarController
//
//  Created by Bang Nguyen on 23/3/21.
//

import SnapKit

final class TabNavigationMenu: UIImageView {
    private let stackView: UIStackView = {
        let st = UIStackView()
        st.axis = .horizontal
        st.distribution = .fillProportionally
        return st
    }()
    
    var itemTapped: ((_ tab: Int) -> Void)?
    var activeItem: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(menuItems: [TabItem], frame: CGRect) {
        self.init(frame: frame)
        
        print(frame)
        backgroundColor = .white
//        image = Resources.icon("tabBarbg")
        self.isUserInteractionEnabled = true
        //self.contentMode = .scaleAspectFit
        
        let w = frame.width
        let itemW = w / CGFloat(menuItems.count + 1)
        
        for i in 0 ..< menuItems.count {
            let isSelected = i==0
            let itemView = TabItemView(item: menuItems[i], isSelected: isSelected, index: i)
            itemView.delegate = self
            //self.createTabItem(item: menuItems[i])
            itemView.tag = i
            stackView.addArrangedSubview(itemView)
            itemView.snp.makeConstraints { make in
                make.width.equalTo(isSelected ? 2*itemW : itemW)
            }
        }
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.activateTab(tab: 2, animate: false)
    }
    
    func activateTab(tab: Int, animate: Bool = true) {
        let w = frame.width
        let itemW = w / CGFloat(stackView.arrangedSubviews.count + 1)
        
        let updateLayout = {
            for (i, view) in self.stackView.arrangedSubviews.enumerated() {
                if let v = view as? TabItemView {
                    let select = i == tab
                    v.setSelected(select)
                    v.snp.updateConstraints { make in
                        make.width.equalTo(select ? itemW*2 : itemW)
                    }
                }
            }
            self.layoutIfNeeded()
        }
        if animate {
            UIView.animate(withDuration: 0.25) {
                updateLayout()
            }
        } else {
            updateLayout()
        }
        self.itemTapped?(tab)
        self.activeItem = tab
    }
}

extension TabNavigationMenu: TabItemViewDelegate {
    func didTap(index: Int) {
        activateTab(tab: index)
    }
}

protocol TabItemViewDelegate: AnyObject {
    func didTap(index: Int)
}

final class TabItemView: UIView {
    weak var delegate: TabItemViewDelegate?
    
    private let contentStack = UIStackView()
    private let iconView = UIImageView()
    
    private lazy var lb: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 12)
        lb.textColor = .white
        return lb
    }()
    private var lbWidthConstraint: Constraint?
    
    private lazy var selectedView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .green
        //iv.image = Resources.icon("selectedTab")?.resizableImage(withCapInsets: UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20))
        return iv
    }()
    
    private let item: TabItem
    private let index: Int
    
    init(item: TabItem, isSelected: Bool, index: Int) {
        self.item = item
        self.index = index
        
        super.init(frame: .zero)
        addSubview(selectedView)
        contentStack.addArrangedSubview(iconView)
        contentStack.addArrangedSubview(lb)
        addSubview(contentStack)
        iconView.image = item.icon?.withRenderingMode(.alwaysTemplate)
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .lightGray
        lb.text = item.displayTitle
        selectedView.backgroundColor = item.highlightColor
        
        iconView.snp.makeConstraints { make in
            make.width.equalTo(iconView.snp.height)
        }
        contentStack.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
        }
        selectedView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentStack).inset(-10)
            make.top.bottom.equalTo(contentStack).inset(-2)
        }
        lb.snp.makeConstraints { make in
            lbWidthConstraint = make.width.equalTo(0).constraint
        }
        if isSelected {
            setSelected(true)
        }
        clipsToBounds = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }
    
    func setSelected(_ isSelected: Bool) {
        selectedView.isHidden = !isSelected
        if isSelected {
            contentStack.spacing = 5
            lbWidthConstraint?.deactivate()
        } else {
            lbWidthConstraint?.activate()
            contentStack.spacing = 0
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectedView.layer.cornerRadius = selectedView.bounds.height/2
    }
    
    @objc private func didTap() {
        delegate?.didTap(index: index)
    }
}

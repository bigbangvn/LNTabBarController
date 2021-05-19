//
//  TabBar.swift
//  LNTabBarController
//
//  Created by Bang Nguyen on 23/3/21.
//

import SnapKit

final class TabNavigationMenu: UIView {
    private let stackView: UIStackView = {
        let st = UIStackView()
        st.axis = .horizontal
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
    
    convenience init(menuItems: [TabItem],
                     frame: CGRect,
                     initialIndex: Int,
                     style: NavMenuStyle) {
        self.init(frame: frame)
        
        backgroundColor = .white
//        image = Resources.icon("tabBarbg")
        self.isUserInteractionEnabled = true
        //self.contentMode = .scaleAspectFit
       
        layer.shadowOffset = CGSize(width: 0, height: -0.5)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 2
        
        let w = frame.width
        let itemW = w / CGFloat(menuItems.count + 1)
        
        for i in 0 ..< menuItems.count {
            let isSelected = i==initialIndex
            let itemView = TabItemView(item: menuItems[i],
                                       isSelected: isSelected,
                                       index: i,
                                       style: style)
            itemView.delegate = self
            itemView.setSelected(isSelected)
            stackView.addArrangedSubview(itemView)
            itemView.snp.makeConstraints { make in
                make.width.equalTo(isSelected ? 2*itemW : itemW)
            }
        }
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        [UISwipeGestureRecognizer.Direction.left, .right].forEach { dir in
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
            gesture.direction = dir
            addGestureRecognizer(gesture)
        }
    }
    
    @objc private func didSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            activateTab(tab: activeItem + 1)
        case .right:
            activateTab(tab: activeItem - 1)
        default:
            break
        }
    }
    
    private func activateTab(tab: Int, animate: Bool = true) {
        let numTab = stackView.arrangedSubviews.count
        guard numTab > 1 else { return }
        let normalizedTabIndex = tab < 0 ? numTab - 1 : tab % numTab
        
        let w = frame.width
        let itemW = w / CGFloat(stackView.arrangedSubviews.count + 1)
        
        let updateLayout = {
            for (i, view) in self.stackView.arrangedSubviews.enumerated() {
                if let v = view as? TabItemView {
                    let select = i == normalizedTabIndex
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
        self.itemTapped?(normalizedTabIndex)
        self.activeItem = normalizedTabIndex
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
        lb.font = UIFont.boldSystemFont(ofSize: 12)
        return lb
    }()
    private var lbWidthConstraint: Constraint?
    
    private lazy var selectedView: UIImageView = {
        let iv = UIImageView()
        //iv.image = Resources.icon("selectedTab")?.resizableImage(withCapInsets: UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20))
        return iv
    }()
    
    private let item: TabItem
    private let index: Int
    private let style: NavMenuStyle
    
    init(item: TabItem, isSelected: Bool, index: Int, style: NavMenuStyle) {
        self.item = item
        self.index = index
        self.style = style
        super.init(frame: .zero)

        addSubview(selectedView)
        contentStack.addArrangedSubview(iconView)
        contentStack.addArrangedSubview(lb)
        addSubview(contentStack)
        
        let fgrColor = isSelected ? style.highlightFgrColor : style.normalFgrColor
        iconView.image = item.anyIcon()?.withRenderingMode(.alwaysTemplate)
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = fgrColor
        
        lb.text = item.anyTitle()
        lb.textColor = fgrColor
        selectedView.backgroundColor = style.highlightBgrColor
        
        iconView.snp.makeConstraints { make in
            make.width.equalTo(iconView.snp.height)
        }
        contentStack.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(14)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(12)
            } else {
                make.bottomMargin.equalToSuperview()
            }
            make.centerX.equalToSuperview()
        }
        selectedView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentStack).inset(-20)
            make.top.bottom.equalTo(contentStack).inset(-6)
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
        let fgrColor = isSelected ? style.highlightFgrColor : style.normalFgrColor
        iconView.tintColor = fgrColor
        lb.textColor = fgrColor
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

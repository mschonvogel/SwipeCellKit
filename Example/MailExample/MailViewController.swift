//
//  MailViewController.swift
//
//  Created by Jeremy Koch
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit
import SwipeCellKit

private let kCellReuseIdentifier = "MailCollectionCell"

class MailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var emails: [Email] = []
    
    var defaultOptions = SwipeTableOptions()
    var isSwipeRightEnabled = true
    var buttonDisplayMode: ButtonDisplayMode = .titleAndImage
    var buttonStyle: ButtonStyle = .backgroundColor
    
    private let collectionView: UICollectionView

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        let layout = UICollectionViewFlowLayout()
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.allowsSelection = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.register(MailCell.self, forCellWithReuseIdentifier: kCellReuseIdentifier)
        
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        view.addSubview(collectionView)
        
        let views = ["collectionView" : collectionView]
        let constraints = [
            "H:|[collectionView]|",
            "V:|[collectionView]|"
            ].flatMap {
                NSLayoutConstraint.constraints(withVisualFormat: $0, options: [], metrics: nil, views: views)
        }
        
        NSLayoutConstraint.activate(constraints)
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        view.layoutMargins.left = 32
        
        resetData()
    }
    
    // MARK: - Collection view data source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return emails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellReuseIdentifier, for: indexPath) as! MailCell
        cell.delegate = self
        cell.selectedBackgroundView = createSelectedBackgroundView()
        
        let email = emails[indexPath.row]
        cell.fromLabel.text = email.from
        cell.dateLabel.text = email.relativeDateString
        cell.subjectLabel.text = email.subject
        cell.bodyLabel.text = email.body
        cell.unread = email.unread
        
        return cell
    }
    
    
    // MARK: - Collection view layout delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    
    // MARK: - Actions
    
    @IBAction func moreTapped(_ sender: Any) {        
        let controller = UIAlertController(title: "Swipe Transition Style", message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Border", style: .default, handler: { _ in self.defaultOptions.transitionStyle = .border }))
        controller.addAction(UIAlertAction(title: "Drag", style: .default, handler: { _ in self.defaultOptions.transitionStyle = .drag }))
        controller.addAction(UIAlertAction(title: "Reveal", style: .default, handler: { _ in self.defaultOptions.transitionStyle = .reveal }))
        controller.addAction(UIAlertAction(title: "\(isSwipeRightEnabled ? "Disable" : "Enable") Swipe Right", style: .default, handler: { _ in self.isSwipeRightEnabled = !self.isSwipeRightEnabled }))
        controller.addAction(UIAlertAction(title: "Button Display Mode", style: .default, handler: { _ in self.buttonDisplayModeTapped() }))
        controller.addAction(UIAlertAction(title: "Button Style", style: .default, handler: { _ in self.buttonStyleTapped() }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { _ in self.resetData() }))
        present(controller, animated: true, completion: nil)
    }
    
    func buttonDisplayModeTapped() {
        let controller = UIAlertController(title: "Button Display Mode", message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Image + Title", style: .default, handler: { _ in self.buttonDisplayMode = .titleAndImage }))
        controller.addAction(UIAlertAction(title: "Image Only", style: .default, handler: { _ in self.buttonDisplayMode = .imageOnly }))
        controller.addAction(UIAlertAction(title: "Title Only", style: .default, handler: { _ in self.buttonDisplayMode = .titleOnly }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    func buttonStyleTapped() {
        let controller = UIAlertController(title: "Button Style", message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Background Color", style: .default, handler: { _ in
            self.buttonStyle = .backgroundColor
            self.defaultOptions.transitionStyle = .border
        }))
        controller.addAction(UIAlertAction(title: "Circular", style: .default, handler: { _ in
            self.buttonStyle = .circular
            self.defaultOptions.transitionStyle = .reveal
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
        
    }
    
    // MARK: - Helpers
    
    func createSelectedBackgroundView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        return view
    }
    
    func resetData() {
        emails = mockEmails
        emails.forEach { $0.unread = false }
        collectionView.reloadData()
    }
}

extension MailViewController: SwipeTableViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let email = emails[indexPath.row]

        if orientation == .left {
            guard isSwipeRightEnabled else { return nil }
            
            let read = SwipeAction(style: .default, title: nil) { action, indexPath in
                let updatedStatus = !email.unread
                email.unread = updatedStatus

                let cell = collectionView.cellForItem(at: indexPath) as! MailCell
                cell.setUnread(updatedStatus, animated: true)
            }
            
            read.hidesWhenSelected = true
            read.accessibilityLabel = email.unread ? "Mark as Read" : "Mark as Unread"

            let descriptor: ActionDescriptor = email.unread ? .read : .unread
            configure(action: read, with: descriptor)

            return [read]
        } else {
            let flag = SwipeAction(style: .default, title: nil, handler: nil)
            flag.hidesWhenSelected = true
            configure(action: flag, with: .flag)
            
            let delete = SwipeAction(style: .destructive, title: nil) { action, indexPath in
                self.emails.remove(at: indexPath.row)
                collectionView.deleteItems(at: [indexPath])
            }
            configure(action: delete, with: .trash)
            
            let cell = collectionView.cellForItem(at: indexPath) as! MailCell
            let closure: (UIAlertAction) -> Void = { _ in cell.hideSwipe(animated: true) }
            let more = SwipeAction(style: .default, title: nil) { action, indexPath in
                let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                controller.addAction(UIAlertAction(title: "Reply", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Forward", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Mark...", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Notify Me...", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Move Message...", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: closure))
                self.present(controller, animated: true, completion: nil)
            }
            configure(action: more, with: .more)

            return [delete, flag, more]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = orientation == .left ? .selection : .destructive
        options.transitionStyle = defaultOptions.transitionStyle
        
        switch buttonStyle {
        case .backgroundColor:
            options.buttonSpacing = 11
        case .circular:
            options.buttonSpacing = 4
            options.backgroundColor = #colorLiteral(red: 0.9467939734, green: 0.9468161464, blue: 0.9468042254, alpha: 1)
        }

        return options
    }
    
    func configure(action: SwipeAction, with descriptor: ActionDescriptor) {
        action.title = descriptor.title(forDisplayMode: buttonDisplayMode)
        action.image = descriptor.image(forStyle: buttonStyle, displayMode: buttonDisplayMode)

        switch buttonStyle {
        case .backgroundColor:
            action.backgroundColor = descriptor.color
        case .circular:
            action.backgroundColor = .clear
            action.textColor = descriptor.color
            action.font = .systemFont(ofSize: 13)
            action.transitionDelegate = ScaleTransition.default
        }
    }
}

class MailCell: SwipeTableViewCell {

    let fromLabel = UILabel()
    let dateLabel = UILabel()
    let subjectLabel = UILabel()
    let bodyLabel = UILabel()
    
    var animator: Any?
    
    let indicatorView = IndicatorView(frame: .zero)
    
    var unread = false {
        didSet {
            indicatorView.transform = unread ? CGAffineTransform.identity : CGAffineTransform.init(scaleX: 0.001, y: 0.001)
        }
    }
    
    override init(frame: CGRect) {

        super.init(frame: frame)
        
        contentView.backgroundColor = .white

        var views = [String: UIView]()
        
//        fromLabel.translatesAutoresizingMaskIntoConstraints = false
//        views["fromLabel"] = fromLabel
//        contentView.addSubview(fromLabel)
        
        
//        dateLabel.translatesAutoresizingMaskIntoConstraints = false
//        views["dateLabel"] = dateLabel
//        contentView.addSubview(dateLabel)
        
        
        subjectLabel.numberOfLines = 0
        subjectLabel.translatesAutoresizingMaskIntoConstraints = false
        subjectLabel.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        views["subjectLabel"] = subjectLabel
        contentView.addSubview(subjectLabel)
        
        
        bodyLabel.numberOfLines = 0
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        views["bodyLabel"] = bodyLabel
        contentView.addSubview(bodyLabel)

        
        let constraints = [
            "H:|-[subjectLabel]-|",
            "H:|-[bodyLabel]-|",
            "V:|-[subjectLabel]-[bodyLabel]-|",
            ].flatMap {
                NSLayoutConstraint.constraints(withVisualFormat: $0, options: [], metrics: nil, views: views)
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        setupIndicatorView()
    }
    
    func setupIndicatorView() {
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.color = tintColor
        indicatorView.backgroundColor = .clear
        contentView.addSubview(indicatorView)
 
        let size: CGFloat = 12
        indicatorView.widthAnchor.constraint(equalToConstant: size).isActive = true
        indicatorView.heightAnchor.constraint(equalTo: indicatorView.widthAnchor).isActive = true
        indicatorView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 12).isActive = true
        indicatorView.centerYAnchor.constraint(equalTo: fromLabel.centerYAnchor).isActive = true
    }
    
    func setUnread(_ unread: Bool, animated: Bool) {
        let closure = {
            self.unread = unread
        }
        
        if #available(iOS 10, *), animated {
            var localAnimator = self.animator as? UIViewPropertyAnimator
            localAnimator?.stopAnimation(true)
            
            localAnimator = unread ? UIViewPropertyAnimator(duration: 1.0, dampingRatio: 0.4) : UIViewPropertyAnimator(duration: 0.3, dampingRatio: 1.0)
            localAnimator?.addAnimations(closure)
            localAnimator?.startAnimation()

            self.animator = localAnimator
        } else {
            closure()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            contentView.backgroundColor = isHighlighted ? UIColor.lightGray : UIColor.white
        }
    }
    
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? UIColor.lightGray : UIColor.white
        }
    }
}

class IndicatorView: UIView {
    var color = UIColor.clear {
        didSet { setNeedsDisplay() }
    }

    override func draw(_ rect: CGRect) {
        color.set()
        UIBezierPath(ovalIn: rect).fill()
    }
}

enum ActionDescriptor {
    case read, unread, more, flag, trash
    
    func title(forDisplayMode displayMode: ButtonDisplayMode) -> String? {
        guard displayMode != .imageOnly else { return nil }
        
        switch self {
        case .read: return "Read"
        case .unread: return "Unread"
        case .more: return "More"
        case .flag: return "Flag"
        case .trash: return "Trash"
        }
    }
    
    func image(forStyle style: ButtonStyle, displayMode: ButtonDisplayMode) -> UIImage? {
        guard displayMode != .titleOnly else { return nil }
        
        let name: String
        switch self {
        case .read: name = "Read"
        case .unread: name = "Unread"
        case .more: name = "More"
        case .flag: name = "Flag"
        case .trash: name = "Trash"
        }
        
        return UIImage(named: style == .backgroundColor ? name : name + "-circle")
    }
    
    var color: UIColor {
        switch self {
        case .read, .unread: return #colorLiteral(red: 0, green: 0.4577052593, blue: 1, alpha: 1)
        case .more: return #colorLiteral(red: 0.7803494334, green: 0.7761332393, blue: 0.7967314124, alpha: 1)
        case .flag: return #colorLiteral(red: 1, green: 0.5803921569, blue: 0, alpha: 1)
        case .trash: return #colorLiteral(red: 1, green: 0.2352941176, blue: 0.1882352941, alpha: 1)
        }
    }
}
enum ButtonDisplayMode {
    case titleAndImage, titleOnly, imageOnly
}

enum ButtonStyle {
    case backgroundColor, circular
}

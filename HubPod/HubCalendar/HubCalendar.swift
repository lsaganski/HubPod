//
//  HubCalendar.swift
//  HubPod
//
//  Created by Leonardo Saganski on 25/09/19.
//  Copyright © 2019 ItauBBA. All rights reserved.
//

import Foundation
import UIKit

public protocol HubCalendarDelegate: AnyObject {
    func onResizeSked(expanding: Bool, height: CGFloat)
    func onPressDate(date: Date, events: [HubCalendarEvent])
}

@IBDesignable
public final class HubCalendar: UIView {
    let viewModel = HubCalendarViewModel()
    
    // main Views
    var viewContainer: UIView?
    var imageViewBackground: UIImageView?
    var viewContainerCV: UIStackView?
    var stackViewHeader: UIStackView?
    var stackViewWeekDays: UIStackView?
    var collectionViewExpanded: UICollectionView?
    var collectionViewCollapsed: UICollectionView?
    var buttonPrior: UIButton?
    var buttonNext: UIButton?
    var labelMonth: UILabel?
    var buttonExpand: UIButton?
    
    // view properties
    var viewExpandedHeightConstraint: NSLayoutConstraint?

    public var events: [HubCalendarEvent]? {
        didSet {
            configEvents()
        }
    }
    
    // Event markers config
    public var showMarkerA: Bool?
    public var showMarkerB: Bool?
    public var colorMarkerA: UIColor?
    public var colorMarkerB: UIColor?

    // viewContainer properties
    @IBInspectable
    public var containerBackgroundColor: UIColor = .white {
        didSet {
            configUIViewContainer()
        }
    }
    public var containerHorizontalPaddings = CGFloat(80)
    @IBInspectable public var backgroundImage: UIImage? {
        didSet {
            configUIViewContainer()
        }
    }
    // stackViewHeader properties
    @IBInspectable public var stackViewHeaderBackgroundColor: UIColor = .clear {
        didSet {
            configUIStackViewHeaderBasic()
        }
    }
    public var buttonPriorBackgroundColor: UIColor = .clear
    public var labelMonthBackgroundColor: UIColor = .clear
    public var buttonNextBackgroundColor: UIColor = .clear
    @IBInspectable public var buttonPriorTextColor: UIColor = .lightGray {
        didSet {
            configUIStackViewHeaderPriorButton()
        }
    }
    @IBInspectable public var buttonNextTextColor: UIColor = .lightGray {
        didSet {
            configUIStackViewHeaderNextButton()
        }
    }
    @IBInspectable public var buttonPriorImage: UIImage? {
        didSet {
            configUIStackViewHeaderPriorButton()
        }
    }
    @IBInspectable public var buttonNextImage: UIImage? {
        didSet {
            configUIStackViewHeaderNextButton()
        }
    }
    @IBInspectable public var buttonPriorText: String = "PREVIOUS" {
        didSet {
            configUIStackViewHeaderPriorButton()
        }
    }
    @IBInspectable public var buttonNextText: String = "NEXT" {
        didSet {
            configUIStackViewHeaderNextButton()
        }
    }
    @IBInspectable public var labelMonthFont: UIFont = UIFont.boldSystemFont(ofSize: CGFloat(16)) {
        didSet {
            configUIStackViewHeaderLabelMonth()
        }
    }
    @IBInspectable public var labelMonthTextColor: UIColor = .orange {
        didSet {
            configUIStackViewHeaderLabelMonth()
        }
    }
    // stackView weekdays properties
    @IBInspectable public var stackViewWeekdaysBackgroundColor: UIColor = .clear {
        didSet {
            configUIStackViewWeekDays()
        }
    }
    @IBInspectable public var labelWeekdaysTextColor: UIColor = .blue {
        didSet {
            configUIStackViewWeekDays()
        }
    }
    @IBInspectable public var labelWeekdaysFont: UIFont = .boldSystemFont(ofSize: CGFloat(14)) {
        didSet {
            configUIStackViewWeekDays()
        }
    }
    // collectionView properties
    @IBInspectable public var cvBackgroundColor: UIColor = .clear {
        didSet {
            configUICollectionView()
        }
    }
    var collectioViewExpandedHeightConstraint: NSLayoutConstraint?
    // expand buttom
    @IBInspectable public var buttonExpandTextColor: UIColor = .lightGray {
        didSet {
            configUIExpandButton()
        }
    }
    @IBInspectable public var buttonExpandImage: UIImage? {
        didSet {
            configUIExpandButton()
        }
    }
    @IBInspectable public var buttonExpandText: String = "EXPAND" {
        didSet {
            configUIExpandButton()
        }
    }
    // cell properties
    @IBInspectable public var cellSelectedBackgroundColor: UIColor = .itauOrange {
        didSet {
//            onReloadData()
        }
    }
    @IBInspectable public var cellSelectedTextColor: UIColor = .white {
        didSet {
//            onReloadData()
        }
    }
    @IBInspectable public var cellCurrentBackgroundColor: UIColor = .clear {
        didSet {
//            onReloadData()
        }
    }
    @IBInspectable public var cellNotCurrentBackgroundColor: UIColor = .darkGray {
        didSet {
//            onReloadData()
        }
    }
    @IBInspectable public var cellCurrentTextColor: UIColor = .lightGray {
        didSet {
//            onReloadData()
        }
    }
    @IBInspectable public var cellNotCurrentTextColor: UIColor = .lightGray {
        didSet {
//            onReloadData()
        }
    }
    @IBInspectable public var cellTodayBackgroundColor: UIColor = .orange {
        didSet {
//            onReloadData()
        }
    }
    @IBInspectable public var cellTodayTextColor: UIColor = .white {
        didSet {
//            onReloadData()
        }
    }
    @IBInspectable public var cellFont: UIFont = .systemFont(ofSize: 14) {
        didSet {
//            onReloadData()
        }
    }
    // Parameters
    var cellSize = CGFloat(0)
    let screenSize: CGRect = UIScreen.main.bounds
    @IBInspectable public var separatorColor: UIColor = .lightGray {
        didSet {
            viewModel.cellSpecs = getCellColorUISpecs()
            configUIStackViewWeekDays()
            collectionViewExpanded?.reloadData()
        }
    }
    // Calendar core
    @IBInspectable public var isExpandable: Bool = true {
        didSet {
            buttonExpand?.isHidden = !isExpandable
        }
    }
    public var delegate: HubCalendarDelegate?
    var safeArea = CGFloat(0)
    
//    public init() {}
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initHubCalendar()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initHubCalendar()
    }
    
    override public func prepareForInterfaceBuilder() {
        initHubCalendar()
    }
    
    func initHubCalendar() {
        viewModel.delegate = self
        createComponents()
        configUI()
        resetToCurrentMonth()
    }
}

extension HubCalendar {
    func createComponents() {
        safeArea = screenSize.width-containerHorizontalPaddings+0
        cellSize = safeArea/CGFloat(viewModel.numberOfItemsPerRow)
        cellSize = round(cellSize * 100) / 100
        // Create container view
        let viewContainer = UIView(frame: .zero)
        viewContainer.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(viewContainer)
        NSLayoutConstraint.activate([
            viewContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            viewContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            viewContainer.topAnchor.constraint(equalTo: topAnchor),
            viewContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        self.viewContainer = viewContainer
        // Background Image
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        viewContainer.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: viewContainer.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: viewContainer.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: viewContainer.bottomAnchor)
            ])
        self.imageViewBackground = imageView
        // Create header stackview
        let stackViewHeader = UIStackView(frame: .zero)
        stackViewHeader.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackViewHeader)
        NSLayoutConstraint.activate([
            stackViewHeader.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackViewHeader.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            stackViewHeader.widthAnchor.constraint(equalToConstant: safeArea+1),
            stackViewHeader.heightAnchor.constraint(equalToConstant: cellSize)
            ])
        self.stackViewHeader = stackViewHeader
        self.createCollectionViews()
        // Collapse / Expand button
        let buttonEC = UIButton(type: .custom)
        buttonEC.isUserInteractionEnabled = true
        buttonEC.addTarget(self, action: #selector(onPressExpand), for: .touchUpInside)
        buttonEC.translatesAutoresizingMaskIntoConstraints = false
        self.viewContainerCV?.addArrangedSubview(buttonEC)
        buttonEC.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        buttonEC.heightAnchor.constraint(equalToConstant: 60).isActive = true
        self.buttonExpand = buttonEC
    }
    
    func createCollectionViews() {
        // View container for collection views
        let viewContainerCV = UIStackView(frame: .zero)
        viewContainerCV.axis = .vertical
        viewContainerCV.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(viewContainerCV)
        if let stack = self.stackViewHeader {
            NSLayoutConstraint.activate([
//                viewContainerCV.leadingAnchor.constraint(equalTo: leadingAnchor),
//                viewContainerCV.trailingAnchor.constraint(equalTo: trailingAnchor),
                viewContainerCV.centerXAnchor.constraint(equalTo: centerXAnchor),
                viewContainerCV.topAnchor.constraint(equalTo: stack.bottomAnchor),
                viewContainerCV.widthAnchor.constraint(equalToConstant: safeArea+1)
                ])
        }
        self.viewContainerCV = viewContainerCV
        // Create days stackView
        let stackViewDays = UIStackView(frame: .zero)
        stackViewDays.translatesAutoresizingMaskIntoConstraints = false
        self.viewContainerCV?.addArrangedSubview(stackViewDays)
        stackViewDays.heightAnchor.constraint(equalToConstant: cellSize).isActive = true
        self.stackViewWeekDays = stackViewDays
        //Create collectionView expanded
        let layoutE: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layoutE.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layoutE.itemSize = CGSize(width: self.cellSize, height: self.cellSize)
        layoutE.minimumLineSpacing = 0
        layoutE.minimumInteritemSpacing = 0 //self.separatorWidth
        let cvExpanded = UICollectionView(frame: .zero, collectionViewLayout: layoutE)
        cvExpanded.translatesAutoresizingMaskIntoConstraints = false
        self.viewContainerCV?.addArrangedSubview(cvExpanded)
        self.collectioViewExpandedHeightConstraint = cvExpanded.heightAnchor.constraint(equalToConstant: 200)
        self.collectioViewExpandedHeightConstraint?.priority = .init(998)
        self.collectioViewExpandedHeightConstraint?.isActive = true
        self.collectionViewExpanded = cvExpanded
        
        //Create collectionView collapsed
        let layoutC: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layoutC.scrollDirection = .horizontal
        layoutC.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layoutC.itemSize = CGSize(width: self.cellSize, height: self.cellSize * 2)
        layoutC.minimumLineSpacing = 0
        layoutC.minimumInteritemSpacing = 0 //self.separatorWidth
        let cvCollapsed = UICollectionView(frame: .zero, collectionViewLayout: layoutC)
        cvCollapsed.translatesAutoresizingMaskIntoConstraints = false
        cvCollapsed.showsHorizontalScrollIndicator = false
        self.viewContainerCV?.addArrangedSubview(cvCollapsed)
        cvCollapsed.heightAnchor.constraint(equalToConstant: self.cellSize*2).isActive = true
        self.collectionViewCollapsed = cvCollapsed
        self.collectionViewCollapsed?.isHidden = true
    }
    
    func configUI() {
        configUIViewContainer()
        createStackViewHeader()
        configUIStackViewHeader()
        createStackViewWeekDays()
        configUIStackViewWeekDays()
        setupCollectionView()
        configUICollectionView()
        configUIExpandButton()
    }
    
    func configUIViewContainer() {
        if let image = self.backgroundImage {
            self.imageViewBackground?.image = image
        }
        self.imageViewBackground?.image = self.backgroundImage ?? nil
        self.viewContainer?.backgroundColor = self.containerBackgroundColor
    }
    
    func createStackViewHeader() {
        let btnPrior = UIButton(type: .custom)
        let lblMonth = UILabel(frame: .zero)
        let btnNext = UIButton(type: .custom)
        btnPrior.isUserInteractionEnabled = true
        btnNext.isUserInteractionEnabled = true
        if let stack = self.stackViewHeader {
            stack.addArrangedSubview(btnPrior)
            stack.addArrangedSubview(lblMonth)
            stack.addArrangedSubview(btnNext)
        }
        btnPrior.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        btnNext.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        lblMonth.setContentHuggingPriority(.defaultLow, for: .horizontal)
        btnPrior.addTarget(self, action: #selector(self.onPressPrior), for: .touchUpInside)
        btnNext.addTarget(self, action: #selector(self.onPressNext), for: .touchUpInside)
        
        self.buttonPrior = btnPrior
        self.labelMonth = lblMonth
        self.buttonNext = btnNext
    }
    
    func configUIStackViewHeader() {
        configUIStackViewHeaderBasic()
        configUIStackViewHeaderLabelMonth()
        configUIStackViewHeaderPriorButton()
        configUIStackViewHeaderNextButton()
    }
    
    func configUIStackViewHeaderBasic() {
        self.stackViewHeader?.backgroundColor = self.stackViewHeaderBackgroundColor
        self.stackViewHeader?.spacing = 0
        self.stackViewHeader?.alignment = .fill
        self.stackViewHeader?.distribution = .fillProportionally
    }
    
    func configUIStackViewHeaderLabelMonth() {
        self.labelMonth?.backgroundColor = self.labelMonthBackgroundColor
        self.labelMonth?.textColor = self.labelMonthTextColor
        self.labelMonth?.textAlignment = .center
        self.labelMonth?.font = self.labelMonthFont
    }
    
    func configUIStackViewHeaderPriorButton() {
        self.buttonPrior?.backgroundColor = self.buttonPriorBackgroundColor
        if self.buttonPriorImage != nil {
            self.buttonPrior?.setImage(self.buttonPriorImage?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.buttonPrior?.tintColor = self.buttonPriorTextColor
        } else {
            self.buttonPrior?.setTitleColor(self.buttonPriorTextColor, for: .normal)
            self.buttonPrior?.setTitle(self.buttonPriorText, for: .normal)
        }
    }
    
    func configUIStackViewHeaderNextButton() {
        self.buttonNext?.backgroundColor = self.buttonNextBackgroundColor
        if self.buttonNextImage != nil {
            self.buttonNext?.setImage(self.buttonNextImage?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.buttonNext?.tintColor = self.buttonNextTextColor
        } else {
            self.buttonNext?.setTitleColor(self.buttonNextTextColor, for: .normal)
            self.buttonNext?.setTitle(self.buttonNextText, for: .normal)
        }
    }
    
    func createStackViewWeekDays() {
        for index in 0..<viewModel.numberOfItemsPerRow {
            self.stackViewWeekDays?.addArrangedSubview(makeWeekDaysLabel(index: index))
        }
    }
    
    func configUIStackViewWeekDays() {
        self.stackViewWeekDays?.backgroundColor = self.stackViewWeekdaysBackgroundColor

        if let stack = self.stackViewWeekDays {
            for index in 0..<stack.subviews.count {
                var day = stack.subviews[index]
                day = configUIWeekDaysLabel(view: day)
                stack.removeArrangedSubview(day)
                stack.insertArrangedSubview(day, at: index)
            }
        }
    }
    
    func makeWeekDaysLabel(index: Int) -> UIView {
        let container = UIView()
        let label = UILabel(frame: .zero)
        label.text = viewModel.weekDays[index]
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        label.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true

        if index < 6 {
            let separator = UIView()
            separator.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(separator)
            separator.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
            separator.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
            let sepSizeConstraint = separator.widthAnchor.constraint(equalToConstant: index < 6 ? 1 : 0)
            sepSizeConstraint.isActive = true
            label.trailingAnchor.constraint(equalTo: separator.leadingAnchor).isActive = true
        } else {
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        }
        return container
    }
    
    func configUIWeekDaysLabel(view: UIView) -> UIView {
        view.backgroundColor = self.stackViewWeekdaysBackgroundColor
        view.widthAnchor.constraint(equalToConstant: cellSize).isActive = true
        for index in 0..<view.subviews.count {
            if view.subviews[index] is UILabel {
                (view.subviews[index] as? UILabel)?.textColor = self.labelWeekdaysTextColor
                (view.subviews[index] as? UILabel)?.font = self.labelWeekdaysFont
                (view.subviews[index] as? UILabel)?.textAlignment = .center
            } else {
                (view.subviews[index] as UIView).backgroundColor = self.separatorColor
            }
        }
        return view
    }
    
    func setupCollectionView() {
        viewModel.cellSpecs = getCellColorUISpecs()
        
        self.collectionViewExpanded?.dataSource = viewModel
        self.collectionViewExpanded?.delegate = viewModel
        self.collectionViewExpanded?.tag = 1
        self.collectionViewExpanded?.isUserInteractionEnabled = true
        self.collectionViewExpanded?.register(DayCollectionViewCell.self, forCellWithReuseIdentifier: viewModel.cellReuseIdentifier)
        self.collectionViewCollapsed?.dataSource = viewModel
        self.collectionViewCollapsed?.delegate = viewModel
        self.collectionViewCollapsed?.tag = 2
        self.isUserInteractionEnabled = true
        self.collectionViewCollapsed?.register(DayCollectionViewCell.self, forCellWithReuseIdentifier: viewModel.cellReuseIdentifier)
    }
    
    func configUICollectionView() {
        self.collectionViewExpanded?.backgroundColor = self.cvBackgroundColor
        self.collectionViewCollapsed?.backgroundColor = self.cvBackgroundColor
//        collectionViewExpanded?.borderWidth = 1
//        collectionViewExpanded?.borderColor = .green
        viewModel.cellSpecs = getCellColorUISpecs()
    }
    
    func configUIExpandButton() {
        self.buttonExpand?.backgroundColor = .clear
        if self.buttonExpandImage != nil {
            let image = self.buttonExpandImage?.withRenderingMode(.alwaysTemplate)
            self.buttonExpand?.setImage(image, for: .normal)
            self.buttonExpand?.tintColor = self.buttonExpandTextColor
            self.buttonExpand?.transform = viewModel.isExpanded ? CGAffineTransform(rotationAngle: .pi) : CGAffineTransform.identity
        }
        self.buttonExpand?.setTitleColor(self.buttonExpandTextColor, for: .normal)
        self.buttonExpand?.setTitle(self.buttonExpandText, for: .normal)
    }
    
    @objc
    func onPressPrior() {
        viewModel.loadPriorMonth()
    }
    
    @objc
    func onPressNext() {
        viewModel.loadNextMonth()
    }
    
    @objc
    func onPressExpand() {
        self.toggleExpandedCalendar()
    }
}

extension HubCalendar {
    public func toggleExpandedCalendar() {
        if isExpandable {
            viewModel.isExpanded = !viewModel.isExpanded
            collectionViewCollapsed?.isHidden = viewModel.isExpanded
            collectionViewExpanded?.isHidden = !viewModel.isExpanded
            stackViewWeekDays?.isHidden = !viewModel.isExpanded
            configUIExpandButton()
            viewModel.loadComponent()
            resizeCalendar()
        }
    }
    
    public func resizeCalendar() {
        if isExpandable {
            
            self.collectioViewExpandedHeightConstraint?.isActive = false
            let numberOfLines = (CGFloat(viewModel.currentSet.count) / CGFloat(viewModel.numberOfItemsPerRow))
            self.collectioViewExpandedHeightConstraint?.constant = numberOfLines * cellSize
            self.collectioViewExpandedHeightConstraint?.isActive = true
            let newH = viewModel.isExpanded ? (numberOfLines+3.5) * cellSize : 4.5 * cellSize
            delegate?.onResizeSked(expanding: viewModel.isExpanded, height: newH)
        }
    }
    
    func resetToCurrentMonth() {
        viewModel.currentDate = Date()
        viewModel.loadComponent()
        self.resizeCalendar()
    }
    
    func getCellColorUISpecs() -> CellColorUISpecs {
        return CellColorUISpecs(
            separatorColor: self.separatorColor,
            labelWeekdaysTextColor: self.labelWeekdaysTextColor,
            labelWeekdaysFont: self.labelWeekdaysFont,
            cellCurrentBackgroundColor: self.cellCurrentBackgroundColor,
            cellNotCurrentBackgroundColor: self.cellNotCurrentBackgroundColor,
            cellTodayTextColor: self.cellTodayTextColor,
            cellCurrentTextColor: self.cellCurrentTextColor,
            cellNotCurrentTextColor: self.cellNotCurrentTextColor,
            cellFont: self.cellFont,
            cellTodayBackgroundColor: self.cellTodayBackgroundColor,
            cellSelectedBackgroundColor: self.cellSelectedBackgroundColor,
            cellSelectedTextColor: self.cellSelectedTextColor,
            showMarkerA: self.showMarkerA ?? false,
            showMarkerB: self.showMarkerB ?? false,
            colorMarkerA: self.colorMarkerA ?? .clear,
            colorMarkerB: self.colorMarkerB ?? .clear
        )
    }
}

extension HubCalendar: HubCalendarViewModelDelegate {
    func updateLabelMonth(text: String) {
        self.labelMonth?.text = text
    }
    
    func onPressDate(date: Date, events: [HubCalendarEvent]) {
        self.delegate?.onPressDate(date: date, events: events)
    }
    
    func onReloadData() {
        self.collectionViewExpanded?.reloadData()
        if isExpandable {
            self.collectionViewCollapsed?.reloadData()
            if !viewModel.isExpanded && viewModel.isCurrentMonth {
                let indexPath = viewModel.indexPathForFirstDayOfThisWeek
                if indexPath.row >= 0 {
                    self.collectionViewCollapsed?.scrollToItem(at: indexPath, at: .left, animated: false)
                }
            }
        }
    }
}

extension HubCalendar {
    func configEvents() {
        viewModel.events = self.events ?? []
        viewModel.loadComponent()
    }
}

//
//  CalendarViewController.swift
//  enPiT2SUProduct
//
//  Created by 仲野天真 on 2022/12/10.
//

import UIKit

//MARK:- Protocol
protocol ViewLogic {
    var numberOfWeeks: Int { get set }
    var daysArray: [String]! { get set }
}

//MARK:- UIViewController
class CalendarViewController: UIViewController, ViewLogic {
    
    @IBOutlet weak var dateitem: UIBarButtonItem!
    
    //MARK: Properties
    var numberOfWeeks: Int = 0
    var selectedDay: Int = 0
    var daysArray: [String]!
    private var requestForCalendar: RequestForCalendar?
    
    private let date = DateItems.ThisMonth.Request()
    private let daysPerWeek = 7
    private var thisYear: Int = 0
    private var thisMonth: Int = 0
    private var today: Int = 0
    private var isToday = true
    private let dayOfWeekLabel = ["日", "月", "火", "水", "木", "金", "土"]
    private var monthCounter = 0
    var dayCount = 0
    
    //MARK: UI Parts
    @IBOutlet weak var collectionView: UICollectionView!
    @IBAction func prevBtn(_ sender: UIBarButtonItem) { prevMonth() }
    @IBAction func nextBtn(_ sender: UIBarButtonItem) { nextMonth() }
    
    //MARK: Initialize
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        dependencyInjection()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dependencyInjection()
    }
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configure()
        settingLabel()
        getToday()
    }
    
    @IBAction func calendarUnwind(_ unwindSegue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "CalendarSegue") {
            let controller = segue.destination as! DetailItemListViewController
            let moveDate = DateItems.MoveMonth.Request(monthCounter)
                    requestForCalendar?.requestNumberOfWeeks(request: moveDate)
                    requestForCalendar?.requestDateManager(request: moveDate)
            controller.year = moveDate.year
            controller.month = moveDate.month
            while dayCount < 7 {
                if (daysArray[dayCount] != "") {
                    break
                }
                dayCount = dayCount + 1
            }
            controller.day = (selectedDay + 1) - dayCount
            dayCount = 0
        }
    }
    
    //MARK: Setting
    private func dependencyInjection() {
        let viewController = self
        let calendarController = CalendarController()
        let calendarPresenter = CalendarPresenter()
        let calendarUseCase = CalendarUseCase()
        viewController.requestForCalendar = calendarController
        calendarController.calendarLogic = calendarUseCase
        calendarUseCase.responseForCalendar = calendarPresenter
        calendarPresenter.viewLogic = viewController
    }
    
    private func configure() {
        collectionView.dataSource = self
        collectionView.delegate = self
        requestForCalendar?.requestNumberOfWeeks(request: date)
        requestForCalendar?.requestDateManager(request: date)
    }
    
    private func settingLabel() {
        dateitem.title = "\(String(date.year))年\(String(date.month))月"
        dateitem.tintColor = .black
        title = "カレンダー"
    }
    
    private func getToday() {
        thisYear = date.year
        thisMonth = date.month
        today = date.day
    }

}

//MARK:- Setting Button Items
extension CalendarViewController {
    
    private func nextMonth() {
        monthCounter += 1
        commonSettingMoveMonth()
    }
    
    private func prevMonth() {
        monthCounter -= 1
        commonSettingMoveMonth()
    }
    
    private func commonSettingMoveMonth() {
        daysArray = nil
        let moveDate = DateItems.MoveMonth.Request(monthCounter)
        requestForCalendar?.requestNumberOfWeeks(request: moveDate)
        requestForCalendar?.requestDateManager(request: moveDate)
        dateitem.title = "\(String(moveDate.year))年\(String(moveDate.month))月"
        isToday = thisYear == moveDate.year && thisMonth == moveDate.month ? true : false
        collectionView.reloadData()
    }
    
}

//MARK:- UICollectionViewDataSource
extension CalendarViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 7 : (numberOfWeeks * daysPerWeek)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let label = cell.contentView.viewWithTag(1) as! UILabel
        label.backgroundColor = .clear
        dayOfWeekColor(label, indexPath.row, daysPerWeek)
        showDate(indexPath.section, indexPath.row, cell, label)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        if(daysArray[indexPath.row] != "") {
            selectedDay = indexPath.row
            performSegue(withIdentifier: "CalendarSegue", sender: nil)
        }
    }
    
    private func dayOfWeekColor(_ label: UILabel, _ row: Int, _ daysPerWeek: Int) {
        switch row % daysPerWeek {
        case 0: label.textColor = .red
        case 6: label.textColor = .blue
        default: label.textColor = .black
        }
    }
    
    private func showDate(_ section: Int, _ row: Int, _ cell: UICollectionViewCell, _ label: UILabel) {
        switch section {
        case 0:
            label.text = dayOfWeekLabel[row]
            cell.selectedBackgroundView = nil
        default:
            label.text = daysArray[row]
            let selectedView = UIView()
            /*selectedView.backgroundColor = UIColor(red: 213/255, green: 214/255, blue: 219/255, alpha: 1.0)*/
            cell.selectedBackgroundView = selectedView
            markToday(label)
        }
    }
    
    private func markToday(_ label: UILabel) {
        if isToday, today.description == label.text {
            label.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.5)
        }
    }
    
}

//MARK:- UICollectionViewDelegateFlowLayout
extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let weekWidth = Int(collectionView.frame.width) / daysPerWeek
        let weekHeight = weekWidth
        let dayWidth = weekWidth
        let dayHeight = (Int(collectionView.frame.height) - weekHeight) / numberOfWeeks
        return indexPath.section == 0 ? CGSize(width: weekWidth, height: weekHeight) : CGSize(width: dayWidth, height: dayHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let surplus = Int(collectionView.frame.width) % daysPerWeek
        let margin = CGFloat(surplus)/2.0
        return UIEdgeInsets(top: 0.0, left: margin, bottom: 1.5, right: margin)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}


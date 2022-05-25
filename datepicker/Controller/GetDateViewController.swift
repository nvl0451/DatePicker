//
//  GetDateViewController.swift
//  datepicker
//
//  Created by Андрей Королев on 24.05.2022.
//

import UIKit

//Get Date Delegate to send Date back to base

protocol GetDateViewControllerDelegate: AnyObject {
    func getDateViewController(getDateViewController: GetDateViewController, dateToSend date: Date)
}

//Get Date - Custom VC for date input, based on HSE App designs

class GetDateViewController: UIViewController {
    
    //MARK: - Structure and elements
    
    //GDVC structure
    //Main Vert Stack View Start
    //Date Hor Stack View Start
    //Date Button
    //Time Button
    //Date Hor Stack View End
    //Date Table View Start
    //Today Cell
    //Tomorrow Cell
    //Next Week Cell
    //Clear Cell
    //Date Table View End
    //Info Text Label
    //Main Vert Stack End
    
    //Main Stack
    var mainVerticalStack: UIStackView = {
        let mvc = UIStackView()
        mvc.translatesAutoresizingMaskIntoConstraints = false
        mvc.axis = .vertical
        mvc.spacing = 15
        return mvc
    }()
    
    //Two-button horizontal date stack
    var dateHorizontalStack: UIStackView = {
       let dhs = UIStackView()
        dhs.translatesAutoresizingMaskIntoConstraints = false
        dhs.axis = .horizontal
        dhs.spacing = 15
        dhs.distribution = .fillProportionally
        return dhs
    }()
    
    var dateButton: UIButton = {
        let db = UIButton()
        db.translatesAutoresizingMaskIntoConstraints = false
        db.setTitle("Выберите дату", for: .normal)
        db.setTitleColor(UIColor(rgb: 0x7C89A3), for: .normal)
        db.backgroundColor = UIColor(rgb: 0xF2F3F5)
        db.layer.cornerRadius = 10
        db.titleLabel?.numberOfLines = 0
        db.titleLabel?.adjustsFontSizeToFitWidth = true
        db.titleLabel?.lineBreakMode = .byWordWrapping
        db.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
        return db
    }()
    
    var timeButton: UIButton = {
        let tb = UIButton()
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.setTitle("Выберите время", for: .normal)
        tb.setTitleColor(UIColor(rgb: 0x7C89A3), for: .normal)
        tb.backgroundColor = UIColor(rgb: 0xF2F3F5)
        tb.layer.cornerRadius = 10
        tb.addTarget(self, action: #selector(timeButtonTapped), for: .touchUpInside)
        return tb
    }()
    
    //Date table
    var dateTable: UITableView = {
        let dt = UITableView()
        dt.translatesAutoresizingMaskIntoConstraints = false
        dt.register(DateHelperTVC.self, forCellReuseIdentifier: "DateHelperCell")
        dt.alwaysBounceVertical = false
        dt.separatorStyle = UITableViewCell.SeparatorStyle.none
        return dt
    }()
    
    //Info label
    var infoLabel: UILabel = {
        let il = UILabel()
        il.translatesAutoresizingMaskIntoConstraints = false
        il.text = "Вы устанавливаете срок для всех участников дедлайна"
        il.textAlignment = .center
        il.textColor = UIColor(rgb: 0x7C89A3)
        il.numberOfLines = 2
        return il
    }()
    
    //MARK: - Properties
    
    weak var delegate: GetDateViewControllerDelegate?
    
    let labelArray: [String] = ["Сегодня", "Завтра", "Следующая неделя", "Без даты и времени"]
    var deleteText: String {
        if dateIsSetup && timeIsSetup {
            return "Без даты и времени"
        } else if dateIsSetup {
            return "Без даты"
        } else if timeIsSetup {
            return "Без времени"
        }
        return "error!"
    }
    
    var dateIsSetup: Bool = false
    var timeIsSetup: Bool = false
    var dateAndTime: Bool {
        return dateIsSetup && timeIsSetup
    }
    
    var deadlineDate: Date?
    var deadlineTime: Date?
    
    //table magic
    var tableSize: Int = 3
    var tableHeight: Int = 150
    var preferredHeight: Int = 320
    
    //MARK: - Screen Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        preferredContentSize.height = CGFloat(preferredHeight)
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        title = "Срок"
        
        setupNavBarButtons()
        
        setupMainStack()
        
        constrainMainStack()
    }
    
    private func setupNavBarButtons() {
        //left
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(dismissSelf))
        
        //right
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(confirmDate))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func setupMainStack() {
        view.addSubview(mainVerticalStack)
        
        mainVerticalStack.addArrangedSubview(dateHorizontalStack)
        mainVerticalStack.addArrangedSubview(dateTable)
        mainVerticalStack.addArrangedSubview(infoLabel)
        
        //setup date stack
        setupDateStack()
        
        //setup help table
        setupHelpTable()
    }
    
    private func setupDateStack() {
        dateHorizontalStack.addArrangedSubview(dateButton)
        dateHorizontalStack.addArrangedSubview(timeButton)
        
        constrainButtons()
    }
    
    private func setupHelpTable() {
        constrainTable()
        
        dateTable.delegate = self
        dateTable.dataSource = self
        dateTable.reloadData()
    }
    
    //MARK: - Constraints
    
    private func constrainMainStack() {
        NSLayoutConstraint.activate([
            mainVerticalStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            mainVerticalStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            mainVerticalStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15)
        ])
    }
    
    private func constrainButtons() {
        NSLayoutConstraint.activate([
            dateButton.heightAnchor.constraint(equalToConstant: 50),
            timeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func constrainTable() {
        NSLayoutConstraint.deactivate(dateTable.constraints)
        NSLayoutConstraint.activate([
            dateTable.heightAnchor.constraint(equalToConstant: CGFloat(tableHeight))
        ])
    }
    
    //MARK: - Button Taps
    
    @objc private func dismissSelf() {
        navigationController?.dismiss(animated: true)
    }
    
    @objc private func confirmDate() {
        let mainDate = mergeDates(firstDate: deadlineDate!, secondDate: deadlineTime!)
        
        delegate?.getDateViewController(getDateViewController: self, dateToSend: mainDate)
        
        print(mainDate)
        
        navigationController?.dismiss(animated: true)
    }
    
    @objc private func dateButtonTapped() {
        let cvc = CalendarViewController()
        cvc.needDeleteButton = dateIsSetup
        cvc.view.layer.cornerRadius = 20
        print(dateIsSetup)
        
        cvc.delegate = self
        navigationController?.preferredContentSize.height = 370
        navigationController?.pushViewController(cvc, animated: true)
    }
    
    @objc private func timeButtonTapped() {
        let cvc = CalendarViewController()
        cvc.timeSetMode = true
        cvc.needDeleteButton = timeIsSetup
        cvc.view.layer.cornerRadius = 20
        cvc.delegate = self
        navigationController?.preferredContentSize.height = 340
        navigationController?.pushViewController(cvc, animated: true)
    }
    
    //MARK: - Date operations
    
    func updateDate(returnDate: DidReturnDate, date: Date?) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM. y г., EE"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        switch returnDate {
        case .date:
            deadlineDate = date
            dateIsSetup = true
            dateButton.setTitle(dateFormatter.string(from: date ?? Date.now), for: .normal)
            dateButton.setTitleColor(.black, for: .normal)
        case .time:
            deadlineTime = date
            timeIsSetup = true
            dateFormatter.dateFormat = "HH:mm"
            timeButton.setTitle(dateFormatter.string(from: date ?? Date.now), for: .normal)
            timeButton.setTitleColor(.black, for: .normal)
            timeButton.backgroundColor = UIColor(rgb: 0xF2F3F5)
        case .deleteDate:
            deadlineDate = nil
            dateIsSetup = false
            dateButton.setTitle("Выберите дату", for: .normal)
            dateButton.setTitleColor(UIColor(rgb: 0x7C89A3), for: .normal)
        case .deleteTime:
            deadlineTime = nil
            timeIsSetup = false
            timeButton.setTitle("Выберите время", for: .normal)
            timeButton.setTitleColor(UIColor(rgb: 0x7C89A3), for: .normal)
            timeButton.backgroundColor = UIColor(rgb: 0xF2F3F5)
        case .none:
            break
        }
        
        adjustTableView()
        
        //check if OK
        if dateAndTime {
            let totalDate = mergeDates(firstDate: deadlineDate!, secondDate: deadlineTime!)
            
            if totalDate < Date.now {
                //bad situation
                navigationItem.rightBarButtonItem?.isEnabled = false
                timeButton.backgroundColor = UIColor(rgb: 0xFF8E88)
                Toast.show(message: "Дедлайн не может быть в прошлом", controller: self)
            } else {
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    func adjustTableView() {
        if timeIsSetup || dateIsSetup {
            //print("????")
            tableSize = 4
            navigationController?.preferredContentSize.height = 370
            tableHeight = 200
        } else {
            //print("!!!!!")
            tableSize = 3
            navigationController?.preferredContentSize.height = 320
            tableHeight = 150
        }
        constrainTable()
        dateTable.reloadData()
    }
    
    func wipeDateAndTime() {
        deadlineDate = nil
        dateIsSetup = false
        dateButton.setTitle("Выберите дату", for: .normal)
        dateButton.setTitleColor(UIColor(rgb: 0x7C89A3), for: .normal)
        
        deadlineTime = nil
        timeIsSetup = false
        timeButton.setTitle("Выберите время", for: .normal)
        timeButton.setTitleColor(UIColor(rgb: 0x7C89A3), for: .normal)
        timeButton.backgroundColor = UIColor(rgb: 0xF2F3F5)
        
        adjustTableView()
        
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
}

//Table View Protocols

extension GetDateViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let choseRow = indexPath.row
        
        let dateToday = Date.now
        let dateTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: dateToday)!
        let dateWeek = Calendar.current.date(byAdding: .day, value: 7, to: dateToday)!
        
        if choseRow == 0 {
            updateDate(returnDate: .date, date: dateToday)
        } else if choseRow == 1 {
            updateDate(returnDate: .date, date: dateTomorrow)
        } else if choseRow == 2 {
            updateDate(returnDate: .date, date: dateWeek)
        } else {
            wipeDateAndTime()
        }
    }
}

extension GetDateViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSize
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dateTable.dequeueReusableCell(withIdentifier: "DateHelperCell", for: indexPath) as! DateHelperTVC
        
        cell.cellText.text = labelArray[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        let dateToday = Date.now
        let dateTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: dateToday)!
        
        var stringToday = dateFormatter.string(from: dateToday)
        var stringTomorrow = dateFormatter.string(from: dateTomorrow)
        
        if timeIsSetup {
            stringToday = "\(stringToday), \(timeButton.titleLabel!.text!)"
            stringTomorrow = "\(stringTomorrow), \(timeButton.titleLabel!.text!)"
        }
        
        if indexPath.row == 0 {
            cell.dateText.text = stringToday
            cell.cellLogo.image = UIImage(named: "calendarIconDoubleCropped")?.withRenderingMode(.alwaysTemplate)
            cell.cellLogo.tintColor = .systemOrange
        } else if indexPath.row == 1 {
            cell.dateText.text = stringTomorrow
            cell.cellLogo.image = UIImage(named: "calendarIconDoubleCropped")?.withRenderingMode(.alwaysTemplate)
            cell.cellLogo.tintColor = .systemOrange
        } else if indexPath.row == 2 {
            cell.dateText.text = stringToday
            cell.cellLogo.image = UIImage(named: "nextWeekIcon")
        } else if indexPath.row == 3 {
            cell.dateText.text = ""
            cell.cellLogo.tintColor = UIColor(rgb: 0x99A2AD)
            cell.cellText.text = deleteText
        }
        
        
        return cell
    }
}

//Calendar Delegate for Date or Time retreival

extension GetDateViewController: CalendarViewControllerDelegate {
    func calendarViewController(controller: CalendarViewController, didReturnDate returnDate: DidReturnDate, dateReturned: Date?) {
        updateDate(returnDate: returnDate, date: dateReturned)
    }
}

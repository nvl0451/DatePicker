//
//  CalendarViewController.swift
//  datepicker
//
//  Created by Андрей Королев on 24.05.2022.
//

import UIKit

//Type of date response
enum DidReturnDate {
    case date
    case time
    case deleteDate
    case deleteTime
    case none
}

//Delegate for returning date
protocol CalendarViewControllerDelegate: AnyObject {
    func calendarViewController(controller: CalendarViewController, didReturnDate returnDate: DidReturnDate, dateReturned: Date?)
}

//Calendar VC - can be fit for date or time input

class CalendarViewController: UIViewController {
    
    //MARK: - Structure and elements
    //CVC Structure:
    //case date
    //Main Stack start
    //Calendar
    //Main Stack end
    
    //case time
    //Main stack start
    //timer
    //confirm button
    //Main stack end
    
    var dateStack: UIStackView = {
        let ds = UIStackView()
        ds.translatesAutoresizingMaskIntoConstraints = false
        ds.axis = .vertical
        ds.spacing = 15
        ds.alignment = .fill
        ds.distribution = .fill
        return ds
    }()
    
    var datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.preferredDatePickerStyle = .inline
        dp.datePickerMode = .date
        dp.locale = Locale(identifier: "ru_RU")
        return dp
    }()
    
    var confirmButton: UIButton = {
        let cb = UIButton()
        cb.setTitle("Выбрать", for: .normal)
        cb.setTitleColor(.white, for: .normal)
        cb.backgroundColor = UIColor(rgb: 0x0050CF)
        cb.layer.cornerRadius = 10
        return cb
    }()
    
    //MARK: - Properties
    
    var timeSetMode: Bool = false
    
    var needDeleteButton: Bool = false
    
    weak var delegate: CalendarViewControllerDelegate?
    
    //MARK: - Setup views

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.preferredContentSize.height = timeSetMode ? 340 : 370

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        title = timeSetMode ? "Выберите время" : "Выберите дату"
        //view.layer.cornerRadius = 20
        
        setupNavBarButtons()
        
        setupDateStack()
        
        constraintDateStack()
    }
    
    private func setupNavBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(dismissSelf))
        
        //right
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Удалить", style: .plain, target: self, action: #selector(deleteDate))
        navigationItem.rightBarButtonItem?.tintColor = .systemRed
        navigationItem.rightBarButtonItem?.isEnabled = needDeleteButton
    }
    
    private func setupDateStack() {
        view.addSubview(dateStack)
        
        dateStack.addArrangedSubview(datePicker)
        
        if timeSetMode {
            datePicker.datePickerMode = .time
            datePicker.preferredDatePickerStyle = .wheels
            dateStack.addArrangedSubview(confirmButton)
            confirmButton.addTarget(self, action: #selector(didTapConfirmTime), for: .touchUpInside)
            constrainButton()
        } else {
            datePicker.addTarget(self, action: #selector(onDateChanged), for: .valueChanged)
            datePicker.minimumDate = Date.now
        }
    }
    
    //MARK: - Constraints
    
    private func constraintDateStack() {
        NSLayoutConstraint.activate([
            dateStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            dateStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            dateStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            dateStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15)
        ])
    }
    
    private func constrainButton() {
        NSLayoutConstraint.activate([
            confirmButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    //MARK: - Button Taps
    
    @objc private func dismissSelf() {
        delegate?.calendarViewController(controller: self, didReturnDate: .none, dateReturned: nil)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func deleteDate() {
        let deleteType: DidReturnDate = timeSetMode ? .deleteTime : .deleteDate
        
        delegate?.calendarViewController(controller: self, didReturnDate: deleteType, dateReturned: nil)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func onDateChanged() {
        delegate?.calendarViewController(controller: self, didReturnDate: .date, dateReturned: datePicker.date)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapConfirmTime() {
        delegate?.calendarViewController(controller: self, didReturnDate: .time, dateReturned: datePicker.date)
        navigationController?.popViewController(animated: true)
    }
}

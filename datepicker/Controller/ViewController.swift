//
//  ViewController.swift
//  datepicker
//
//  Created by Андрей Королев on 23.05.2022.
//

import UIKit
import EventKit

class ViewController: UIViewController {
    
    //MARK: - Structure and elements
    //Main VC Structure (very simple)
    //Date button to show date and copy to clipboard
    //open Get Date View Controller button
    //pickerView for subjects
    //add remider button

    var dateButton: UIButton = {
        let db = UIButton()
        db.translatesAutoresizingMaskIntoConstraints = false
        
        db.setTitle("Дата не выбрана", for: .normal)
        
        db.backgroundColor = UIColor(rgb: 0xF2F3F5)
        db.setTitleColor(.black, for: .normal)
        db.layer.cornerRadius = 10
        
        db.addTarget(self, action: #selector(didTappedDate), for: .touchUpInside)
        
        return db
    }()
    
    var openMenuButton: ActualGradientButton = {
        let omb = ActualGradientButton()
        omb.translatesAutoresizingMaskIntoConstraints = false
        
        omb.setTitle("Выбрать дату", for: .normal)
        
        //omb.backgroundColor = .clear
        omb.setTitleColor(.white, for: .normal)
        omb.layer.cornerRadius = 10
        
        omb.addTarget(self, action: #selector(getDateButtonTapped), for: .touchUpInside)
        
        return omb
    }()
    
    var pickerView: UIPickerView = {
        let pv = UIPickerView()
        pv.translatesAutoresizingMaskIntoConstraints = false
        
        return pv
    }()
    
    var reminderButton: UIButton = {
        let rb = UIButton()
        rb.translatesAutoresizingMaskIntoConstraints = false
        
        rb.setTitle("Создать напоминание", for: .normal)
        
        rb.backgroundColor = UIColor(rgb: 0x0050CF)
        rb.setTitleColor(.white, for: .normal)
        rb.layer.cornerRadius = 10
        
        rb.addTarget(self, action: #selector(didTappedReminder), for: .touchUpInside)
        
        return rb
    }()
    
    //MARK: - Properties
    
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
    var deadlineSet: Bool = false
    
    var deadlineDate: Date? = nil
    
    let pickerViewSubjects: [String] = ["Архитектура ВС", "Конструирование ПО", "Статистика", "Комплексный обед"]
    var currentPickerViewSelection: String = "Архитектура ВС"
    
    let eventStore = EKEventStore()
    
    //MARK: - Setup Views
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        title = "Тестовое задание"
        
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.selectRow(0, inComponent: 0, animated: true)
        
        addViews()
        setupConstraints()
    }

    func addViews() {
        view.addSubview(dateButton)
        view.addSubview(openMenuButton)
        view.addSubview(pickerView)
        view.addSubview(reminderButton)
        
        pickerView.isHidden = true
        reminderButton.isHidden = true
    }
    
    //MARK: - Constraints
    
    func setupConstraints() {
        //constrain dateButton
        NSLayoutConstraint.activate([
            dateButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            dateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dateButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        //constrain Open menu button
        NSLayoutConstraint.activate([
            openMenuButton.topAnchor.constraint(equalTo: dateButton.bottomAnchor, constant: 20),
            openMenuButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            openMenuButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            openMenuButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        //constrain picker view
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: openMenuButton.bottomAnchor, constant: 20),
            pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            pickerView.heightAnchor.constraint(equalToConstant: 250)
        ])
        
        //constrain reminderButton
        NSLayoutConstraint.activate([
            reminderButton.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 20),
            reminderButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            reminderButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            reminderButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    //MARK: - Button Taps
    
    @objc private func getDateButtonTapped() {
        let getDateVC = GetDateViewController()
        let getDateNC = UINavigationController(rootViewController: getDateVC)
        
        getDateNC.preferredContentSize.height = 320
        
        slideInTransitioningDelegate.disableCompactHeight = true
        slideInTransitioningDelegate.direction = .bottom
        
        getDateNC.transitioningDelegate = slideInTransitioningDelegate
        getDateNC.modalPresentationStyle = .custom
        
        getDateVC.delegate = self
        
        present(getDateNC, animated: true, completion: nil)
    }
    
    @objc private func didTappedDate() {
        if deadlineSet {
            UIPasteboard.general.string = dateButton.titleLabel?.text
            Toast.show(message: "Дедлайн скопирован в буфер обмена", controller: self)
        } else {
            Toast.show(message: "Нажмите Выбрать дату чтобы выбрать дату", controller: self)
        }
    }
    
    @objc private func didTappedReminder() {
        eventStore.requestAccess(to: EKEntityType.reminder, completion: {
          granted, error in
          if (granted) && (error == nil) {
            print("granted \(granted)")

            let reminder: EKReminder = EKReminder(eventStore: self.eventStore)
            let newTitle = self.currentPickerViewSelection
            reminder.title = newTitle
            reminder.priority = 2

            let alarmTime = self.deadlineDate
            let alarm = EKAlarm(absoluteDate: alarmTime!)
            reminder.addAlarm(alarm)

            reminder.calendar = self.eventStore.defaultCalendarForNewReminders()


            do {
              try self.eventStore.save(reminder, commit: true)
            } catch {
              print("Cannot save")
              return
            }
            print("Reminder saved")
              
            DispatchQueue.main.async {
                Toast.show(message: "Создано напоминание для \(newTitle)", controller: self)
            }
            
          }
         })
    }
}

//MARK: - GDVC Delegate for Data retreival

extension ViewController: GetDateViewControllerDelegate {
    func getDateViewController(getDateViewController: GetDateViewController, dateToSend date: Date) {
        deadlineSet = true
        deadlineDate = date
        
        pickerView.isHidden = false
        reminderButton.isHidden = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy г., EE, HH:mm"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        let deadlineString = dateFormatter.string(from: date)
        
        dateButton.setTitle(deadlineString, for: .normal)
    }
}

//MARK: - Picker View Protocols

extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentPickerViewSelection = pickerViewSubjects[row]
    }
}

extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewSubjects.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerViewSubjects[row]
    }
}

//MARK: - Gradient Button Class

class ActualGradientButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    private lazy var gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.frame = self.bounds
        l.colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor, UIColor.systemPink.cgColor]
        l.startPoint = CGPoint(x: 0, y: 0.5)
        l.endPoint = CGPoint(x: 1, y: 0.5)
        l.locations = [0.0, 0.5, 1.0]
        l.cornerRadius = 10
        l.add(gradientAnimation, forKey: gradientAnimation.keyPath)
        layer.insertSublayer(l, at: 0)
        return l
    }()
    
    private lazy var gradientAnimation: CABasicAnimation = {
        let anim = CABasicAnimation(keyPath: "locations")
        anim.fromValue = [-0.5, 0.25, 0.5]
        anim.toValue = [0.5, 0.75, 1.5]
        anim.autoreverses = true
        anim.repeatCount = .infinity
        anim.duration = 8
        return anim
    }()
}

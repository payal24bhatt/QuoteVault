//
//  ExtensionUITextField.swift
//

import UIKit
import CoreData

// MARK: - TextField's placeholder Color. -

extension UITextField {

    /// Placeholder Color of UITextField , as it is @IBInspectable so you can directlly set placeholder color of UITextField From Interface Builder , No need to write any number of Lines.
    @IBInspectable var placeholderColor: UIColor? {
        get {
            return self.placeholderColor
        } set {
            if let newValue = newValue {

                self.attributedPlaceholder = NSAttributedString(
                    string: self.placeholder ?? "",
                    attributes: [.foregroundColor:newValue]
                )
            }
        }
    }
}

// MARK: - Adding Left & Right View For TextField. -

extension UITextField {

    /// This method is used to add a leftView of UITextField.
    ///
    /// - Parameters:
    ///   - strImgName: String value - Pass the Image name.
    ///   - leftPadding: CGFloat value - (Optional - so you can pass nil if you don't want any spacing from left side) OR pass how much spacing you want from left side.
    func addLeftImageAsLeftView(strImgName: String?, leftPadding: CGFloat?) {

        let leftView = UIImageView(image: UIImage(named: strImgName ?? ""))

        leftView.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: (((leftView.image?.size.width) ?? 0.0) + (leftPadding ?? 0.0)),
            height: ((leftView.image?.size.height ?? 0.0))
        )

        leftView.contentMode = .center

        self.leftViewMode = .always
        self.leftView = leftView
    }

    /// This method is used to add a rightView of UITextField.
    ///
    /// - Parameters:
    ///   - strImgName: String value - Pass the Image name.
    ///   - rightPadding: CGFloat value - (Optional - so you can pass nil if you don't want any spacing from right side) OR pass how much spacing you want from right side.
    func addRightImageAsRightView(strImgName: String?, rightPadding: CGFloat?) {

        let rightView = UIImageView(image: UIImage(named: strImgName ?? ""))

        rightView.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: (((rightView.image?.size.width) ?? 0.0) + (rightPadding ?? 0.0)),
            height: ((rightView.image?.size.height ?? 0.0))
        )

        rightView.contentMode = .center

        self.rightViewMode = .always
        self.rightView = rightView
    }
}

typealias SelectedDateHandler = ((Date) -> Void)

// MARK: - DatePicker as TextField's inputView. -
extension UITextField {

    /// This Private Structure is used to create all AssociatedObjectKey which will be used within this extension.
    fileprivate struct AssociatedObjectKey {

        static var txtFieldDatePicker = "txtFieldDatePicker"
        static var datePickerDateFormatter = "datePickerDateFormatter"
        static var selectedDateHandler = "selectedDateHandler"
        static var defaultDate = "defaultDate"
        static var isPrefilledDate = "isPrefilledDate"
    }

    /// A Computed Property of UIDatePicker , If its already in memory then return it OR not then create new one and store it in memory reference.
    fileprivate var txtFieldDatePicker: UIDatePicker? {

        guard let txtFieldDatePicker = objc_getAssociatedObject(
            self,
            &AssociatedObjectKey.txtFieldDatePicker) as? UIDatePicker else {
                return self.addDatePicker()
        }

        return txtFieldDatePicker
    }

    /// A Private method used to create a UIDatePicker and store it in a memory reference.
    ///
    /// - Returns: return a newly created UIDatePicker.
    private func addDatePicker() -> UIDatePicker {

        let txtFieldDatePicker = UIDatePicker()
        if #available(iOS 13.4, *) {
            txtFieldDatePicker.preferredDatePickerStyle = .wheels
        }
        self.inputView = txtFieldDatePicker

        txtFieldDatePicker.addTarget(
            self,
            action: #selector(self.handleDateSelection(sender:)),
            for: .valueChanged
        )

        objc_setAssociatedObject(
            self,
            &AssociatedObjectKey.txtFieldDatePicker,
            txtFieldDatePicker,
            .OBJC_ASSOCIATION_RETAIN
        )

        self.inputAccessoryView = self.addToolBar()
        self.tintColor = .clear
        
       // txtFieldDatePicker.locale = Locale(identifier: Language.en.rawValue)

        return txtFieldDatePicker
    }

    /// A Computed Property of DateFormatter , If its already in memory then return it OR not then create new one and store it in memory reference.
    fileprivate var datePickerDateFormatter: DateFormatter? {

        guard let datePickerDateFormatter = objc_getAssociatedObject(
            self,
            &AssociatedObjectKey.datePickerDateFormatter) as? DateFormatter else {
                return self.addDatePickerDateFormatter()
        }

        return datePickerDateFormatter
    }

    /// A Private methos used to create a DateFormatter and store it in a memory reference.
    ///
    /// - Returns: return a newly created DateFormatter.
    private func addDatePickerDateFormatter() -> DateFormatter {

        let datePickerDateFormatter = DateFormatter()
        datePickerDateFormatter.locale = Locale(identifier: "en_US_POSIX")

        objc_setAssociatedObject(
            self,
            &AssociatedObjectKey.datePickerDateFormatter,
            datePickerDateFormatter,
            .OBJC_ASSOCIATION_RETAIN
        )

        return datePickerDateFormatter
    }

    /// A Private method used to handle the date selection event everytime when value changes from UIDatePicker.
    ///
    /// - Parameter sender: UIDatePicker - helps to trach the selected date from UIDatePicker
    @objc private func handleDateSelection(sender: UIDatePicker) {

        self.text = self.datePickerDateFormatter?.string(from: sender.date)

        objc_setAssociatedObject(
            self,
            &AssociatedObjectKey.defaultDate,
            sender.date,
            .OBJC_ASSOCIATION_RETAIN
        )

        if let selectedDateHandler = objc_getAssociatedObject(self, &AssociatedObjectKey.selectedDateHandler) as? SelectedDateHandler {
            selectedDateHandler(sender.date)
        }
    }

    /// This method is used to set the UIDatePickerMode.
    ///
    /// - Parameter mode: Pass the value of Enum(UIDatePickerMode).
    private func setDatePickerMode(mode: UIDatePicker.Mode?) {
        if let mode = mode {
            self.txtFieldDatePicker?.datePickerMode = mode
        }
    }

    /// This method is used to set the maximumDate of UIDatePicker.
    ///
    /// - Parameter maxDate: Pass the maximumDate you want to see in UIDatePicker.
    private func setMaximumDate(maxDate: Date?) {
        self.txtFieldDatePicker?.maximumDate = maxDate
    }

    /// This method is used to set the minimumDate of UIDatePicker.
    ///
    /// - Parameter minDate: Pass the minimumDate you want to see in UIDatePicker.
    private func setMinimumDate(minDate: Date?) {
        self.txtFieldDatePicker?.minimumDate = minDate
    }

    /// This method is used to set the (DateFormatter.Style).
    ///
    /// - Parameter dateStyle: Pass the value of Enum(DateFormatter.Style).
    private func setDateFormatterStyle(dateStyle: DateFormatter.Style) {
        self.datePickerDateFormatter?.dateStyle = dateStyle
    }

    /// This method is used to enable the UIDatePicker into UITextField. It will help you to see proper UIDatePickerMode , maximumDate , minimumDate etc into UIDatePicker.
    ///
    /// - Parameters:
    ///   - dateFormate: A String Value used to set the dateFormat you want.
    ///   - datePickerMode: Pass the value of Enum(UIDatePickerMode).
    ///
    ///   - defaultDate: A Date? (optional - you can pass nil if you don't want any defualt value) Or pass proper date which will behave like it is already selected from UIDatePicker(you can see this date into UIDatePicker First when UIDatePicker present).
    ///   - isPrefilledDate: A Bool value will help you to prefilled the UITextField with Default Value when UIDatePicker Present.
    ///   - minimumDate: Pass the minimumDate you want to see in UIDatePicker.
    ///   - maximumDate: Pass the maximumDate you want to see in UIDatePicker.
    ///   - selectedDateHandler: A Handler Block returns a selected date.
    func setDatePickerWithDateFormate(dateFormate: String,
                                      datePickerMode:UIDatePicker.Mode? = nil,
                                      defaultDate: Date? = nil,
                                      isPrefilledDate: Bool = false,
                                      minimumDate: Date? = nil,
                                      maximumDate: Date? = nil,
                                      selectedDateHandler: @escaping SelectedDateHandler) {

        self.inputView = self.txtFieldDatePicker

        self.setDateFormate(dateFormat: dateFormate)
        self.setDatePickerMode(mode: datePickerMode)
        self.setMinimumDate(minDate: minimumDate)
        self.setMaximumDate(maxDate: maximumDate)
        self.txtFieldDatePicker?.setDate(defaultDate ?? Date(), animated: true)

        // Storting the handler.
        objc_setAssociatedObject(
            self,
            &AssociatedObjectKey.selectedDateHandler,
            selectedDateHandler,
            .OBJC_ASSOCIATION_RETAIN
        )

        // Storting the default date.
        objc_setAssociatedObject(
            self,
            &AssociatedObjectKey.defaultDate,
            defaultDate,
            .OBJC_ASSOCIATION_RETAIN
        )

        // Storting the Prefilled date boolean.
        objc_setAssociatedObject(
            self,
            &AssociatedObjectKey.isPrefilledDate,
            isPrefilledDate,
            .OBJC_ASSOCIATION_RETAIN
        )

        self.delegate = self
    }

    /// A Private method is used to set the dateFormat of UIDatePicker.
    ///
    /// - Parameter dateFormat: A String Value used to set the dateFormatof UIDatePicker.
    private func setDateFormate(dateFormat: String) {
        self.datePickerDateFormatter?.dateFormat = dateFormat
    }
}

// MARK: - Tool bar -
extension UITextField {

    /// A fileprivate method is used to add a UIToolbar above UIDatePicker. This UIToolbar contain only one UIBarButtonItem(Done).
    ///
    /// - Returns: return newly created UIToolbar
    fileprivate func addToolBar() -> UIToolbar {

        let toolBar = UIToolbar(
            frame: CGRect(
                x: 0.0,
                y: 0.0,
                width: UIDevice.screenWidth,
                height: 44.0)
        )

        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: self,
            action: nil
        )

        let btnDone = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(self.btnDoneTapped(sender:))
        )
        
        // Done button
           let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.btnDoneTapped))
        doneButton.tintColor = .black
        doneButton.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        doneButton.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .highlighted)

           
    
        toolBar.setItems(
            [flexibleSpace, btnDone],
            animated: true
        )

        return toolBar
    }

    /// A Private method used to handle the touch event of button Done(A UIToolbar Button).
    ///
    /// - Parameter sender: UIBarButtonItem
    @objc private func btnDoneTapped(sender: UIBarButtonItem) {

        self.resignFirstResponder()

        guard let doneCompletionHandler = objc_getAssociatedObject(self, &AssociatedObjectKeyTwo.doneCompletionHandler) as? DoneCompletionHandler else {
            return
        }
        
        doneCompletionHandler?()
    }
}

// MARK: - PickerView as TextField's inputView. -

typealias SelectedPickerDataHandler = ((_ info: Any, _ row: Int, _ component: Int) -> Void)
typealias DoneCompletionHandler = (() -> Void)?

extension UITextField {

    fileprivate struct AssociatedObjectKeyTwo {
        static var txtFieldPickerView = "txtFieldPickerView"
        static var selectedPickerDataHandler = "selectedPickerDataHandler"
        static var doneCompletionHandler = "doneCompletionHandler"
        static var arrPickerData = "arrPickerData"
        static var arrPickerCoreData = "arrPickerCoreData"
        static var data = "data"
        static var key = "key"
    }

    fileprivate var txtFieldPickerView: UIPickerView {

        guard let txtFieldPickerView = objc_getAssociatedObject(self, &AssociatedObjectKeyTwo.txtFieldPickerView) as? UIPickerView else {
            return self.addPickerView()
        }

        return txtFieldPickerView
    }

    private func addPickerView() -> UIPickerView {

        let txtFieldPickerView = UIPickerView()

        txtFieldPickerView.dataSource  = self
        txtFieldPickerView.delegate  = self

        self.inputView = txtFieldPickerView

        objc_setAssociatedObject(
            self,
            &AssociatedObjectKeyTwo.txtFieldPickerView,
            txtFieldPickerView,
            .OBJC_ASSOCIATION_RETAIN
        )

        self.inputAccessoryView = self.addToolBar()
        self.tintColor = .clear

        return txtFieldPickerView
    }

    fileprivate var arrPickerData: [Any] {
        let isCoreData = checkForCoreDataPicker()
        
        if isCoreData.isNSManagedObject == false,
           let arrPickerData = isCoreData.result as? [Any] {
            
            // Getting the direct array
            return arrPickerData
        } else if isCoreData.isNSManagedObject == true,
                  let coreDataInfo = isCoreData.result as? [String: Any] {
            
            // Getting the dictionary object with core data entity
            if let arr = coreDataInfo[AssociatedObjectKeyTwo.data] as? [NSManagedObject],
               let key = coreDataInfo[AssociatedObjectKeyTwo.key] as? String {
                
                // Get the array to show in pickerview.
                let arFilter = arr.map { (object: NSManagedObject) -> Any in
                    let testDic: [String: Any] = object.dictionaryWithValues(forKeys: Array(object.entity.attributesByName.keys))
                    return testDic[key] ?? ""
                }
                return arFilter
            }
        }
        return []
    }

    private func checkForCoreDataPicker() -> (isNSManagedObject: Bool, result: Any?) {
        if let arrPickerData = objc_getAssociatedObject(self, &AssociatedObjectKeyTwo.arrPickerData) as? [Any] {
            // It will return normal picker data
            return (false, arrPickerData)
        } else if let coreDataInfo = objc_getAssociatedObject(self, &AssociatedObjectKeyTwo.arrPickerCoreData) as? [String: Any] {
            // It will return NSManagedObject object
            return (true, coreDataInfo)
        }
        return (false, nil)
    }

    private func pickerDidSelectRow(didSelectRow row: Int, inComponent component: Int) {

        self.text = "\(arrPickerData[row])"

        guard let selectedPickerDataHandler = objc_getAssociatedObject(self, &AssociatedObjectKeyTwo.selectedPickerDataHandler) as? SelectedPickerDataHandler else {
            return
        }

        let isCoreData = checkForCoreDataPicker()

        guard isCoreData.isNSManagedObject,
            let coreDataInfo = isCoreData.result as? [String: Any],
            let arr = coreDataInfo[AssociatedObjectKeyTwo.data] as? [NSManagedObject] else {
                // for normal data
                selectedPickerDataHandler(
                    self.text ?? "",
                    row,
                    component
                )
                return
        }

        // for NSManagedObject
        selectedPickerDataHandler(
            arr[row],
            row,
            component
        )
    }

    func setPickerData(
        arrPickerData: [Any],
        doneCompletionHandler: DoneCompletionHandler? = nil,
        pickerDataHandler: @escaping SelectedPickerDataHandler
    ) {

        self.inputView = txtFieldPickerView

        objc_setAssociatedObject(
            self,
            &AssociatedObjectKeyTwo.arrPickerData,
            arrPickerData,
            .OBJC_ASSOCIATION_RETAIN
        )

        txtFieldPickerView.reloadAllComponents()

        objc_setAssociatedObject(
            self,
            &AssociatedObjectKeyTwo.selectedPickerDataHandler,
            pickerDataHandler,
            .OBJC_ASSOCIATION_RETAIN
        )

        // Store handler for DONE button click.
        if let doneHandler = doneCompletionHandler {
            objc_setAssociatedObject(
                self,
                &AssociatedObjectKeyTwo.doneCompletionHandler,
                doneHandler,
                .OBJC_ASSOCIATION_RETAIN
            )
        }

        self.delegate = self
        let arrString = arrPickerData as? [String]
        // Set default value based on current text
        if let currentText = self.text, let row = arrString?.firstIndex(of: currentText) {
                   txtFieldPickerView.selectRow(row, inComponent: 0, animated: false)
                   pickerDataHandler(currentText, row, 0)
               }
    }

//    func setPickerData(
//        entityClass: NSManagedObject.Type,
//        predicate: NSPredicate? = nil,
//        sortDescriptors: [NSSortDescriptor]? = nil,
//        key: String, doneCompletionHandler: DoneCompletionHandler? = nil,
//        pickerDataHandler: @escaping SelectedPickerDataHandler
//    ) {
//
//        self.inputView = txtFieldPickerView
//
//        let arrData = entityClass.fetch(
//            predicate: predicate,
//            sortDescriptor: sortDescriptors
//        )
//
//        let dataInfo: [String: Any?] = [
//            AssociatedObjectKeyTwo.data: arrData,
//            AssociatedObjectKeyTwo.key: key
//        ]
//
//        objc_setAssociatedObject(
//            self,
//            &AssociatedObjectKeyTwo.arrPickerCoreData,
//            dataInfo,
//            .OBJC_ASSOCIATION_RETAIN
//        )
//
//        txtFieldPickerView.reloadAllComponents()
//
//        objc_setAssociatedObject(
//            self,
//            &AssociatedObjectKeyTwo.selectedPickerDataHandler,
//            pickerDataHandler,
//            .OBJC_ASSOCIATION_RETAIN
//        )
//
//        // Store handler for DONE button click.
//        if let doneHandler = doneCompletionHandler {
//            objc_setAssociatedObject(
//                self,
//                &AssociatedObjectKeyTwo.doneCompletionHandler,
//                doneHandler,
//                .OBJC_ASSOCIATION_RETAIN
//            )
//        }
//
//        self.delegate = self
//    }
}

// MARK: - PickerView dataSource/delegate -

extension UITextField: UIPickerViewDataSource, UIPickerViewDelegate {

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrPickerData.count
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(arrPickerData[row])"
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerDidSelectRow(didSelectRow: row, inComponent: component)
    }
}

// MARK: - TextField Delegate -

extension UITextField: UITextFieldDelegate {

    public func textFieldDidBeginEditing(_ textField: UITextField) {

        if (self.inputView as? UIDatePicker) != nil {

            if let isPrefilledDate = objc_getAssociatedObject(self, &AssociatedObjectKey.isPrefilledDate) as? Bool {

                if isPrefilledDate {

                    if let defaultDate = objc_getAssociatedObject(self, &AssociatedObjectKey.defaultDate) as? Date {

                        self.txtFieldDatePicker?.date = defaultDate
                        self.txtFieldDatePicker?.setDate(defaultDate, animated: true)
                        self.text = self.datePickerDateFormatter?.string(from: defaultDate)
                    } else {
                        print("defaultDate not set ")
                    }
                } else {
                    print("isPrefilledDate \(isPrefilledDate) ")
                }
            } else {
                print("isPrefilledDate not set")
            }
        } else if (self.inputView as? UIPickerView) != nil {
            guard arrPickerData.count > 0 else {
                return
            }

            if let index = arrPickerData.firstIndex(where: {($0 as? String) == textField.text}) {

                txtFieldPickerView.selectRow(
                    index,
                    inComponent: 0,
                    animated: false
                )

                pickerDidSelectRow(
                    didSelectRow: index,
                    inComponent: 0
                )
            } else {

                txtFieldPickerView.selectRow(
                    0,
                    inComponent: 0,
                    animated: false
                )

                pickerDidSelectRow(
                    didSelectRow: 0,
                    inComponent: 0
                )
            }
        } else {
            print("UIPickerView not show")
        }
    }
}

//
//  AddMetricViewController.swift
//  HealthTrackingApp
//
//  Created by Abhishek on 12/01/25.
//


import UIKit

protocol AddMetricDelegate: AnyObject {
    func didUpdateMetrics()
}

class AddMetricViewController: UIViewController {
    
    // MARK: --- VARIABLES ---
    private let viewModel = HealthMetricsViewModel()
    weak var delegate: AddMetricDelegate?
    var metricToEdit: HealthTracking?
    private let typePicker = UIPickerView()
    private let valueTextField = UITextField()
    private let saveButton = UIButton()
    private let metricTypes = ["Steps", "Heart Rate", "Water Intake"]
    private let metricImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        prefillValuesIfNeeded()
        
    }
    
    // MARK: --- FUNCTIONS ---

    private func setupUI() {
        
        metricImageView.contentMode = .scaleAspectFill
        metricImageView.translatesAutoresizingMaskIntoConstraints = false
        metricImageView.image = UIImage(named: "logo") // Change this to your image
        typePicker.dataSource = self
        typePicker.delegate = self
        valueTextField.placeholder = "Value"
        valueTextField.keyboardType = .numberPad
        valueTextField.delegate = self
        valueTextField.addDoneButtonOnKeyboard()
        saveButton.setTitle(metricToEdit == nil ? "Save" : "Update", for: .normal)
        saveButton.backgroundColor = #colorLiteral(red: 0.9411764706, green: 0.9254901961, blue: 0.9764705882, alpha: 1)
        saveButton.setTitleColor(.black, for: .normal)
        saveButton.addTarget(self, action: #selector(saveMetric), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [metricImageView,typePicker, valueTextField, saveButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        NSLayoutConstraint.activate([
                    metricImageView.heightAnchor.constraint(equalToConstant: 200) // Adjust height as needed
                ])
    }

    private func prefillValuesIfNeeded() {
        guard let metric = metricToEdit else { return }
        if let index = metricTypes.firstIndex(of: metric.name!) {
            typePicker.selectRow(index, inComponent: 0, animated: false)
        }
        valueTextField.text = "\(metric.value)"
    }

    @objc private func saveMetric() {
        guard let valueText = valueTextField.text, !valueText.isEmpty else {
            showAlert(title: "Input Error", message: "The value field is empty. Please enter a valid number.")
            return
        }
        
        guard let value = Double(valueText) else {
            showAlert(title: "Input Error", message: "The entered value is not valid. Please enter a numeric value.")
            return
        }

        let selectedType = metricTypes[typePicker.selectedRow(inComponent: 0)]

        if let metric = metricToEdit {
            viewModel.updateMetric(id: metric.objectID, newType: selectedType, newValue: value, newTimestamp: Date())
        } else {
            viewModel.addMetric(type: selectedType, value: value, timestamp: Date())
        }

        delegate?.didUpdateMetrics()
        navigationController?.popViewController(animated: true)
    }
}

// MARK: --- UIPICKERVIEW DELGATE AND DATASOURCE ---


extension AddMetricViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return metricTypes.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return metricTypes[row]
    }
}
// MARK: --- UITEXTFIELD DELEGATE ---

extension AddMetricViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Allow only numbers and delete key
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}

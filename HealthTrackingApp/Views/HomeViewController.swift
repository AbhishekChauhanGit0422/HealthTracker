import UIKit
import Charts
import SwiftUI

class HomeViewController: UIViewController {
    
    // MARK: --- OUTLETS ---
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var filterSortButton: UIButton!
    
    // MARK: --- VARIABLES ---
    private var metrics: [HealthTracking] = []
    private var graphMetrics: [HealthTracking] = []
    var isAscending = false
    var timeFilter = "None"
    private let viewModel = HealthMetricsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Health Tracker"
        setupUI()
        loadMetrics()
        loadGraphData()
    }
    
    // MARK: --- FUNCTIONS ---
    private func setupUI() {
        setupButton()
        setupAddButton()
        filterSegmentedControl.removeAllSegments()
        let filterArray = ["All", "Steps", "Heart Rate", "Water Intake"]
        for i in filterArray.indices{
            filterSegmentedControl.insertSegment(withTitle: filterArray[i], at: i, animated: false)
        }
        filterSegmentedControl.selectedSegmentIndex = 0
        filterSegmentedControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        // Create a hosting controller for the chart
        tableView.dataSource = self
        tableView.delegate = self
        //  tableView.register(UITableViewCell.self, forCellReuseIdentifier: )
        let nib = UINib(nibName: "ViewMetricsCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: ViewMetricsCell.reusableIdentifier)
        
        // Set a fixed height for the chart view
        createChartHostingController()
    }
    
    func createChartHostingController(){
        chartView.subviews.forEach({$0.removeFromSuperview()})
        let filterType = filterSegmentedControl.selectedSegmentIndex == 0 ? "All" : filterSegmentedControl.titleForSegment(at: filterSegmentedControl.selectedSegmentIndex)
        let lineChartView = LineChartWrapper(metrics: graphMetrics, filterType: filterType)
        let hostingController = UIHostingController(rootView: lineChartView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.bounds = chartView.bounds
        chartView.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: chartView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: chartView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: chartView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: chartView.bottomAnchor)
        ])
    }
    
    
    private func setupButton() {
        // Define actions for sorting
        let ascendingAction = UIAction(title: "Ascending", image: UIImage(systemName: "arrow.up"),state: isAscending ? .on : .off) { _ in
            self.isAscending = true
            self.updateFilterData()
        }
        
        let descendingAction = UIAction(title: "Descending", image: UIImage(systemName: "arrow.down"),state: !isAscending ? .on : .off) { _ in
            self.isAscending = false
            self.updateFilterData()
        }
        
        // Define actions for filtering
        let morningAction = UIAction(title: "Morning", image: UIImage(systemName: "sunrise"),state: timeFilter == "Morning" ? .on : .off) { _ in
            self.timeFilter = "Morning"
            self.updateFilterData()
        }
        
        let afternoonAction = UIAction(title: "Afternoon", image: UIImage(systemName: "sun.max"),state: timeFilter == "Afternoon" ? .on : .off) { _ in
            self.timeFilter = "Afternoon"
            self.updateFilterData()
        }
        
        let eveningAction = UIAction(title: "Evening", image: UIImage(systemName: "sunset"),state: timeFilter == "Evening" ? .on : .off) { _ in
            self.timeFilter = "Evening"
            self.updateFilterData()
        }
        
        let noneAction = UIAction(title: "None", image: UIImage(systemName: "xmark.circle"),state: timeFilter == "None" ? .on : .off) { _ in
            self.timeFilter = "None"
            self.updateFilterData()
        }
        // Create submenus
        let sortMenu = UIMenu(title: "Sort Order", options: .displayInline, children: [ascendingAction, descendingAction])
        let filterMenu = UIMenu(title: "Time Filter", options: .displayInline, children: [morningAction, afternoonAction, eveningAction, noneAction])
        
        // Combine submenus into one menu
        filterSortButton.menu = UIMenu(title: "Options", children: [sortMenu, filterMenu])
        
    }
    private func setupAddButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(addMetric)
        )
    }
    func updateFilterData(){
        setupButton()
        self.loadMetrics()
    }
    
    @objc private func addMetric() {
        let addVC = AddMetricViewController()
        addVC.delegate = self
        navigationController?.pushViewController(addVC, animated: true)
    }
    
    private func loadMetrics() {
        let filterType = filterSegmentedControl.selectedSegmentIndex == 0 ? nil : filterSegmentedControl.titleForSegment(at: filterSegmentedControl.selectedSegmentIndex)
        
        viewModel.fetchMetrics(filterType: filterType, ascending: self.isAscending,timeFilter: self.timeFilter) { [weak self] metrics in
            self?.metrics = metrics
            self?.tableView.reloadData()
            //  self?.updateGraph(with: metrics)
        }
    }
    
    private func loadGraphData() {
        let filterType = filterSegmentedControl.selectedSegmentIndex == 0 ? nil : filterSegmentedControl.titleForSegment(at: filterSegmentedControl.selectedSegmentIndex)
        
        viewModel.fetchMetricsForLast24Hours(filterType: filterType) { [weak self] metrics in
            self?.graphMetrics = metrics
            self?.createChartHostingController()
        }
    }
    
    
    @objc private func filterChanged() {
        loadMetrics()
        loadGraphData()
    }

    
}

// MARK: --- UITABLEVIEW DELEGATE AND DATASOURCE ---

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return metrics.count
    }
    
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ViewMetricsCell.reusableIdentifier, for: indexPath) as? ViewMetricsCell else {
            fatalError("Unable to dequeue ViewMetricsCell")
        }
        let metric = metrics[indexPath.row]
        var unit = ""
        
        switch metric.name {
        case "Steps":
            cell.metricImageView.image = UIImage(named: "footprints")
            unit = " steps"
        case "Heart Rate":
            cell.metricImageView.image = UIImage(named: "heart")
            unit = " bpm"
        case "Water Intake":
            cell.metricImageView.image = UIImage(named: "drink-water")
            unit = " L"
            
        default:
            cell.metricImageView.image = UIImage(named: "")
        }
        cell.metricName.text = "\(metric.name ?? ""): \(metric.value)\(unit)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMetric = metrics[indexPath.row]
        let addMetricVC = AddMetricViewController()
        addMetricVC.metricToEdit = selectedMetric
        addMetricVC.delegate = self
        navigationController?.pushViewController(addMetricVC, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let metricToDelete = metrics[indexPath.row]
            
            self.viewModel.deleteMetric(metric: metricToDelete) { [weak self] success in
                if success {
                    self?.metrics.remove(at: indexPath.row)
                    
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    
                    self?.loadGraphData()
                } else {
                    print("Failed to delete the metric.")
                }
            }
        }
    }
    
}

extension HomeViewController: AddMetricDelegate {
    func didUpdateMetrics() {
        loadMetrics()
        loadGraphData()
    }
}

# HealthTracker
A mobile application designed for tracking and visualizing health metrics like heart rate, steps, or water intake. Users can input, filter, sort, and view data through an intuitive interface. The app supports data persistence using local storage and offers visual trends via charts.

Health Tracker App is a robust iOS application that helps users track their daily health metrics, including steps, heart rate, and water intake. It features a clean and intuitive interface for visualizing health trends over time and managing health-related data efficiently.

Features
Health Metrics Management: Add, edit, delete, and view health metrics such as Steps, Heart Rate, and Water Intake.
Edit by tableViewDidSelect and Delete Feature by Swiping left TableView Cell.
Interactive Charts: Visualize metrics trends with customizable line charts.
Sorting & Filtering: Sort metrics in ascending or descending order and filter by time of day (Morning, Afternoon, Evening).
Dynamic UI: Responsive design supporting various user interactions and metric types.
MVVM Architecture: Clean and modular code using the Model-View-ViewModel pattern.
Dark Theme Support: from device theme changes.

Technologies Used
Swift: Core programming language for the app.
UIKit: For building a dynamic user interface.
SwiftUI: Used for chart rendering and reactive programming.
MVVM Pattern: Ensures better separation of concerns and testability.
Core Data:
Singleton Pattern: Ensures a single, shared instance of the Core Data stack throughout the app's lifecycle.
Persistent Container: Utilizes NSPersistentContainer to manage the Core Data stack.
Model Name: The persistent container is configured with the name HealthTrackingApp to match the Core Data model file (HealthTrackingApp.xcdatamodeld).
Automatic Store Loading: Automatically loads the persistent store and handles errors during initialization.
Managed Object Context:
Provides easy access to the main NSManagedObjectContext via the context property.
Automatically linked to the persistent container for seamless data persistence.
Save Context: Includes a saveContext method to persist changes to the Core Data store.

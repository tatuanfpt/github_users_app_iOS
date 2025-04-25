# 🚀 GithubUserApp

A modern iOS application built with UIKit that fetches and displays GitHub users, supports detail views, and includes persistent caching using Core Data.

---

## 🏗 Project Structure

GithubUserApp/
├── Model/                    # Data models representing GitHub users
│   ├── GitHubUser.swift
│   ├── GitHubUserDetail.swift
├── Networking/               # Networking layer using URLSession
│   ├── APIClient.swift
│   ├── GitHubService.swift
├── ViewModel/               # MVVM ViewModels for users and details
│   ├── UserListViewModel.swift
│   ├── UserDetailViewModel.swift
├── Views/                   # UIKit ViewControllers
│   ├── UserListViewController.swift
│   ├── UserDetailViewController.swift
├── CoreData/               # Core Data stack and entities
│   ├── CoreDataStack.swift
│   ├── CachedUser+CoreDataClass.swift
│   ├── CachedUser+CoreDataProperties.swift
├── Tests/                  # Unit tests
│   ├── GitHubServiceTests.swift
│   ├── UserListViewModelTests.swift
├── Supporting Files/       # App config and Core Data model
│   ├── GithubUserApp.xcdatamodeld
│   ├── Info.plist
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift

---

## 📱 Features

- Fetches and displays a list of GitHub users
- View detailed information for each user
- Caches user data using Core Data for offline access
- MVVM architecture for better testability and separation of concerns
- Unit tests for networking and ViewModel logic
- Pull-to-refresh functionality
- Dark mode support
- Error handling with user-friendly messages

---

## 🧪 Testing

### Unit Tests
The `Tests/` directory includes unit tests for:
- `GitHubService` (mocking network requests)
- `UserListViewModel` (testing logic with fake data sources)

To run tests:
Cmd + U

Or via terminal:
```bash
xcodebuild test -scheme GithubUserApp -destination 'platform=iOS Simulator,name=iPhone 14'
```

---

## 🛠 Requirements
- Xcode 14+
- iOS 15.0+
- Swift 5.7+

---

## 💡 TODO
- UI tests
- Implement infinite scrolling for user list
- Add user search functionality
- Add unit tests for UserDetailViewModel

---

## 📄 License

This project is licensed under the MIT License.

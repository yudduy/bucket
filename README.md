# Bucket - Track Your Goals, Share Your Journey

<img width="300px" align="left" src="./doc/bucket_logo.webp" />

Welcome to **Bucket** - an intuitive goal-tracking social app built for **iOS 17**, designed to help users create bucket list items, track their progress, and share their journey with friends.

This app is powered by **SwiftUI**, Apple's declarative framework for building modern user interfaces, and follows **Clean Code** principles to ensure scalability, maintainability, and high performance. Whether you're learning a new language, getting fit, or checking items off your bucket list, **Bucket** helps you stay accountable through social sharing.

This project was originally inspired by the [AppStuff](https://www.youtube.com/@appstuff) YouTube channel's **[SwiftUI Threads Clone | iOS 17 | async/await | Firebase | 2023](https://www.youtube.com/watch?v=MfwdchNNW78&t=1142s)** tutorial. Since then, the app has been transformed into a bucket list goal-tracking platform with significant architectural changes and new features.

This app includes images and resources designed by [Freepik](https://www.freepik.com). We would like to acknowledge and thank Freepik for their incredible design assets. The images used in the app are provided with attribution, as required by Freepik's licensing terms. For more information on Freepik's resources, please visit [www.freepik.com](https://www.freepik.com).

<p align="center">
  <img src="https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white" />
  <img src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white" />
  <img src="https://img.shields.io/badge/Xcode-007ACC?style=for-the-badge&logo=Xcode&logoColor=white" />
  <img src="https://img.shields.io/badge/Apple%20laptop-333333?style=for-the-badge&logo=apple&logoColor=white" />
  <img src="https://img.shields.io/badge/firebase-ffca28?style=for-the-badge&logo=firebase&logoColor=black" />
</p>

<p align="center">
  <img width="250px" src="doc/previewed/image1.jpeg" />
  <img width="250px" src="doc/previewed/image2.jpeg" />
  <img width="250px" src="doc/previewed/image3.jpeg" />
  <img width="250px" src="doc/previewed/image4.jpeg" />
  <img width="250px" src="doc/previewed/image5.jpeg" />
</p>

Slides are built using the template from [Previewed](https://previewed.app/template/AFC0B4CB). I extend my gratitude to them for their remarkable work and contribution.

## Disclaimer

This project, **Bucket**, has been developed **for educational purposes only**. The main goal is to explore and learn how to build **modern iOS applications** using **SwiftUI** and related technologies.

**Bucket does not provide real social media services, account management, or real-time interactions**. Instead, it serves as a **demonstration project** to showcase how to create a goal-tracking social experience using **SwiftUI** and other modern iOS development practices. The features and functionality are implemented to simulate real-world social apps, such as posting progress updates and engaging with friends, but they are not connected to any live data or external services.

## Project Description

**Bucket** is a dynamic iOS application developed with **SwiftUI** and powered by **Firebase** to provide users with a seamless platform to track their goals, share progress, and stay accountable with friends. Built for **iOS 17**, this app allows users to create bucket list goals, post progress updates, and engage with friends' journeys.

The app utilizes **Firebase Authentication** to manage user accounts and **Firestore** (Firebase's NoSQL database) to store user data, goals, progress updates, and interactions in real-time. This ensures a highly responsive and secure experience for users, allowing them to engage with others and track their activity effortlessly.

Users can explore new people, follow them, and get notified when their content receives likes or when someone follows them. Notifications are delivered in real-time, alerting users when someone interacts with their progress updates, creating an engaging and supportive environment.

In addition, users have the ability to **personalize their profile**, adding a personal touch to their account and showcasing their unique identity.

## Key Features

- **User Authentication**: Users can securely sign up and log in using **Firebase Authentication**

- **Create Goals**: Users can add bucket list items with titles, descriptions, and categories to track their aspirations

- **Post Progress Updates**: Share progress on your goals with photos and text updates to keep friends informed of your journey

- **Engage with Content**: Other users can **like** and **share** progress updates to show support and encouragement

- **Follow Users**: Explore and follow other users to stay updated with their goal progress

- **Real-Time Notifications**: The app delivers **real-time notifications** to alert users when someone likes their progress update or follows them

- **Profile Customization**: Users can personalize their profiles by adding images, bio information, and other customizable details

- **Explore New People**: Users can discover other users, follow them, and expand their social network within the app

- **Built with Firebase**: The app uses **Firestore** for storing user data, goals, progress updates, likes, and other interactions in real-time

- **Clean Architecture**: The app follows **Clean Code** principles and uses **SwiftUI** for creating modern, maintainable, and scalable user interfaces

<img src="doc/screenshots/picture_18.png" />

## Architecture

**Bucket** follows a modern **MVVM (Model-View-ViewModel)** pattern combined with **Clean Architecture** principles to provide a scalable, maintainable, and testable application structure. This approach ensures separation of concerns, clear data flow, and easy extensibility as the project grows.

### MVVM + Clean Architecture
- **Model**: Represents the core data structures of the application (e.g., `Goal`, `ProgressUpdate`, `User`).
- **View**: The SwiftUI views that display the UI components, like `GoalCard`, `ProgressUpdateCell`, `ActivityView`, and `ProfileView`.
- **ViewModel**: Contains the logic for transforming the raw data into something that the View can display. The ViewModel communicates with use cases to fetch and manipulate data.

**Clean Architecture** divides the application into **independent layers**:

1. **Use Case Layer**: Contains the application-specific business logic, including the actions users can perform, such as creating a goal, posting progress updates, fetching notifications, etc. Each use case is represented by a class that handles a specific feature (e.g., `CreateGoalUseCase`, `CreateProgressUpdateUseCase`, `FetchNotificationsUseCase`).

2. **Repository Layer**: Abstracts the data-fetching logic, providing a unified API for interacting with different data sources. It retrieves and manipulates data through various repositories (e.g., `GoalRepository`, `ProgressUpdateRepository`, `UserRepository`). This layer interacts with external services like Firebase and abstracts Firebase interactions behind a clean interface.

3. **DataSource Layer**: Deals directly with the external data sources (e.g., Firebase, network APIs) and returns the raw data to be passed to the repository layer. This layer abstracts the direct communication with Firebase, ensuring that the repository only interacts with the data layer and does not need to know about its implementation details.

### SwiftUI + Combine
**SwiftUI** is used for building declarative user interfaces, offering a reactive, dynamic, and flexible UI that updates as the data changes. The **Combine** framework is used for reactive programming, allowing us to bind data to views, enabling real-time updates to the user interface. This combination of **SwiftUI** and **Combine** ensures the app reacts to changes in data seamlessly, particularly for features like notifications, likes, and user actions.

### Inversion of Control (IoC) Container with Factory
The application utilizes an **IoC (Inversion of Control) container** with a **Factory** design pattern to manage dependency injection. This allows for better separation of concerns and ensures that the dependencies (such as repositories, use cases, etc.) are injected into the classes that require them. It simplifies unit testing and enhances modularity by making the app more flexible and extensible.

### Firebase Abstraction
To ensure the app remains testable and maintainable, Firebase interactions (e.g., authentication and Firestore) are abstracted through repository and data source layers. Instead of directly using Firebase SDKs throughout the app, all Firebase-related calls are routed through specific **data sources** like `UserDataSource`, `GoalDataSource`, and `ProgressUpdateDataSource`. This abstraction allows easy switching or mocking of Firebase for testing and future scalability.

## Technologies Used

**Bucket** utilizes various modern technologies and libraries to provide a rich, interactive, and high-performance user experience. Below is a list of key technologies and frameworks used in the app:

### Firebase
- **Firestore**: A real-time NoSQL database that stores all user data, goals, progress updates, notifications, and likes. Firestore allows for real-time data synchronization across devices, enabling seamless user interactions.
- **Firebase Authentication**: Handles secure user sign-in and registration with multiple authentication providers (e.g., email/password, Google, Apple). Firebase Authentication ensures user data is protected and supports scalable authentication methods.

### SwiftUI
- **SwiftUI**: Used for building the entire UI of the app. Its declarative syntax and native integration with iOS allow for easy development and maintenance of UI components.

### Combine
- **Combine**: The reactive framework that integrates with SwiftUI to manage state changes. Combine enables binding data to views and handling asynchronous events, like network calls and real-time updates.

### IoC Container & Factory Pattern
- **IoC Container**: The app leverages an IoC container to manage dependencies and handle the injection of services like repositories, use cases, and data sources, making the architecture more modular and testable.
- **Factory Pattern**: The Factory pattern is used in combination with the IoC container to create instances of required objects and services, providing better separation of concerns and flexibility.

### UI Libraries & Tools
- **Kingfisher**: A powerful image downloading and caching library for Swift. Kingfisher is used for handling profile images and other images in the app, ensuring they are efficiently cached and loaded asynchronously.

- **SwipeActions**: A native SwiftUI feature that enables swipe actions on rows, allowing users to delete or perform actions like marking notifications as read. The swipe actions are enhanced to provide a clean and intuitive UX.

### Other Frameworks
- **UIKit**: While **SwiftUI** is the primary UI framework, **UIKit** is also used for certain UI elements (e.g., custom image views, gesture recognizers) where SwiftUI lacks support.

## App Screenshots

Here are some screenshots from our app to give you a glimpse of its design and functionality.

<img width="260px" align="left" src="doc/screenshots/picture_1.png" />
<img width="260px" align="left" src="doc/screenshots/picture_2.png" />
<img width="260px" src="doc/screenshots/picture_3.png" />

<img width="260px" align="left" src="doc/screenshots/picture_4.png" />
<img width="260px" align="left" src="doc/screenshots/picture_5.png" />
<img width="260px" src="doc/screenshots/picture_6.png" />

<img width="260px" align="left" src="doc/screenshots/picture_7.png" />
<img width="260px" align="left" src="doc/screenshots/picture_8.png" />
<img width="260px" src="doc/screenshots/picture_9.png" />

<img width="260px" align="left" src="doc/screenshots/picture_10.png" />
<img width="260px" align="left" src="doc/screenshots/picture_11.png" />
<img width="260px" src="doc/screenshots/picture_12.png" />

<img width="260px" align="left" src="doc/screenshots/picture_13.png" />
<img width="260px" align="left" src="doc/screenshots/picture_14.png" />
<img width="260px" src="doc/screenshots/picture_15.png" />

<img width="260px" align="left" src="doc/screenshots/picture_16.png" />
<img width="260px" align="left" src="doc/screenshots/picture_17.png" />
<img width="260px" src="doc/screenshots/picture_19.png" />

<img width="260px" src="doc/screenshots/picture_20.png" />

## Acknowledgements

We express our deep appreciation to [Freepik](https://www.freepik.es/) for generously providing the resources used in this project.

I would like to express my sincere gratitude to the [AppStuff](https://www.youtube.com/@appstuff) YouTube channel for providing such valuable resources. Specifically, I followed the **[SwiftUI Threads Clone | iOS 17 | async/await | Firebase | 2023](https://www.youtube.com/watch?v=MfwdchNNW78&t=1142s)** tutorial, which served as a key learning tool and starting point for developing this app. This free tutorial was incredibly helpful in understanding UI development, and it provided a solid foundation for building the app. Since then, I've made significant adjustments to the architecture and incorporated new features to transform it into a goal-tracking platform.

Template mockup from https://previewed.app/template/AFC0B4CB

## Visitors Count
<img width="auto" src="https://profile-counter.glitch.me/bucket_swiftui/count.svg" />

## License

This project is licensed under the MIT License, an open-source software license that allows developers to freely use, copy, modify, and distribute the software. This includes use in both personal and commercial projects, with the only requirement being that the original copyright notice is retained.

Please note the following limitations:

- The software is provided "as is", without any warranties, express or implied.
- If you distribute the software, whether in original or modified form, you must include the original copyright notice and license.
- The license allows for commercial use, but you cannot claim ownership over the software itself.

The goal of this license is to maximize freedom for developers while maintaining recognition for the original creators.

```
MIT License

Copyright (c) 2025 Dream software - Sergio Sanchez

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

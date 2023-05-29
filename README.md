# EmpowerNUS

This application is a simple yet powerful tool that aims to make university campuses safer. Developed in Flutter and using Firebase for backend services, this application provides user authentication and a platform for reporting crime incidents, accessing safety resources, connecting with other users, and sharing life-saving data with authorities. 

## Tech Stack

- **Flutter:** Flutter is an open-source UI software development kit created by Google. It is used to develop applications for Android, iOS, Linux, Mac, Windows, Google Fuchsia, and the web from a single codebase.
  
- **Dart:** Dart is the programming language used in the Flutter framework. Dart syntax is easy to understand for JavaScript or Java developers as it supports most of the object-oriented concepts.

- **Firebase Authentication:** We are using Firebase for user authentication. Firebase Auth provides multiple methods for authentication, including email and password authentication, which we are using in this project.
  
- **Cloud Firestore:** Cloud Firestore is a flexible, scalable NoSQL cloud database to store and sync data for client- and server-side development.

## Features

### Existing Features

- **User Registration:** New users can create an account using their email address and password.
- **User Login:** Registered users can log in to the application.

### Future Features

- **Crime Reporting:** Users can report crime incidents directly through the app. This information can be shared with the authorities to ensure proper actions are taken.
- **Safety Resources:** Users can access information and resources on how to prevent crimes, ensuring they are well informed.
- **User Connection:** The app will allow users to share experiences and connect with other users, creating a sense of community and collective security.
- **Data Sharing with Authorities:** Users will be able to share crucial data with authorities, ensuring real-time communication during emergency situations.
- **Area Quick Scan:** The app will include a feature to quickly scan the area for potential risks.
- **Angel List:** Users can have an emergency contact list called the 'Angel List' for instant help during crisis situations.

## Database Structure

In the context of a crime reporting app on university campuses, we would structure our Firestore database as follows:

- **Users:** This collection will store user data, such as email, name, and emergency contacts (for the Angel List). Each document in this collection represents a user and the document id can be the unique user id provided by Firebase Auth.

- **Reports:** This collection will contain reported incidents. Each document can contain details about the incident like date, time, location, description, type of crime, and the user who reported it.

- **Resources:** This can be a collection of documents where each document represents a resource on how to prevent crimes.

Remember, when structuring the Firestore database, we should aim for a balance between query performance and update costs depending on the specific needs of the application.

## Designs

![App Mockup Design](master/images/App Mockup Design.png)


## Getting Started

### Prerequisites

- Flutter SDK: The Flutter SDK is required to build and run the app. Visit the [official Flutter site](https://flutter.dev/) to download and install Flutter.
- Firebase Account: This app uses Firebase for authentication. You need to have a Firebase project setup and have added this Flutter app to that Firebase project. Visit the [Firebase Console](https://console.firebase.google.com) to set up a new Firebase project if you don't have one already.

### Installing and Running the App

1. Clone this repository:

```bash
git clone https://github.com/YourGitHubUsername/flutter-authentication-app.git
cd flutter-authentication-app
```

2. Install dependencies:

```bash
flutter pub get


```

3. Run the app:

```bash
flutter run
```


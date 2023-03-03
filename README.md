# Chat Sieve

Chat Sieve is a simple android app that allows you to summarize messages from your chat apps. It is currently in development and may not work as expected.

## Supported Apps

Facebook Messenger only. It is planned to support other apps in the future.

## Installation

### Requirements

- A valid OpenAI API key
- A valid up to date Flutter Environment

### Steps

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter gen-l10n` to generate the localization files
4. Run `flutter run` to run the app in debug mode (or `flutter run --release` to run in release mode)

## Usage

1. Open the app
2. In the settings page, enter your OpenAI API key
3. In the settings page, enter the name of the chat you want to summarize (e.g. `Vacation 2023`)
4. Switch the service on and allow the app to access your notifications (this is required to read your messages)
5. In the home page, you can now generate summaries of your chat




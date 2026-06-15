# Cards (UNO Clone)

A multiplayer real-time implementation of the classic UNO card game. This repository contains the Flutter frontend client, designed for high-performance cross-platform gameplay with a customized rule engine. 

The backend service powering this application is built with Python and FastAPI. It operates exclusively via WebSockets to maintain low-latency bidirectional state synchronization. 

## Backend Infrastructure

The server infrastructure and API logic are hosted separately. You can find the complete backend repository and deployment details here:
[CardsBackend on Hugging Face Spaces](https://huggingface.co/spaces/iamthetwodigiter/CardsBackend/)

## Key Features

* **Real-time Multiplayer:** Instantaneous game state synchronization utilizing WebSockets.
* **Custom House Rules:** 
  * **Stacking:** Support for passing +2 and +4 draw penalties to subsequent players by stacking matching penalty cards.
  * **First/Last Card Constraints:** Enforced rules prohibiting players from winning on or initiating the game with Action or Wild cards.
  * **Auto-Pass:** Automatic turn progression when drawn cards yield no valid moves.
* **Call UNO Mechanics:** Players are required to declare "UNO" on their penultimate card. Opponents can catch players who fail to declare, resulting in a penalty draw.
* **Interactive Tutorial:** A visual, swipeable tutorial engine integrated directly into the client to explain complex house rules dynamically.
* **Adaptive UI:** Fully responsive card widgets built with custom layout builders that scale seamlessly without distortion.

## Technology Stack

* **Frontend:** Flutter & Dart
* **State Management:** Riverpod
* **Networking:** Dio (HTTP API), web_socket_channel (WebSockets)
* **Backend Integration:** FastAPI, Uvicorn, Pydantic

## Getting Started

### Prerequisites

Ensure you have the following installed on your local development environment:
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable release)
* Dart SDK (included with Flutter)
* IDE of choice (Visual Studio Code, Android Studio, or IntelliJ)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/iamthetwodigiter/Cards.git
```

2. Navigate into the project directory:
```bash
cd Cards
```

3. Install all dependencies:
```bash
flutter pub get
```

4. Configure the Backend Endpoint:
Open `lib/core/network/api_client.dart` and ensure `kServerHost` points to your deployed backend (or localhost if testing the backend locally). 

### Running the Application

Execute the following command to launch the app on your connected device or emulator:
```bash
flutter run
```

To build a release APK for Android:
```bash
flutter build apk --split-per-abi --release
```

## Architecture Details

The application follows a feature-driven architecture, separating concerns into distinct logical domains:
* `core/`: Global utilities, network configurations, and local storage mechanisms.
* `features/game/`: Core gameplay loops, card rendering logic, WebSocket handling, and the UNO game state machine.
* `features/home/`: Room generation, joining logic, and player profile configuration.
* `features/tutorial/`: Visual walkthroughs and rule explanations.

## License

This project is intended for educational purposes and personal development. UNO is a trademark of Mattel, Inc. This application is a non-commercial clone.

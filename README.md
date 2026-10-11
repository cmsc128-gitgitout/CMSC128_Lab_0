# CMSC128 Lab 0

This repository is for CMSC 128 Laboratory Activity 0 on Git and GitHub Organization Basics. 

## Group Members

- Trisha Mae Hechenagocia
- Rose Antonette Kaindoy
- Justin Lauricio
- Aleighia Keith Reyes

## Project setup

This project contains a Flutter application configured to initialize Firebase for Android and web. Follow these steps after cloning the repository to set up the project on your computer.

### Prerequisites

Install the following tools:

- **Git**, to clone the repository.
- **Flutter SDK**, including the Dart SDK. The project requires Dart `3.13.2` or later, as specified in `pubspec.yaml`. Add Flutter's `bin` directory to your `PATH`.
- **Android Studio (Optional)** (or the Android SDK command-line tools) if you plan to run the app on Android. Install an Android SDK and either create an emulator or connect an Android device with USB debugging enabled.
- **Java 17** for Android builds. Android Studio's bundled JDK 17 is suitable; otherwise, install a JDK 17 and configure `JAVA_HOME`.
- **Google Chrome** if you plan to run the web version.

After installing Flutter, open a new terminal and check your installation:

```sh
flutter --version
dart --version
flutter doctor
```

Resolve any Flutter Doctor issues for the platform you intend to use. For Android, accept the Android SDK licenses when prompted:

```sh
flutter doctor --android-licenses
```

### Clone and install dependencies

Clone the repository and change into its directory:

```sh
git clone https://github.com/cmsc128-jart/CMSC128_Lab_0.git
cd CMSC128_Lab_0
```

Download the Dart and Flutter packages declared by the project:

```sh
flutter pub get
```

### Firebase configuration

Firebase is already configured for the shared Firebase project `cmsc-128-labs`. The repository includes the FlutterFire options in `lib/firebase_options.dart`, the Android configuration in `android/app/google-services.json`, and the FlutterFire project mapping in `firebase.json`. The Android Gradle plugin is also configured to load the Google Services plugin.

You do **not** need to create a Firebase project or run FlutterFire CLI just to run the currently configured Android or web app. `lib/main.dart` initializes Firebase with the checked-in platform options. Do not replace or regenerate these files as part of ordinary local setup.

The checked-in Firebase files identify the Firebase app; they are not a substitute for Firebase Security Rules. Use the shared project only as authorized by the team, and do not add passwords, service-account keys, or other private credentials to the repository. Firebase options are currently configured for **Android and web only**; iOS, macOS, Windows, and Linux are not configured.

If Firebase rejects a request while developing a feature, check with the project maintainer that your account has the required access and that the relevant Firebase product is enabled and its rules permit the operation. Do not loosen production rules to work around a local setup issue.

### Run the app on an Android device

Install Android's **SDK Platform-Tools** (which includes `adb`) using Android Studio's SDK Manager, or install the standalone Platform-Tools package. Make sure the directory containing `adb` is on your `PATH`. On Windows, it is commonly under `%LOCALAPPDATA%\Android\Sdk\platform-tools`. Check that the command is available:

```sh
adb --version
```

#### Option 1: USB debugging

1. On your Android device, enable Developer options. On most devices, open **Settings > About phone** and tap **Build number** seven times; the exact menu names can vary by manufacturer.
2. In **Settings > Developer options**, turn on **USB debugging**.
3. Connect the device to your computer with a data-capable USB cable. Unlock the device and accept the prompt to allow USB debugging from this computer. Only authorize computers you trust.
4. Confirm that `adb` recognizes the device:

   ```sh
   adb devices
   ```

   The device should be listed with the status `device`. If it says `unauthorized`, unlock the phone and accept its authorization prompt. If it is missing, check the cable, USB connection mode, and device-specific USB driver (Windows).
5. From the project directory, list Flutter devices and run the app:

   ```sh
   flutter devices
   flutter run
   ```

   If more than one device is connected, use the device ID shown by `flutter devices`:

   ```sh
   flutter run -d <device-id>
   ```

#### Option 2: Wireless debugging (Android 11 and later)

Wireless debugging requires the computer and phone to be on the same trusted Wi-Fi network. Avoid public or untrusted networks.

1. Enable **Developer options** on the phone if you have not already, then open **Settings > Developer options > Wireless debugging** and turn it on.
2. Choose **Pair device with pairing code** on the phone. Keep the displayed pairing IP address, pairing port, and code available.
3. In a terminal, pair `adb` with the phone. Substitute the IP address and pairing port shown on the phone:

   ```sh
   adb pair <phone-ip>:<pairing-port>
   ```

   Enter the pairing code when prompted.
4. On the Wireless debugging screen, find the device's IP address and **ADB connection port**. This connection port may differ from the pairing port. Connect using the connection port:

   ```sh
   adb connect <phone-ip>:<connection-port>
   ```

5. Verify the connection and launch the app:

   ```sh
   adb devices
   flutter devices
   flutter run -d <device-id>
   ```

   Use the device ID shown by `flutter devices`. If the phone disconnects or its network address changes, repeat the wireless connection steps.

#### Wireless debugging on older Android versions

For Android 10 and earlier, wireless ADB may be available by first connecting over USB and enabling ADB TCP/IP mode:

```sh
adb devices
adb tcpip 5555
adb connect <phone-ip>:5555
```

Find the phone's IP address in its Wi-Fi network settings. The phone and computer must be on the same trusted network. Once connected, you can unplug the USB cable and use `flutter devices` followed by `flutter run -d <device-id>`. To return to USB mode, reconnect the cable and run `adb usb`.

### Run the app on an emulator

To use an Android emulator, start one from Android Studio's Device Manager, then list Flutter's available devices:

```sh
flutter devices
```

Run the app on the emulator:

```sh
flutter run
```

To run in Chrome:

```sh
flutter run -d chrome
```

When multiple devices are available, specify the device ID shown by `flutter devices`:

```sh
flutter run -d <device-id>
```

### Common setup checks

- If Flutter or Dart is not recognized, add the Flutter SDK's `bin` directory to `PATH`, open a new terminal, and rerun `flutter doctor`.
- If Android builds cannot find Java or report an incompatible Java version, configure Android Studio's JDK or `JAVA_HOME` to use Java 17, then rerun `flutter doctor`.
- If Android SDK licenses are missing, run `flutter doctor --android-licenses` and accept the required licenses.
- If packages are unavailable or the package configuration is missing, run `flutter pub get` from the repository root.
- If no Android device is listed, start an emulator or check that USB or wireless debugging is enabled and the device is authorized and connected in `adb devices`.
- If wireless ADB cannot connect, verify both devices are on the same trusted Wi-Fi network and use the phone's current ADB connection port, not its pairing port.
- If no web device is listed, install Chrome for web development.
- If Firebase reports that an app or platform is not configured, verify that you are running on Android or web. Other platforms need to be registered and configured with the project maintainer before use.



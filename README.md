# Fundare App in Flutter

Fundare: Helping Lost Vehicles Find the Way Home. Built using [Flutter.io](https://flutter.io)

## Fundare  Dev - Getting Started 

How to Install Fundare Flutter
1. Install Flutter & Dependencies 
   - See [How to Install Flutter][README/FLUTTER.md]

3. Clone this repo to your machine.
   ```
   git clone https://github.com/bnonni/Fundare_Flutter
   ```

2. cd into this repo via Terminal, and run the following commands:
   ```
   cd Fundare_Flutter/app/ios
   pod init
   ```
   - Open the newly created Podfile, and add:
   ```
   pod 'Firebase/Core'
   ```
   - Ensure its in the Podfile under the comment line # Pods for Runner, like this:
   ```
   # Pods for Runner
   pod 'Firebase/Core'
   ```

3. In terminal from the Fundare_Flutter/app/ios foler, run:
  ```
  pod install
  ```
  - Then, from that same folder, run:
  ```
  cd ../
  open -a Simulator
  flutter run
  ```

That's it! :) Enjoy!

----------------------

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)
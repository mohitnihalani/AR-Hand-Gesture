# Echo-AR Hand Gesture Recognition

IOS Application using EchoAR SDK, that recognizes hand gestures in relatime using ARKit and controles 3-D model.

## Register
If you don't have an echoAR API key yet, make sure to register for FREE at [echoAR](https://console.echoar.xyz/#/auth/register).

## Installation
- Clone the project from the github repository.
- Open up Xcode and select 'open an existing project'.

## Run
- Set your echoAR API key in the `EchoAR.swift`
- [Add the 3D model](https://docs.echoar.xyz/quickstart/add-a-3d-model) to the console.
- Connect an IOS Device and build the project.

## Usage
- Currently It supports 4 gestures:
    - 1 : Rotate active 3-D model
    - 2 : Scale down the model
    - 3 : Move model towards left direction
    - 4 : Scale up the model
    - 5 : Move towards right direction

- To use custom model add the model in CoreML directory and update `gestureRecognitionModel` in `viewController.swift` with your own model
- To update transformations based on gestures update `visionRequestDidComplete` function in `viewController-Extension.swift`

## Learn more
Refer to our [documentation](https://docs.echoar.xyz/swift/installation/) to learn more about how to use IOS Sdk and echoAR.

Refer to ARkit [documentation](https://developer.apple.com/documentation/arkit/) to learn more about how to use ARkit.


## Support
Feel free to reach out at [support@echoAR.xyz](mailto:support@echoAR.xyz) or join our [support channel on Slack](https://join.slack.com/t/echoar/shared_invite/enQtNTg4NjI5NjM3OTc1LWU1M2M2MTNlNTM3NGY1YTUxYmY3ZDNjNTc3YjA5M2QyNGZiOTgzMjVmZWZmZmFjNGJjYTcxZjhhNzk3YjNhNjE).

## ScreenShots
<img src="./sampleVideo.gif" width="300" height="800" />





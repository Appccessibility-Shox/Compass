# Building a Safari-inspired Browser

In this tutorial, we'll be covering how one might go about architecting a Safari/Chrome
-inspired browser using UIKit. The goal of this tutorial is to go from the starter iOS 
application to a browser UI with collection views displaying a grid of tab snapshots and
ensuring that whenever a tab is clicked, a zoom animation converts that snapshot into a
full web view. 

## Table of Contents

1. Basic Project Setup

## Chapter 1: Basic Project Setup

To make this tutorial easier to follow, we'll be leveraging totally programmatic UI. This
chapter includes two steps:

1. Setting up an Xcode project to use programattic UI.
1. In my case, I'll also be comitting tutorial-related files (such as the project README,
documentation screenshots, etc.)

By the end of this chapter, you'll be able to run a storyboardless starter application.

### Step 1: Project Initialization

These steps should be familiar to anyone who's developed for iOS before.

1. Open Xcode.
1. Select "File > New > Project..." (alternatively, ⌘⇧N).
1. Configure the project with the following key settings 
([Figure 1.1](./Documentation/1.1_Project_Initialization.png)): 
    - **Product name:** Compass
    - **Interface:** Storyboard
    - **Language:** Swift
1. Do initialize a Git repository for this project.

### Step 2: Eliminating Storyboards

Configuring a storybaordless iOS application is a *very* common task. Hence, there are
many, many tutorials on this. If you're reading this in the future, I'd suggest you
look on YouTube for the most recent instructions on how to complete this. The steps
below are what I did and it worked for me at the time of publishing.

1. Right click on the Main.storyboard file and select "Delete" from the context menu. 
([Figure 1.2](./Documentation/1.2_Delete_Main_Dot_Storyboard.png))
1. In the confirmation dialog, select "Move to trash".
1. Open the "Info.plist" file.
1. Delete the key entitled "Storyboard Name". 
([Figure 1.3](./Documentation/1.3_Delete_Info_Dot_Plist_Key.png))
1. In the sidebar, click on the "Compass" Xcode project.
1. Delete the build setting entitled "UIKit Main Storyboard File Base Name". 
([Figure 1.4](./Documentation/1.4_Delete_Build_Setting.png))

Next, we must edit the `SceneDelegate.swift` file. In particular, replace the boilerplate 
implementation of the `func scene(...)` method with the following:

``` swift
func scene(
    _ scene: UIScene, 
    willConnectTo session: UISceneSession, 
    options connectionOptions: UIScene.ConnectionOptions
) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    let window = UIWindow(windowScene: windowScene)
    window.makeKeyAndVisible()
    window.rootViewController = ViewController()
    self.window = window
}
```

At this point, you should be able to run your app, and see a black screen. 
([Figure 1.5](./Documentation/1.5_Blank_Screen.png))

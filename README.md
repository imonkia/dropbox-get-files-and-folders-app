# Dropbox Get Files and Folders Example

> [!NOTE]
> This is a SwiftUI app that uses the [official Dropbox SDK (SwiftyDropbox)](https://github.com/dropbox/SwiftyDropbox).

This basic iOS app demonstrates how to access a team space using the `Dropbox-API-Path-Root` header to then make a call to [/files/list_folder](https://www.dropbox.com/developers/documentation/http/documentation#files-list_folder)&lsqb;[/continue](https://www.dropbox.com/developers/documentation/http/documentation#files-list_folder-continue)&rsqb; endpoints.

For more information on Dropbox teams configuration, team file content management and interaction please refer to [DBX Team Files Guide](https://developers.dropbox.com/dbx-team-files-guide).

Becuase of the simplicity of this app, AppDelegate and SceneDelegate are not implemented, but rather the Dropbox client is instantiated when the app is first initialized.

## How to use

1. Follow the [steps outlined](https://github.com/dropbox/SwiftyDropbox/tree/633b368bd06a8f5ee12dc546b16f33cc1fa6fcd8?tab=readme-ov-file#configure-your-project) in the [SiwftyDropbox](https://github.com/dropbox/SwiftyDropbox) documentation to configure your project.
2. Replace `"APP_KEY"` with your Dropbox App's app key in the `SwiftyDropbox_ExampleApp` file (found in the [App/](https://github.com/imonkia/dropbox-get-files-and-folders-example/tree/master/SwiftyDropbox-Example/App) directory of this project).
# Serve

> **Note:** `serve` is a simple HTTP server which allows you to run your pre-built JavaScript
> app (React, Angular, etc.) in production mode for testing.

## Prerequisites: Build Your App

First, you need to build your app (depending on which tool you are using).

### Using npm:

```bash
npm build
```

### Using yarn:

```bash
yarn build
```

## Running the App with Serve

Now, execute this command to install and run `serve` as a temporary package without installing
it permanently:

```bash
npx serve -s BUILD_FOLDER_NAME
```

Now the app is running on the port which `serve` will provide (probably `3000`).

> **Note:** `BUILD_FOLDER_NAME` will probably be `dist` or `build`, depending on which tool you
> used to build the app.

## Alternative: Global Installation (Not Recommended)

If you want to install `serve` globally instead, run this command:

```bash
sudo npm install --location=global serve
```

Then, run the app with this command:

```bash
serve -s BUILD_FOLDER_NAME
```

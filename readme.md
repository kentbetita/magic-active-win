# magic-active-win

This is a modified version of the [active-win](https://github.com/sindresorhus/active-win) package. Retrieve metadata about the active window.

Works on macOS 10.14+, Linux ([note](#linux-support)), and Windows 7+.

## Install

```sh
npm install magic-active-win
```

## Usage

```js
const activeWindow = require('magic-active-win');

(async () => {
	console.log(await activeWindow(options));

	/* Expected result
	{
		title: 'Unicorns - Google Search',
		id: 5762,
		bounds: {
			x: 0,
			y: 0,
			height: 900,
			width: 1440
		},
		owner: {
			name: 'Google Chrome',
			processId: 310,
			bundleId: 'com.google.Chrome',
			path: '/Applications/Google Chrome.app'
		},
		memoryUsage: 11015432
	}
	*/
})();
```

## API

**Note**: `options` is a type of `object`.

- `activeWindow(options)`: Get metadata about the active window.
- `activeWindow.sync(options)`: Get metadata about the active window synchronously.
- `activeWindow.getOpenWindows()`:
  - Get metadata about all open windows.
  - Windows are returned in order from front to back.
  - Returns `Promise<activeWindow.Result[]>`.
- `activeWindow.getOpenWindowsSync()`:
  - Get metadata about all open windows synchronously.
  - Windows are returned in order from front to back.
  - Returns `activeWindow.Result[]`.

#### List of options

- `accessibilityPermission` **(macOS only)**
- Type: `boolean`
- Default: `true`

Enable the accessibility permission check. Setting this to `false` will prevent the accessibility permission prompt on macOS versions 10.15 and newer. The `url` property won't be retrieved.

- `screenRecordingPermission` **(macOS only)**
- Type: `boolean`
- Default: `true`

Enable the screen recording permission check. Setting this to `false` will prevent the screen recording permission prompt on macOS versions 10.15 and newer. The `title` property in the result will always be set to an empty string.

## Result

Returns a `Promise<object>` with the result, or `Promise<undefined>` if there is no active window or if the information is not available.

- `platform` _(string)_ - `'macos'` | `'linux'` | `'windows'`
- `title` _(string)_ - Window title
- `id` _(number)_ - Window identifier
- `bounds` _(Object)_ - Window position and size
  - `x` _(number)_
  - `y` _(number)_
  - `width` _(number)_
  - `height` _(number)_
- `owner` _(Object)_ - App that owns the window
  - `name` _(string)_ - Name of the app
  - `processId` _(number)_ - Process identifier
  - `bundleId` _(string)_ - Bundle identifier _(macOS only)_
  - `path` _(string)_ - Path to the app
- `memoryUsage` _(number)_ - Memory usage by the window owner process

## Development

To bypass the `gyp` build:

```sh
npm install --ignore-scripts
```

## Publishing to Github Release

Create new tag:

Check the `version` on `package.json` and just increment it.

```sh
git tag -a version -m "some desciption here"
```

Push the new tag:

```sh
git push --tags
```

Check the `Tags` section on the repository and check if the tag that you pushed exist. If it does, click on it.

On the upper right corner you will see an option to publish a release, click that and then fill the necessary details such as generating the release notes and then proceed to publish.

## Publishing to NPM

Make sure you're authenticated with `npm`:

```sh
npm login
```

Build MacOS binary: (required so that the latest binary `main` will also be published)

```sh
npm run build:macos
```

Then publish the files:

```sh
npm publish
```

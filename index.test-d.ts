import { expectType } from 'tsd';
import activeWindow from './index.js';
import { Result, LinuxResult, MacOSResult, WindowsResult } from './index.js';

expectType<Promise<Result | undefined>>(activeWindow());

const result = activeWindow.sync({
	screenRecordingPermission: false,
	accessibilityPermission: false
});

expectType<Result | undefined>(result);

if (result) {
	expectType<'macos' | 'linux' | 'windows'>(result.platform);
	expectType<string>(result.title);
	expectType<number>(result.id);
	expectType<number>(result.bounds.x);
	expectType<number>(result.bounds.y);
	expectType<number>(result.bounds.width);
	expectType<number>(result.bounds.height);
	expectType<string>(result.owner.name);
	expectType<number>(result.owner.processId);
	expectType<string>(result.owner.path);
	expectType<number>(result.memoryUsage);

	if (result.platform === 'macos') {
		expectType<MacOSResult>(result);
		expectType<string>(result.owner.bundleId);
		expectType<string | undefined>(result.url);
	} else if (result.platform === 'linux') {
		expectType<LinuxResult>(result);
		expectType(result.owner.name);
	} else {
		expectType<WindowsResult>(result);
		expectType(result.owner.name);
	}
}

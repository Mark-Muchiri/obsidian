(function() {
	const isFirefox = typeof browser !== 'undefined';
  	const runtime = isFirefox ? browser.runtime : chrome.runtime;

	document.getElementById('open-options').addEventListener('click', function() {
		if (runtime.openOptionsPage) {
			runtime.openOptionsPage();
		} else {
			// Fallback if openOptionsPage isn't supported (older Chrome versions)
			window.open(runtime.getURL('options.html'));
		}
	  });
})()
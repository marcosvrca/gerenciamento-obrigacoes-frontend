{{flutter_js}}
{{flutter_build_config}}

(function () {
  function setSplashStatus(text) {
    var el = document.querySelector('#app-loading .subtitle');
    if (el) {
      el.textContent = text;
    }
  }

  function hideSplash() {
    var el = document.getElementById('app-loading');
    if (!el || el.classList.contains('is-hidden')) {
      return;
    }
    el.classList.add('is-hidden');
    window.setTimeout(function () {
      if (el && el.parentNode) {
        el.parentNode.removeChild(el);
      }
    }, 320);
  }

  // Keep the branded splash until Flutter paints a real first frame.
  window.addEventListener('flutter-first-frame', hideSplash, { once: true });

  var flutterConfig = {
    // Smaller CanvasKit build for Chromium-based browsers (Chrome/Edge).
    canvasKitVariant: 'chromium',
  };

  _flutter.loader.load({
    config: flutterConfig,
    onEntrypointLoaded: async function (engineInitializer) {
      setSplashStatus('Inicializando o motor…');
      var appRunner = await engineInitializer.initializeEngine(flutterConfig);
      setSplashStatus('Montando a interface…');
      await appRunner.runApp();
    },
  });
})();

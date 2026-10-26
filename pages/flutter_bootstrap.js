// Übergangs-Shim für alte, noch zwischengespeicherte index.html: lädt die neueste Version.
(function () {
  fetch('/sol-tracker/latest.json?t=' + Date.now(), { cache: 'no-store' })
    .then(function (r) { return r.json(); })
    .then(function (j) {
      var old = document.querySelector('base');
      if (old) old.href = j.base; else { var b = document.createElement('base'); b.href = j.base; document.head.appendChild(b); }
      var s = document.createElement('script');
      s.src = j.base + 'flutter_bootstrap.js';
      document.body.appendChild(s);
    });
})();

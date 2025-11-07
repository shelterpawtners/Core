// Service Worker for friendly navigation redirects
// - Ensures missing .html and uppercase filenames/paths are corrected
// - Activates quickly and controls pages on first load

self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});

self.addEventListener('fetch', (event) => {
  const req = event.request;

  // Only handle top-level navigations (address bar, link clicks)
  if (req.mode !== 'navigate') return;

  const url = new URL(req.url);

  // Ignore asset directories
  const ignored = ['/css/', '/js/', '/assets/', '/images/', '/img/', '/static/'];
  if (ignored.some((p) => url.pathname.startsWith(p))) return;

  // Normalize
  let pathname = url.pathname;
  if (pathname.endsWith('/') && pathname.length > 1) pathname = pathname.slice(0, -1);

  const lastSlash = pathname.lastIndexOf('/') + 1;
  let dir = pathname.slice(0, lastSlash);
  let file = pathname.slice(lastSlash);

  // If empty file on root, let it pass (index.html will handle)
  if (!file && (dir === '/' || dir === '')) return;

  let changed = false;

  // Ensure .html for likely pages
  if (file && !file.includes('.')) {
    file = file + '.html';
    changed = true;
  }

  // Lowercase filename and directories to match filesystem
  if (/[A-Z]/.test(file)) {
    file = file.toLowerCase();
    changed = true;
  }
  if (/[A-Z]/.test(dir)) {
    dir = dir.toLowerCase();
    changed = true;
  }

  // Heuristic: only rewrite for our page routes
  const likelyPage = dir.startsWith('/pages/') || dir.startsWith('/admin/') || dir.split('/').filter(Boolean).length === 0;

  if (changed && likelyPage) {
    const target = dir + file + url.search + url.hash;
    event.respondWith(Response.redirect(target, 301));
  }
});

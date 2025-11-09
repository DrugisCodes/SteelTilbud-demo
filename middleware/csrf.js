// middleware/csrf.js
export function csrfProtection(req, res, next) {
  // midlertidig "dummy" middleware – kan utvides senere
  next();
}

export function requireCsrf(req, res, next) {
  // midlertidig "dummy" middleware for CSRF protection
  next();
}

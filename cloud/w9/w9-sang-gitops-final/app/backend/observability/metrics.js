const client = require("prom-client");

const APP_VERSION = process.env.APP_VERSION || "v1";
const ERROR_RATE = Number.parseFloat(process.env.ERROR_RATE || "0");

const registry = new client.Registry();

client.collectDefaultMetrics({
  prefix: "flipkart_nodejs_",
  register: registry,
});

const httpRequestsTotal = new client.Counter({
  name: "flipkart_http_requests_total",
  help: "Total number of HTTP requests served by the Flipkart backend.",
  labelNames: ["method", "route", "status_code", "version"],
  registers: [registry],
});

const httpRequestDurationSeconds = new client.Histogram({
  name: "flipkart_http_request_duration_seconds",
  help: "HTTP request latency for the Flipkart backend in seconds.",
  labelNames: ["method", "route", "status_code", "version"],
  buckets: [0.05, 0.1, 0.25, 0.5, 1, 2, 5],
  registers: [registry],
});

const shouldSkipInstrumentation = (req) =>
  req.path === "/healthz" || req.path === "/metrics";

const routeLabelFromRequest = (req) => {
  if (req.route && req.route.path) {
    return `${req.baseUrl || ""}${req.route.path}`;
  }

  if (req.path) {
    return req.path;
  }

  return "unknown";
};

const metricsMiddleware = (req, res, next) => {
  if (shouldSkipInstrumentation(req)) {
    return next();
  }

  const stopTimer = httpRequestDurationSeconds.startTimer();
  let recorded = false;

  const recordMetrics = () => {
    if (recorded) {
      return;
    }
    recorded = true;

    const labels = {
      method: req.method,
      route: routeLabelFromRequest(req),
      status_code: String(res.statusCode),
      version: APP_VERSION,
    };

    httpRequestsTotal.inc(labels);
    stopTimer(labels);
  };

  res.once("finish", recordMetrics);
  res.once("close", recordMetrics);

  return next();
};

const shouldInjectFailure = (req) =>
  req.path.startsWith("/api/v1") &&
  ERROR_RATE > 0 &&
  Number.isFinite(ERROR_RATE) &&
  Math.random() < ERROR_RATE;

const errorInjectionMiddleware = (req, res, next) => {
  if (!shouldInjectFailure(req)) {
    return next();
  }

  return res.status(500).json({
    success: false,
    error: "Injected failure for canary validation",
    version: APP_VERSION,
  });
};

const metricsHandler = async (_req, res) => {
  res.set("Content-Type", registry.contentType);
  res.end(await registry.metrics());
};

const healthHandler = (_req, res) => {
  res.status(200).json({
    ok: true,
    version: APP_VERSION,
    errorRate: ERROR_RATE,
  });
};

module.exports = {
  APP_VERSION,
  ERROR_RATE,
  metricsMiddleware,
  errorInjectionMiddleware,
  metricsHandler,
  healthHandler,
  registry,
};

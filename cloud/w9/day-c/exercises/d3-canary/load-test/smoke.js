import http from "k6/http";
import { check, sleep } from "k6";

export const options = {
  vus: 5,
  duration: "2m",
  thresholds: {
    http_req_failed: ["rate<0.01"],
    http_req_duration: ["p(95)<500"],
  },
};

const targetUrl = __ENV.TARGET_URL || "http://localhost:8080";

export default function () {
  const response = http.get(targetUrl);

  check(response, {
    "status is successful": (result) => result.status >= 200 && result.status < 400,
  });

  sleep(1);
}

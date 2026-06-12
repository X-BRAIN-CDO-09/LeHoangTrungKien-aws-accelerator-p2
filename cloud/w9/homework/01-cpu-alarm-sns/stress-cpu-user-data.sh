#!/bin/bash
set -euxo pipefail

cat > /tmp/cpu-burn.sh <<'SCRIPT'
#!/bin/bash
set -euxo pipefail

workers="$(nproc)"

for i in $(seq 1 "${workers}"); do
  while true; do
    :
  done &
done

wait
SCRIPT

chmod +x /tmp/cpu-burn.sh

# Keep CPU high long enough for 5 consecutive 1-minute CloudWatch datapoints.
nohup timeout 10m /tmp/cpu-burn.sh > /tmp/cpu-burn.log 2>&1 &

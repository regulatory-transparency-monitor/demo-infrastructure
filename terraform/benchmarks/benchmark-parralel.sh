#!/bin/bash

# Variables
BENCHMARK_RESULTS="benchmark_results.csv"
CPU_METRICS="cpu_metrics.csv"

# Ensure the benchmark results file exists with headers
if [[ ! -e $BENCHMARK_RESULTS ]]; then
    echo "Timestamp,Load Level,Command,Iteration,Parallelism,Response Time (ms),Status" > $BENCHMARK_RESULTS
fi

# Ensure the CPU metrics file exists with headers
if [[ ! -e $CPU_METRICS ]]; then
    echo "Timestamp, CPU Utilization (%)" > $CPU_METRICS
fi

# Define the kubectl commands to benchmark
declare -A kubectl_cmds
kubectl_cmds=(
    ["Pods in sock-shop"]="kubectl get pods -n sock-shop"
    ["Nodes"]="kubectl get nodes"
    ["PVCs in sock-shop"]="kubectl get pvc -n sock-shop"
)
run_benchmark() {
    local load_level="$1"
    local cmd_name="$2"
    local cmd="$3"
    local parallelism="$4"
    local total_iterations="$5"
    
    echo "Starting benchmark for: $cmd_name with $parallelism parallelism for $total_iterations total iterations."

    for iter in $(seq 1 $total_iterations); do
        for para_iter in $(seq 1 $parallelism); do
            {
                local timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
                start_time=$(date +%s%3N)
                eval "$cmd"
                cmd_exit_status=$?
                end_time=$(date +%s%3N)
                duration=$(( end_time - start_time ))
                if [[ $cmd_exit_status -eq 0 ]]; then
                    echo "$timestamp,\"$load_level\",\"$cmd_name\",$iter,$parallelism,$duration,Success" >> $BENCHMARK_RESULTS
                else
                    echo "$timestamp,\"$load_level\",\"$cmd_name\",$iter,$parallelism,$duration,Failure" >> $BENCHMARK_RESULTS
                fi
            } &
        done
        # Wait for all parallel jobs of this iteration to complete before proceeding
        wait
    done
    echo "Completed benchmark for: $cmd_name"
}
# Function to stress CPU
stress_cpu() {
    local utilization="$1"
    local duration="$2"

    # Stress CPU cores to achieve the target utilization
    stress-ng --cpu 1 --cpu-load 90 --timeout ${duration}s &
    stress-ng --cpu 1 --cpu-load 90 --timeout ${duration}s &

    stress_pid=$!

    # Collect CPU metrics while stress is running
    while kill -0 $stress_pid 2> /dev/null; do
        top -bn1 | grep "Cpu(s)" | \
            sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \
            awk -v date="$(date '+%Y-%m-%d %H:%M:%S')" '{print date "," 100 - $1}' >> $CPU_METRICS
        sleep 3
    done
}

# Capture user input for number of iterations
read -p "Enter number of command iterations (default is 10): " user_iterations
user_iterations=${user_iterations:-10}

# Main Execution
PARALLELISM_LEVELS=(2 5 10)

for parallelism in "${PARALLELISM_LEVELS[@]}"; do
    stress_cpu 95 $(( user_iterations * 3 / 5 ))  # Aim for 95% utilization.
    for cmd_name in "${!kubectl_cmds[@]}"; do
        run_benchmark $user_iterations "$cmd_name" "${kubectl_cmds[$cmd_name]}" $parallelism $user_iterations
    done
done

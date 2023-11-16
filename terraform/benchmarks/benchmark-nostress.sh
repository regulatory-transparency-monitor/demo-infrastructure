#!/bin/bash

# Define the benchmark commands and their labels
declare -A COMMANDS
COMMANDS["Pods in sock-shop"]="kubectl get pods -n sock-shop"
COMMANDS["Nodes"]="kubectl get nodes"
COMMANDS["PVCs in sock-shop"]="kubectl get pvc -n sock-shop"

# File to save benchmark results
BENCHMARK_FILE="benchmark_results.csv"
CPU_METRICS_FILE="cpu_metrics.csv"

# Check if a number of iterations is passed as an argument
if [ "$1" -gt 0 ] 2>/dev/null; then
    ITERATIONS=$1
else
    ITERATIONS=5
fi

# Function to get CPU utilization
get_cpu_utilization() {
    echo $(top -bn2 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | tail -n 1 | awk '{print 100 - $1}')
}

# Clear or create the benchmark results file
echo "Command,Iteration,Response Time (ms),Status" > $BENCHMARK_FILE
echo "Timestamp, CPU Utilization (%)" > $CPU_METRICS_FILE

# Execute benchmarks
for CMD_LABEL in "${!COMMANDS[@]}"; do
    echo "Starting benchmark for: $CMD_LABEL"
    CMD="${COMMANDS[$CMD_LABEL]}"
    for i in $(seq 1 $ITERATIONS); do
        echo "Executing iteration $i of $CMD_LABEL"
        START_TIME=$(date +%s%3N)  # Current time in milliseconds
        OUTPUT=$($CMD 2>&1)
        END_TIME=$(date +%s%3N)  # Current time in milliseconds
        RESPONSE_TIME=$(($END_TIME - $START_TIME))
        if [[ $OUTPUT == *error* ]]; then
            STATUS="Error"
        else
            STATUS="Success"
        fi
        echo "\"$CMD_LABEL\",$i,$RESPONSE_TIME,$STATUS" >> $BENCHMARK_FILE
        
        # Collect CPU metric
        CPU_UTIL=$(get_cpu_utilization)
        TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
        echo "$TIMESTAMP, $CPU_UTIL" >> $CPU_METRICS_FILE
    done
done

echo "Benchmark results saved to $BENCHMARK_FILE"
echo "CPU metrics saved to $CPU_METRICS_FILE"

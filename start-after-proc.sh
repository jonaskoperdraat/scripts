# This script waits for a given process to finish before starting another proces
#
# The PID of the process to wait for
pid=13202

# The timeout in seconds to wait between checks if the process is still active
timeout=60

# Wait for the process to finish.
while $(kill -0 ${pid}) ; do 
	echo $(date) Waiting for process to finish 
	sleep ${timeout};
done 

echo $(date) Starting next process.

# Run a command here
echo Running.

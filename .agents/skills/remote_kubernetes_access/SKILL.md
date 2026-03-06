---
name: Remote Kubernetes Cluster Access
description: Instructions on how to interact with our infrastructure which is hosted on an external VPS, avoiding local execution of kubectl.
---

# Remote Kubernetes Cluster Access

**CRITICAL INSTRUCTION**: Our infrastructure is hosted on an external VPS. Under NO circumstances should you attempt to run commands like `kubectl`, `helm`, or any other cluster management commands directly in the local terminal of this machine.

## Guidelines

1. **No Local Execution**: Do not run `kubectl <command>` directly on the user's machine. The local machine is NOT configured to access the cluster directly, and attempting to do so will fail or affect the wrong environment.
2. **External VPS**: The Kubernetes cluster (K3s) is running on remote VPS instances.
3. **Cluster Interaction**: If we need to execute commands on the cluster, we must SSH into the appropriate remote Server/VPS first, or ask the user to run the commands on the server and provide the outputs.
4. **Consulting this Skill**: Always refer to this skill before attempting any operation that modifies, interacts with, or queries the infrastructure.

If you need to check the status of pods, deployments, logs, or restart services (like keda-operator), remember this constraint and provide instructions for the user to execute on the external VPS.

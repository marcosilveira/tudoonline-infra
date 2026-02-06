#!/usr/bin/env python3
"""
Generate RabbitMQ queue definitions from helm-values-production.yaml
"""
import yaml
import json

# Read workers config
with open('k8s/helm-values-production.yaml', 'r') as f:
    values = yaml.safe_load(f)

workers = values.get('worker', {}).get('workers', [])

# Generate queue definitions
queues = []
for worker in workers:
    # Get queue name from KEDA triggers
    if worker.get('keda', {}).get('triggers'):
        for trigger in worker['keda']['triggers']:
            if trigger.get('type') == 'rabbitmq':
                queue_name = trigger['metadata'].get('queueName')
                if queue_name:
                    queues.append({
                        "name": queue_name,
                        "vhost": "production",
                        "durable": True,
                        "auto_delete": False,
                        "arguments": {
                            "x-queue-type": "classic"
                        }
                    })

# Create full definition
definition = {
    "rabbit_version": "3.11.9",
    "rabbitmq_version": "3.11.9",
    "queues": queues,
    "policies": [
        {
            "name": "ha-all",
            "pattern": ".*",
            "vhost": "production",
            "apply-to": "all",
            "definition": {
                "ha-mode": "all",
                "ha-sync-batch-size": 81920,
                "ha-sync-mode": "automatic"
            }
        }
    ]
}

# Output
print(json.dumps(definition, indent=2))
print(f"\n# Total queues: {len(queues)}", file=__import__('sys').stderr)

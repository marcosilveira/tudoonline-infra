#!/usr/bin/env python3
"""
Generate Kubernetes manifests for workers from helm-values-production.yaml
"""
import yaml
import sys

def generate_worker_manifests(values_file, output_file, image_tag='latest'):
    with open(values_file, 'r') as f:
        values = yaml.safe_load(f)
    
    workers = values.get('worker', {}).get('workers', [])
    defaults = values.get('worker', {}).get('defaults', {})
    namespace = values.get('namespace', 'production')
    
    manifests = []
    
    for worker in workers:
        name = f"{defaults.get('namePrefix', 'tudoonline-worker-')}{worker['name']}"
        
        # Deployment
        deployment = {
            'apiVersion': 'apps/v1',
            'kind': 'Deployment',
            'metadata': {
                'name': name,
                'namespace': namespace,
                'labels': {'app': name}
            },
            'spec': {
                'replicas': worker.get('replicaCount', 0),
                'selector': {'matchLabels': {'app': name}},
                'strategy': defaults.get('updateStrategy', {}),
                'template': {
                    'metadata': {
                        'labels': {'app': name},
                        'annotations': defaults.get('podAnnotations', {})
                    },
                    'spec': {
                        'serviceAccountName': defaults.get('serviceAccountName', 'default'),
                        'imagePullSecrets': defaults.get('imagePullSecrets', []),
                        'dnsConfig': defaults.get('dnsConfig', {}),
                        'affinity': worker.get('affinity', defaults.get('affinity', {})),
                        'schedulerName': defaults.get('schedulerName', 'default-scheduler'),
                        'containers': [{
                            'name': 'worker',
                            'image': f"{defaults.get('image', 'ghcr.io/marcosilveira/tudoonline-workers')}:{image_tag}",
                            'imagePullPolicy': 'Always',
                            'command': worker.get('command', []),
                            'args': worker.get('args', []),
                            'resources': worker.get('resources', {}),
                            'volumeMounts': [
                                {'name': p['name'], 'mountPath': p['mountPath']}
                                for p in worker.get('persistence', [])
                            ] if worker.get('persistence') else []
                        }],
                        'volumes': [
                            {'name': p['name'], 'persistentVolumeClaim': {'claimName': p['existingClaim']}}
                            for p in worker.get('persistence', [])
                        ] if worker.get('persistence') else []
                    }
                }
            }
        }
        manifests.append(deployment)
        
        # KEDA ScaledObject
        if worker.get('keda'):
            keda = worker['keda']
            scaled_object = {
                'apiVersion': 'keda.sh/v1alpha1',
                'kind': 'ScaledObject',
                'metadata': {
                    'name': name,
                    'namespace': namespace
                },
                'spec': {
                    'scaleTargetRef': {'name': name},
                    'pollingInterval': keda.get('pollingInterval', 30),
                    'cooldownPeriod': keda.get('cooldownPeriod', 300),
                    'minReplicaCount': keda.get('minReplicaCount', 0),
                    'maxReplicaCount': keda.get('maxReplicaCount', 10),
                    'triggers': keda.get('triggers', [])
                }
            }
            
            if keda.get('behavior'):
                scaled_object['spec']['advanced'] = {
                    'horizontalPodAutoscalerConfig': {
                        'behavior': keda['behavior']
                    }
                }
            
            manifests.append(scaled_object)
    
    # Write all manifests to file
    with open(output_file, 'w') as f:
        for i, manifest in enumerate(manifests):
            if i > 0:
                f.write('---\n')
            yaml.dump(manifest, f, default_flow_style=False, sort_keys=False)

if __name__ == '__main__':
    image_tag = sys.argv[1] if len(sys.argv) > 1 else 'latest'
    generate_worker_manifests(
        'k8s/helm-values-production.yaml',
        'k8s/workers.yaml',
        image_tag
    )
    print(f"Generated k8s/workers.yaml with image tag: {image_tag}")

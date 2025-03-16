# fraud-detection

This folder hast to be download and used in parallel with the original fraud-detection guide, <https://github.com/rh-aiservices-bu/fraud-detection>, as it extends it.

## Prerequisites

1. Openshift AI, Openshift Service Mesh and Openshift Serverless installed
2. Openshift AI DataScienceCluster set up to enable Kserve. Example:
```apiVersion: datasciencecluster.opendatahub.io/v1
kind: DataScienceCluster
metadata:
  name: rhods
  labels:
	app.kubernetes.io/name: datasciencecluster
	app.kubernetes.io/instance: rhods
	app.kubernetes.io/part-of: rhods-operator
	app.kubernetes.io/managed-by: kustomize
	app.kubernetes.io/created-by: rhods-operator
spec:
  components:
	codeflare:
  	managementState: Managed
	dashboard:
  	managementState: Managed
	datasciencepipelines:
  	managementState: Managed
	kserve:
  	serving:
    	ingressGateway:
      	certificate:
        	type: SelfSigned
    	managementState: Managed
    	name: knative-serving
  	managementState: Managed
	modelmeshserving:
  	managementState: Managed
	ray:
  	managementState: Managed
	trustyai:
  	managementState: Managed
	workbenches:
  	managementState: Managed
```
3. Openshift Sandboxed Containers installed with CoCo enabled
4. Trustee operator installed
5. Trustee operator has to contain a key stored as a Secret. The storage initializer running in the model will perform attestation to get the key defined in the env `KBS_PATH`, but otherwise it will default to `kbsres1/key.bin`. The `KBS_PATH` env simply defines `secret/file_name`, so `kbsres1/key.bin` simply means secret called `kbsres1` which has `key.bin` as content.


## Deployment step by step
To better understand and try one thing at the time, we will deploy

1. The fraud detection demo as-is
2. The fraud detection in CoCo with plaintext model
3. The fraud detection in CoCo with encrypted model (attestation)

### Run the demo as-is

Follow this workshop Instructions: <https://rh-aiservices-bu.github.io/fraud-detection/>. Skip point 5. Data Science Pipelines and 6. Distributed Training.

#### Note:
If you get SSL connection errors when deploying the pod, then you need to disable SSL.

1. Write down your project name (example `fraud-detection`)
2. If you plan to change the yaml (not using the web UI): Convert the following template string in `base64`: `http://minio.<project-name>.svc.cluster.local:9000` (example `base64` for http://minio.fraud-detection.svc.cluster.local:9000 is `aHR0cDovL21pbmlvLmZyYXVkLWRldGVjdGlvbi5zdmMuY2x1c3Rlci5sb2NhbDo5MDAw`)
3. In the web UI go in namespace <project name> and in secrets/aws-connection-my-storage and then do `Edit` and change `AWS_S3_ENDPOINT` to be your string obtained in the previous step. If you edit the yaml, you need to add the `base64` version of the url, otherwise in the web ui you can also add the plain text.

### Run the plain text model in a confidential container

First of all, enable runtimeClass change in Kserve:
```
oc edit cm -n knative-serving config-features
```
and add the following:
```
data:
  kubernetes.podspec-runtimeclassname: enabled
```

Optional for this example but higly recommended: delete the plaintext model uploaded in the minio storage.

Then, run `1b_encrypt_model.ipynb` provided in this folder, to encrypt the model.

Run again `fraud-detection/2_save_model.ipynb`, to be sure the encrypted model is uploaded.

Once the fraud-detection demo as-is is fully running, try modifying the InferenceService:
```
oc edit inferenceservices/<your-model-name> -n <your-project-name>
```
And add the following:
```
spec:
  predictor:
    runtimeClassName: kata-remote
```
In addition, you can also add a policy to be able to exec,log, or perform only certain exec commands. Refer to this link for more informations: https://esposem.github.io/osc-demo-showroom/modules/03-deploy-workload.html#options

A new deployment should be created in <your-project-name> ns, and you will see that the pod is running with `kata-remote`.

### Add attestation

Now add the custom kserve storage initializer to be able to pull an encrypted model
```
oc edit configmaps/inferenceservice-config -n redhat-ods-applications
```
And change the storage-initializer to either the default storage-initializer, or a custom one you can build in `../kserve-storage-initialzer`
```
storageInitializer: |-
    {
        "image" : "quay.io/eesposit/kserve-storage-initializer:latest
```

Once the fraud-detection demo as-is is fully running, try modifying the InferenceService:
```
oc edit inferenceservices/<your-model-name> -n <your-project-name>
```

And add the following (assumes that `kata-remote` is already present from the previous step):
```
spec:
  predictor:
    model:
      env:
        - name: KBS_PATH
          value: <secret_name>/<key_name>
```

A new deployment should be created in <your-project-name> ns, and you will see that the pod is running with the new storage intializer.

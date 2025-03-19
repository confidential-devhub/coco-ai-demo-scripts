# fraud-detection

This folder hast to be download and used in parallel with the original fraud-detection guide, <https://github.com/rh-aiservices-bu/fraud-detection>, as it extends it.

## Prerequisites

1. Openshift AI, Openshift Service Mesh and Openshift Serverless installed
2. Openshift AI DataScienceCluster set up to enable Kserve. The goal is that when deploying a model server, the "Single model server" option is available. An example is located in `../setup/oai-datasciencecluster.yaml`. Official guide is here: https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/2.13/html-single/serving_models/index#about-the-single-model-serving-platform_serving-large-models
3. Openshift Sandboxed Containers installed with CoCo enabled
4. Trustee operator installed
5. Trustee operator has to contain a key stored as a Secret (and the key has to be added in `KbsConfig`). The storage initializer running in the model will perform attestation to get the key defined in the env `MODEL_DECRYPTION_KEY`, but otherwise it will default to `model-keys/model-name.key`. The `MODEL_DECRYPTION_KEY` env simply defines `secret/file_name`, so `model-keys/model-name.key` simply means secret called `model-keys` which has `model-name.key` as content.

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

Optional for this example but higly recommended: delete the plaintext model uploaded in the minio storage.

Then, run `1b_encrypt_model.ipynb` provided in this folder, to encrypt the model. This file requires that `fraud-detection` original demo repo has also been cloned in the workbench.

Run again `fraud-detection/2_save_model.ipynb`, to be sure the encrypted model is uploaded.

Now, we need to change the `kserve-storage-initializer`. This is an init container in Kserve that takes care of downloading the model from the remote storage and putting it in a specific directory in the container, so that the main container can find it and run it.

Because the model is now encrypted, we need to extend the kserve-storage-initializer to know how to fetch the key from Trustee, and how to decrypt the model.

In order to change the default initializer, we need to create a `ClusterStorageContainer`. In this container, we specify which storage initializer image to use, and which Uri formats we want to replace. An example of `ClusterStorageContainer` is in `../setup/coco-csi.yaml`. Modify that file as needed, specifying the env variables to match the chosen secret in trustee, type of model and so on.

For this example, use the following variables:
```
    env:
      - name: MODEL_ENCRYPTED # wether to decrypt the model or not
        value: "true"
      - name: MODEL_DECRYPTION_KEY # path to the secret/file in Trustee
        value: "secret/key_file" # TODO: insert your own value!
      - name: MODEL_NAME # name of the model, without format
        value: "model"
      - name: MODEL_FORMAT # format of the model
        value: "onnx"
```

The provided `ClusterStorageContainer` refers to the pre-built `quay.io/confidential-devhub/coco-storage-initializer:rhoai-2.16` image. If you want to create your own, refer to the [confidential-devhub kserve-storage-initializer](https://github.com/confidential-devhub/kserve/blob/coco-v0.12.1/python/storage-initializer.Dockerfile). Note that the way `supportedUriFormats` inside the CSC is set, any model fetched from `s3` will use that storage initializer.

If you want this `ClusterStorageContainer` to only refer the specific `models/fraud` bucket, then change `supportedUriFormats` to point only to that:
```
  supportedUriFormats:
    - prefix: 's3://my-storage/models/fraud'
```

Then restart the fraud-detection model server deployment in <your-project-name> ns, and you will see that the pod is running with the new storage intializer.

# Dataprovider Agent

<!-- TOC -->
- [Dataprovider Agent](#dataprovider-agent)
  - [Description](#description)
  - [Prerequisites](#prerequisites)
    - [Tools](#tools)
    - [DNS entries](#dns-entries)
  - [Deployment](#deployment)
    - [Preliminary tasks](#preliminary-tasks)
      - [OpenBao related tasks](#openbao-related-tasks)
        - [Secret for Infrastructure-be](#secret-for-infrastructure-be)
        - [Secret for simpl-edc](#secret-for-simpl-edc)
    - [Deployment using ArgoCD](#deployment-using-argocd)
    - [Manual deployment](#manual-deployment)
      - [Files preparation](#files-preparation)
      - [Deployment Command to execute](#deployment-command-to-execute)
    - [Verification of deployment](#verification-of-deployment)
  - [Additional steps and remarks](#additional-steps-and-remarks)
    - [Onboarding](#onboarding)
    - [Tier2-proxy status](#tier2-proxy-status)
    - [Monitoring](#monitoring)
  - [Troubleshooting](#troubleshooting)
  - [FAQ](#faq)
<!-- /TOC -->

## Description

This repo contains:

- a master helm chart allowing to deploy a *Dataprovider* agent using a single command.
- templates of values.yaml files used inside *Integration* environment under `app-values` folder

## Prerequisites

### Tools

| Pre-Requisites      |     Version     | Description  |
|:-------------------:|:---------------:|:------------:|
| DNS sub-domain name    |       N/A       | This domain will be used to address all services of the agent. <br/> example: `*.dataprovider01.example.com` |
| external-dns    | 0.16.1 or newer | Used for DNS entries creation. <br/> Other version *might* work but tests were performed using 0.16.1-debian-12-r6 version. <br/> Image used: `docker.io/bitnamilegacy/external-dns:0.16.1-debian-12-r6` |  
| Kubernetes Cluster  | 1.29.x or newer | Other version *might* work but tests were performed using 1.29.x version                                                                                                                     |
| nginx-ingress       | 1.10.x or newer | Used as ingress controller. <br/> Other version *might* work but tests were performed using 1.10.x version. <br/> Image used: `registry.k8s.io/ingress-nginx/controller:v1.10.0`          |
| cert-manager        | 1.15.x or newer | Used for automatic cert management. <br/> Other version *might* work but tests were performed using 1.15.x version. <br/> Image used: `quay.io/jetstack/cert-manager-controller:v1.15.3`    |
| nfs-provisioner     | 4.0.x or newer  | Backend for *Read/Write many* volumes. <br/> Other version *might* work but tests were performed using 4.0.x version. <br/> Image used: `registry.k8s.io/sig-storage/nfs-provisioner:v4.0.8` |
| argocd              | 2.11.x or newer | Used as GitOps tool . App of apps concept. <br/> Other version *might* work but tests were performed using 2.11.x version. <br/> Image used: `quay.io/argoproj/argocd:v2.11.3`            |

### DNS entries

If you're not using external-dns, you will need to add the following dns entries manually.

| Entry Name | Entries |
| ------------- | --------------------------------------------------------------------------------------------------- |
| catalogue-ui           | catalogue-ui.(namespaceTag).(domainSuffix) |
| gitea-http             | gitea.crossplane.(namespaceTag).(domainSuffix) |
| infrastructure-argo-cd-server | argoui.crossplane.(namespaceTag).(domainSuffix) |
| infrastructure-argo-workflows-server | argoworkflows.crossplane.(namespaceTag).(domainSuffix) |
| infrastructure-be | infrastructure-be.(namespaceTag).(domainSuffix) |
| infrastructure-fe-frontend | infrastructure-fe.(namespaceTag).(domainSuffix) |
| redis-commander     | redis-commander.(namespaceTag).(domainSuffix) |
| sd-ui                  | sd-ui.(namespaceTag).(domainSuffix) |
| simpl-fe-authentication-provider | participant.fe.(namespaceTag).(domainSuffix)/participant-utility |
| simpl-fe-users-roles             | participant.fe.(namespaceTag).(domainSuffix)/users-roles         |
| simpl-files            | files.(namespaceTag).(domainSuffix) |
| simpl-ingress          | participant.be.(namespaceTag).(domainSuffix) |
| tier2-gateway          | tls.participant.(namespaceTag).(domainSuffix) |

## Deployment

The deployment is based on master helm chart which, when applied on Kubernetes cluster, should deploy the Data Provider to it using ArgoCD.

### Preliminary tasks

#### OpenBao related tasks

You can access OpenBao on <https://secrets.**commonnamespacetag**.**domainSuffix**>
Root token can be found in common namespace, secret secrets-root-token, in key token.

The description of using OpenBao is in a separate document:

<https://code.europa.eu/simpl/simpl-open/development/agents/common_components/-/blob/main/documents/user-manual/Using_OpenBao.md>

Before you proceed with the next steps related to accessing your OpenBao and changing its contents, please read the document above.<BR>

##### Secret for Infrastructure-be

Edit the key for Infrastructure-be named "*dataprovider01*-infrastructure-be" where the first part reflects the namespace of your dataprovider. 

You can only request the token after the provider is deployed, so after you've changed the values in the secret, you need to restart the infrastructure-be pod. 
To get the value for gitea.token, you can execute the following command. Replace the values in brackets with variables from your Dataprovider deployment.

```bash
curl -X POST "https://gitea.crossplane.(namespaceTag).(domainSuffix)/api/v1/users/(gitea.username)/tokens" \
  -u (gitea.username):(gitea.password) \
  -H "Content-Type: application/json" \
  -d '{
    "name": "token-name",
    "scopes": ["all"]
  }'
```

After the command is processed you will get a result like this:
```bash
{"id":3,"name":"token-name","sha1":"(giteatoken)","token_last_eight":"example","scopes":null}
```
Put in the secret below the value of the "sha1" key. 

In the secret, you need to modify or add:

| Variable name                   |     Example                | Description                   |
| ----------------------          |     :-----:                | ---------------               |
| gitea.token                     | giteatoken                 | Token to access gitea         |

##### Secret for simpl-edc

Edit the key for Infrastructure-be named "*dataprovider01*-simpl-edc" where the first part reflects the namespace of your dataprovider. You need to provide endpoint and keys to your Minio.

You need to modify:

| Variable name                    |     Example              | Description              |
| ----------------------           |     :-----:              | ---------------          |
| fr_gxfs_s3_access_key            | minioacckey              | minio access key (fr.gxfs S3) |
| fr_gxfs_s3_endpoint              | https://minio.address.eu | minio api address (fr.gxfs S3) |
| fr_gxfs_s3_secret_key            | minioseckey              | minio secret key (fr.gxfs S3) |
| AWS_ACCESS_KEY_ID                | AKIA...                  | AWS S3 data-plane access key (AWS SDK) |
| AWS_SECRET_ACCESS_KEY            | wJalr...                 | AWS S3 data-plane secret key (AWS SDK) |
| AWS_REGION                       | eu-west-1                | AWS S3 region (AWS SDK) |

> **Fuente única:** estos campos deben sembrarse en el secret `<namespace>-edc-s3-credentials` de
> OpenBao **antes de desplegar el participante**. El `openbao-seeder` los copia automáticamente a
> `<namespace>-simpl-edc`, que es de donde el deployment de simpl-edc los lee (`source config.txt`).
> Cada campo se copia solo si existe en el origen. (El data-provider no usa `AWS_PROVISION_STS_ROLE_ARN`.)

All the other necessary secrets are now created automatically with proper data.

### Deployment using ArgoCD

You can easily deploy the agent using ArgoCD. All the values mentioned in the sections below you can input in ArgoCD deployment. The repoURL gets the package directly from code.europa.eu.
targetRevision is the package version.

In the example below, please replace the marked versions with the ones applicable to your environment.

Please pay special attention to the namespace names and replace them with yours: common01, authority01, and dataprovider01, and also to replace the domain name example.com and the occurrence of the test-int value itself.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: 'dataprovider01-deployer'           # name of the deploying app in argocd
spec:
  project: default
  source:
    repoURL: 'https://code.europa.eu/api/v4/projects/904/packages/helm/stable'
    path: '""'
    targetRevision: 3.0.0                   # version of package
    helm:
      values: |
        values:
          branch: v3.0.0                    # branch of repo with values - for released version it should be the release branch
        project: default
        namespaceTag:
          dataprovider: dataprovider01      # identifier of deployment and part of fqdn for this agent
          authority: authority01            # identifier of deployment and part of fqdn for authority
          common: common01                  # identifier of deployment and part of fqdn for common components
        domainSuffix: example.com           # last part of fqdn
        resourcePreset: default             # set to "low" to disable requests of resources
        argocd:
          appname: dataprovider01           # name of generated argocd app 
          namespace: argocd                 # namespace of your argocd
        cluster:
          address: https://kubernetes.default.svc
          namespace: dataprovider01         # where the app will be deployed
          commonToolsNamespace: common01    # namespace where main monitoring stack is deployed
          issuer: dev-prod                  # issuer of certificates
        secrets:
          role: example-role                # role created in OpenBao for access
          secretEngine: example             # secret engine name created in OpenBao
        crossplane:
          enabled: true                     # if infrastructure components should be deployed (there can be only one instance per cluster)
          kafka:
            username: user                  # name should be: namespace_infrabe e.g.: dataprovider01_infrabe
            password: pass                  # take the password from common01-kafka-credentials OpenBao secret, key dataprovider01_infrabe
          gitea:
            username: gitops_test           # username of gitea
            password: pass                  # password of gitea - the variable can take on any value (set it to your preference)
        monitoring:
          enabled: true                     # should monitoring be enabled
    chart: data-provider
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: dataprovider01               # where the package will be deployed
```

### Manual deployment

#### Files preparation

Another way for deployment, is to unpack the released package to a folder on a host where you have kubectl and helm available and configured.

There is basically one file that you need to modify - values.yaml.
There are a couple of variables you need to replace - described below. The rest you don't need to change.

```yaml
values:
  branch: v3.0.0                    # branch of repo with values - for released version it should be the release branch
project: default
namespaceTag:
  dataprovider: dataprovider01      # identifier of deployment and part of fqdn for this agent
  authority: authority01            # identifier of deployment and part of fqdn for authority
  common: common01                  # identifier of deployment and part of fqdn for common components
domainSuffix: example.com           # last part of fqdn
resourcePreset: default             # set to "low" to disable requests of resources
argocd:
  appname: dataprovider01           # name of generated argocd app 
  namespace: argocd                 # namespace of your argocd
cluster:
  address: https://kubernetes.default.svc
  namespace: dataprovider01         # where the app will be deployed
  commonToolsNamespace: common01    # namespace where main monitoring stack is deployed
  issuer: dev-prod                  # issuer of certificates
secrets:
  role: example-role                # role created in OpenBao for access
  secretEngine: example             # secret engine name created in OpenBao
crossplane:
  enabled: true                     # if infrastructure components should be deployed (there can be only one instance per cluster)
  kafka:
    username: dataprovider01_infrabe # name should be: namespace_infrabe e.g.: dataprovider01_infrabe
    password: pass                  # take the password from common01-kafka-credentials OpenBao secret, key dataprovider01_infrabe
  gitea:
    username: gitops_test           # username of gitea
    password: pass                  # password of gitea - the variable can take on any value (set it to your preference)
monitoring:
  enabled: true                     # should monitoring be enabled
```

#### Deployment Command to execute

After you have prepared the values file, you can start the deployment.
Use the command prompt. Proceed to the folder where you have the Chart.yaml file and execute the following command. The dot at the end is crucial - it points to current folder to look for the chart.

Now you can deploy the agent:

`helm install data-provider .`

After starting the deployment synchronization process, the expected applications in ArgoCD will be created.

### Verification of deployment

Initially, the status observed e.g. in ArgoCD will indicate the creation of new pods:

<img src="images/dataprovider_ArgoCD01.png" alt="ArgoCD01" width="600"><BR>

Be patient!... Depending on the configuration, this step can take up to 30 minutes!

At the end, all pods should be created correctly:

<img src="images/dataprovider_ArgoCD02.png" alt="ArgoCD02" width="600"><BR>

## Additional steps and remarks

### Onboarding

After the deployment process is complete, a manual onboarding process of the participant is required.

The steps are described in the document:
https://code.europa.eu/simpl/simpl-open/development/iaa/documentation/-/blob/main/versioned_docs/2.5.x/user-manual/ONBOARD.md

### Identity attributes of the roles

Once onboarding is complete, the CronJob `role-identity-attributes` adds the configured identity
attributes to the roles of the participant (the same as ticking them in
`participant-fe-<namespace>.<domain>/users-roles/role` and saving):

| Role | Identity attributes added |
|---|---|
| SD_PUBLISHER | DATA_PROVIDER_PUBLISHER, EDVAL_PARTICIPANT |
| SD_CONSUMER | DATA_SEARCHER, EDVAL_PARTICIPANT |

It runs every 5 minutes and does nothing until the participant has those attributes (i.e. until
onboarding has finished). It only adds attributes, never removes those already in the role. When it is
done it records it in the ConfigMap `role-identity-attributes-state` and later runs exit immediately.

- Logs: `kubectl -n <namespace> logs job/<last role-identity-attributes-... job>`
- Run it again: `kubectl -n <namespace> delete configmap role-identity-attributes-state`
- Change the mapping or disable it: `roleIdentityAttributes.mapping` / `roleIdentityAttributes.enabled`
  in the chart values (a new mapping is applied automatically).

### Tier2-proxy status

Please keep in mind that until the agent is properly initialized, the tier2-proxy component will not work properly.

### Monitoring

Filebeat components for monitoring are included in this release.
Their deployment can be disabled by switching the value monitoring.enabled to false.

## Troubleshooting

If you encounter issues during deployment, check the following:

- Ensure that ArgoCD is properly set up and running.
- Verify that the namespace exists in your Kubernetes cluster.
- Check the ArgoCD application logs and Helm error messages for specific issues.

## FAQ

1. `How do I install the SuperAdmin certificate in my browser?`
    1. Download the SuperAdmin certificate in PKCS#12 (*.p12) format.
    2. Follow browser-specific steps to import the certificate: [Example for Firefox](https://docs.keyfactor.com/ejbca-cloud/latest/import-certificate-to-mozilla-firefox)
    3. Restart the browser if the certificate is not immediately recognized.
2. `What is the purpose of the ManagementCA certificate, and how can I obtain it?`
    1. The ManagementCA certificate is used as the truststore for secure communications.
    2. Download it from the Admin Dashboard under CA Structure & CRL.
    3. Save the file in JKS format and securely store the password used during download.
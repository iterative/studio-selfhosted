# studio-selfhosted-terraform
Terraform configurations for Studio Selfhosted 

## Pre-flight Checklist

You'll need the following things before kicking off the installation:
- [AWS CLI (version >= 2.0.0)](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
   - Must be configured with a valid set of credentials that can provision AWS resources
- [Terraform (version >= 1.0.0)](https://developer.hashicorp.com/terraform/downloads?product_intent=terraform)
- Optional: A TLS certificate - bring your own or create one by [following the example](https://github.com/iterative/helm-charts#prepare-a-tls-secret)



## Deployment

### Prepare some global variables to substitute

1. Create an S3 bucket for Terraform states

    Open AWS Console in a browser, create a new private S3 bucket.
    Make a note of the bucket name.

2. Templating necessary variables:
   Using the S3 bucket you created in the first step, run the following script
   to template required variables in the tf files before proceeding:

   ```shell
   TF_BUCKET="iterative-studio-terraform" \
     ADMIN_IAM_ROLE="arn:aws:sts::123456789123:assumed-role/role_name/account" \
     CLUSTER_NAME="iterative-studio" \
     VPC_NAME="iterative-studio" \
     CREATE_VPC=true \
     AWS_REGION="us-east-2" \
     ./subst_vars.sh
   ```

3. Optional steps:
   - Set `CREATE_VPC=false` in the command above to use an existing VPC with
   the name given in `VPC_NAME`.
   - If you want your automatically created VPC to have a specific CIDR, edit `vpc_cidr` in `studio/terraform.tfvars` 

4. Create the EKS cluster with Terraform

    ```shell
    $ cd eks-cluster
    $ terraform init
    $ terraform apply --auto-approve
    ```

5. Download the configuration for the newly-created EKS cluster

    ```shell
    $ EKS_CLUSTER_ARN=$(aws eks update-kubeconfig --region <AWS region> --name <EKS cluster name> | grep -Po "arn:[^\s]*")
    $ kubectl config use-context "$EKS_CLUSTER_ARN"
    ```

    Replace `<AWS region>` and `<EKS cluster name>` with values that you set previously.

6. Create a Kubernetes namespace for Studio

    ```shell
    $ kubectl create namespace studio
    ```

7. Create a Kubernetes Secret containing your Iterative Docker registry credentials

    ```shell
    $ kubectl create secret docker-registry iterativeai \
        --namespace studio \
        --docker-server="docker.iterative.ai" \
        --docker-username="<username>" \
        --docker-password="<password>"
     ```

    Replace `<username>` and `<password>` with the credentials that you have received.

8. Optional: Create a Kubernetes Secret containing your TLS certificate and private key
This is relevant if you have a known registered domain with a valid cert.
If that's not the case you can add this later with a self-signed cert
created for the NLB address that will be auto-generated.
    ```shell
    $ kubectl create secret tls studio-ingress-tls \
      --namespace studio \
      --cert=<tls certificate filename> \
      --key=<tls private key filename>
    ```

    Replace `<tls certificate filename>` and `<tls private key filename>` with paths to your files.
9. Deploy the NGINX ingress controller (using AWS NLB)

    ```shell
    $ cd $(git rev-parse --show-toplevel)
    $ cd ingress-controller
    $ terraform init
    $ terraform apply --auto-approve
    ```

   If installation was completed successfully, you should be able to see the helm deployment
   with a "deployed" status:
   
   ```shell
   $ helm -n ingress-nginx ls
   NAME         	NAMESPACE    	REVISION	UPDATED                             	STATUS  	CHART              	APP VERSION
   ingress-nginx	ingress-nginx	1       	2023-01-29 17:56:34.157425 +0200 IST	deployed	ingress-nginx-4.4.2	1.5.1   ```
   ```
10. Extract the NLB external address:
   ```shell
   $ kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
   ```
   We'll need the output of the above to configure Studio in the next step.

11. Edit `studio/values/studio.yaml` with your Studio settings.
You'll need to configure an external hostname studio will be accessible in `global.host`.
If you are planning to use a custom DNS (have a known domain) - use it and set the A
record with your DNS service to ALIAS the NLB hostname you extracted above.
If you did not register a domain, and don't plan to, use the address extracted in the 
last step directly as the address.

12. Deploy Studio

    ```shell
    $ cd $(git rev-parse --show-toplevel)
    $ cd studio
    $ terraform init
    $ terraform apply --auto-approve
    ```

   If installation was completed successfully, you should be able to see the helm deployment
   with a "deployed" status:
   
   ```shell
   ❯ helm -n studio ls
   NAME  	NAMESPACE	REVISION	UPDATED                             	STATUS  	CHART        	APP VERSION
   studio	studio   	1       	2023-01-29 15:22:34.373947 +0200 IST	deployed	studio-0.1.14	v1.41.3
   ```

13. Further configuration - If you need to further re-configure studio, you can iterate on 
running `terraform apply --auto-approve` in the `helm` subdirectory.

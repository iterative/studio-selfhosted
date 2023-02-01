# Studio Selfhosted AMI

This AMI contains K3s along with a preconfigured ingress-nginx reverse proxy. 

## Studio Installation
To deploy Studio please:
1. Run instance with AMI, 
2. Open on Security Group ports: 22, 80, 443(if https is needed),
3. Login though ssh to the instance,
3. Proceed with the instructions of [Studio helm chart](https://github.com/iterative/helm-charts), how tu configure and install the Studio.

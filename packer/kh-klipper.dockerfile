FROM rancher/klipper-helm:v0.7.7-build20230403

RUN helm_v3 repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
RUN helm_v3 pull ingress-nginx/ingress-nginx --version 4.6.0
RUN tar -zxvf ingress-nginx-4.6.0.tgz

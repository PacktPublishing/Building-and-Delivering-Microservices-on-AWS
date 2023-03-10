aws eks update-kubeconfig --name chap-14-eks-cluster --region us-east-1
kubectl get configmaps aws-auth -n kube-system -o yaml > aws-auth.yaml
kubectl apply -f aws-auth.yml
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 279522866734.dkr.ecr.us-east-1.amazonaws.com

eksctl create iamidentitymapping \
    --cluster chap-14-eks-cluster \
    --region us-east-1 \
    --arn arn:aws:iam::279522866734:role/chap-14-codebuild-eks-role \
    --group system:masters \
    --no-duplicate-arns \
    --username chap-14-codebuild-eks-role


eksctl create iamidentitymapping \
    --cluster chap-14-eks-cluster \
    --region us-east-1 \
    --arn arn:aws:iam::279522866734:user/console_user \
    --group system:masters \
    --no-duplicate-arns \
    --username console_user


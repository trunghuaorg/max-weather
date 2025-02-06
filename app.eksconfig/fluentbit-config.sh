echo "Please provide the AWS profile that will be used to provision the infrastructure."
read awsprofile
echo "Please provide the AWS region."
read awsregion
echo "Please provide the EKS Cluster name."
read eksclustername

echo "Create the logs deamon namespace"
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cloudwatch-namespace.yaml

FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
kubectl create configmap fluent-bit-cluster-info \
--from-literal=cluster.name=${eksclustername} \
--from-literal=http.server=${FluentBitHttpServer} \
--from-literal=http.port=${FluentBitHttpPort} \
--from-literal=read.head=${FluentBitReadFromHead} \
--from-literal=read.tail=${FluentBitReadFromTail} \
--from-literal=logs.region=${awsregion} -n amazon-cloudwatch

echo "Apply the Fluent bit"
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluent-bit/fluent-bit.yaml

echo "Validating the config"
kubectl get pods -n amazon-cloudwatch

echo "Running provision OIDC"
eksctl utils associate-iam-oidc-provider --region=$awsregion --cluster=$eksclustername --profile $awsprofile --approve

eksctl create iamserviceaccount \
    --name fluent-bit \
    --namespace amazon-cloudwatch \
    --cluster $eksclustername \
    --attach-policy-arn "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy" \
    --approve \
    --override-existing-serviceaccounts \
    --profile $awsprofile \
    --region $awsregion \

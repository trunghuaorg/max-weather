echo "Please review the Terraform output to provide the required input fields."
echo "Please provide the AWS profile that will be used to provision the infrastructure."
read awsprofile
echo "Please provide the AWS region."
read awsregion
echo "Please provide the EKS Cluster name."
read eksclustername

AWS_USER_ARN=$(aws sts get-caller-identity --profile $awsprofile | jq -r '.Arn')
AWS_USERNAME=$(echo "$AWS_USER_ARN" | sed 's|.*/||')
TYPE_ACCESS=cluster
POLICY_ARN=arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy

echo "Configurations"
echo "\n AWS_USER_ARN = $AWS_USER_ARN \
\n AWS_USERNAME = $AWS_USERNAME \
\n CLUSTER_NAME = $eksclustername \
\n AWS_PROFILE = $awsprofile"


#create the resources to access
echo "Grant the access to eks cluster"

aws eks create-access-entry --cluster-name $eksclustername --principal-arn $AWS_USER_ARN  --type STANDARD --user $AWS_USERNAME --kubernetes-groups Viewers --profile $awsprofile --region $awsregion

aws eks associate-access-policy --cluster-name $eksclustername --profile $awsprofile --region $awsregion --principal-arn $AWS_USER_ARN  --access-scope type=cluster --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy


#update the kubeconfig
aws eks update-kubeconfig --region $awsregion --profile $awsprofile --name $eksclustername

echo "Verifying the eks cluster"
kubectl config current-context | grep $eksclustername  | wc -l
kubectl get namespace -A
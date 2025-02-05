echo "please provide terraform workspace"
read tfwf
terraform workspace new $tfwf
terraform workspace select $tfwf
current_tfwsp=$(terraform workspace show)
terraform init -backend-config=dev.conf
terraform plan -var-file=envs/${current_tfwsp}.tfvars
echo "do you want apply the infra ? (yes) to continue"
read tfapply
if [[ $tfapply == "yes" ]]; then 
    terraform apply -var-file=envs/${current_tfwsp}.tfvars
    echo "Please follow the terminal output to verify the result of infrastructure provisioning."
else
    echo "Cancel apply for infra"
fi
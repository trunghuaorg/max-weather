#!/bin/bash
destroy_infa() {
    echo "Please provide the terraform workspace"
    read tfwf 
    #verify that the terraform workspace is exits or not ?
    x=$(terraform workspace list  | grep ${tfwf}  | wc -l)
    if [ $x -ne 1 ]; then
        echo "The workspace is not exits."
        exit 1
    else 
        terraform workspace select ${tfwf}
    fi
    terraform workspace show
    
    if [ -f "$(pwd)/envtfvars/${tfwf}.tfvars" ]; then
        echo "The tfvars file is exits. Destroy the infra ? (yes) to continue."
        read isapply
        if [[ $isapply == "yes" ]]; then 
            terraform destroy -var-file="$(pwd)/envtfvars/${tfwf}.tfvars" -auto-approve
            echo "Please follow the console to verify the result!"
        fi
    else
        echo "Cancel destroy infra. Exit"
        exit 0
    fi 
}

provisiong_inf() {

    echo "Please provide the terraform workspace"
    read tfwf 
    echo "verify that the terraform workspace is exits or not ?"
    x=$(terraform workspace list  | grep ${tfwf}  | wc -l)
    if [ $x -ne 1 ]; then
        echo "The workspace is not exits. Creating the workspace"
        terraform workspace new ${tfwf}
        terraform workspace select ${tfwf}
    else 
        terraform workspace select ${tfwf}
    fi
    terraform workspace show

    #verify the tfvars is exits or not ?
    if [ -f "$(pwd)/envtfvars/${tfwf}.tfvars" ] && [ -f "$(pwd)/tfwpconfigs/${tfwf}.conf" ]; then
        echo "The tfvars and backend config file is exits. Running verify and apply the infrastructure"
        terraform init -backend-config="$(pwd)/tfwpconfigs/${tfwf}.conf" -reconfigure -cloud=false
        terraform plan -var-file="$(pwd)/envtfvars/${tfwf}.tfvars"

        echo "Apply the infrastructure ? (yes) to apply."
        read isapply
        if [[ $isapply == "yes" ]]; then 
            terraform apply -var-file="$(pwd)/envtfvars/${tfwf}.tfvars" -auto-approve
            echo "Please follow the console to verify the result!"
        else
            echo "Cancel apply. Exit"
            exit 0
        fi

    else
        echo "The tfvars file is not exits for ${tfwf} workspace. Plese create the tfvars for ${tfwf} workspace"
        echo "Deleting the workspace ${tfwf}"
        terraform workspace select default
        terraform workspace delete ${tfwf}
        exit 1
    fi
}

echo "Please selection the menu"
menu=("(1)-Provsionin_Infra" "(2)-Destroy_Infra")
for str in ${menu[@]}; do
    echo $str
done
read menu
case $menu in 
    1)
        echo "Provisioning Infra"
        provisiong_inf
        ;;
    2)
        echo "Destroy Infra"
        destroy_infa
        ;;
    *)
        echo "Please select the menu"
        ;;
esac
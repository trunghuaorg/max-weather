#!/bin/bash

set -e

REGION="eu-west-1"
PREFIX="u58"  # Sửa nếu cần dùng tên khác

echo "⚠️ BẠN SẮP XÓA TOÀN BỘ HẠ TẦNG AWS (prefix: $PREFIX, region: $REGION)"
read -p "Bạn có chắc chắn? (y/N): " CONFIRM
if [[ "$CONFIRM" != "y" ]]; then
  echo "❌ Hủy bỏ."
  exit 1
fi

echo "🚨 BẮT ĐẦU QUÁ TRÌNH DỌN DẸP AWS..."

## EC2 INSTANCES
INSTANCE_IDS=$(aws ec2 describe-instances --region $REGION \
  --filters "Name=tag:Name,Values=*$PREFIX*" \
  --query "Reservations[*].Instances[*].InstanceId" --output text)

if [ -n "$INSTANCE_IDS" ]; then
  echo "💣 Đang terminate EC2 instances: $INSTANCE_IDS"
  aws ec2 terminate-instances --instance-ids $INSTANCE_IDS --region $REGION
fi

## EKS CLUSTERS
CLUSTERS=$(aws eks list-clusters --region $REGION --query "clusters[?contains(@, '$PREFIX')]" --output text)
for CLUSTER in $CLUSTERS; do
  echo "🧨 Xóa EKS cluster: $CLUSTER"
  aws eks delete-cluster --name $CLUSTER --region $REGION
done

## CLOUDFORMATION
STACKS=$(aws cloudformation list-stacks --region $REGION \
  --query "StackSummaries[?contains(StackName, '$PREFIX') && StackStatus!='DELETE_COMPLETE'].StackName" --output text)

for STACK in $STACKS; do
  echo "📦 Xóa CloudFormation Stack: $STACK"
  aws cloudformation delete-stack --stack-name $STACK --region $REGION
done

## LOAD BALANCERS
LB_ARNs=$(aws elbv2 describe-load-balancers --region $REGION \
  --query "LoadBalancers[?contains(LoadBalancerName, '$PREFIX')].LoadBalancerArn" --output text)

for ARN in $LB_ARNs; do
  echo "🧨 Xóa LoadBalancer: $ARN"
  aws elbv2 delete-load-balancer --load-balancer-arn $ARN --region $REGION
done

## TARGET GROUPS
TG_ARNs=$(aws elbv2 describe-target-groups --region $REGION \
  --query "TargetGroups[?contains(TargetGroupName, '$PREFIX')].TargetGroupArn" --output text)

for TG in $TG_ARNs; do
  echo "🧯 Xóa Target Group: $TG"
  aws elbv2 delete-target-group --target-group-arn $TG --region $REGION
done

## DETACH SG khỏi ENIs trước khi xóa
SG_IDS=$(aws ec2 describe-security-groups --region $REGION \
  --query "SecurityGroups[?GroupName!='default' && contains(GroupName, '$PREFIX')].GroupId" --output text)

for SG in $SG_IDS; do
  ENIs=$(aws ec2 describe-network-interfaces --region $REGION \
    --filters Name=group-id,Values=$SG \
    --query "NetworkInterfaces[*].NetworkInterfaceId" --output text)

  for ENI in $ENIs; do
    echo "🧹 Gỡ SG $SG khỏi ENI $ENI"
    aws ec2 modify-network-interface-attribute --network-interface-id $ENI --groups "" --region $REGION || true
  done

  echo "🛡️ Xóa Security Group: $SG"
  aws ec2 delete-security-group --group-id $SG --region $REGION || echo "⚠️ Không thể xóa SG $SG (vẫn còn phụ thuộc)"
done

## UNUSED EBS
VOLUMES=$(aws ec2 describe-volumes --region $REGION \
  --filters Name=status,Values=available \
  --query "Volumes[*].VolumeId" --output text)

for VOL in $VOLUMES; do
  echo "💾 Xóa volume: $VOL"
  aws ec2 delete-volume --volume-id $VOL --region $REGION
done

## AUTO SCALING & LAUNCH CONFIG
LC_NAMES=$(aws autoscaling describe-launch-configurations --region $REGION \
  --query "LaunchConfigurations[?contains(LaunchConfigurationName, '$PREFIX')].LaunchConfigurationName" --output text)

for LC in $LC_NAMES; do
  echo "🧯 Xóa Launch Config: $LC"
  aws autoscaling delete-launch-configuration --launch-configuration-name $LC --region $REGION
done

ASG_NAMES=$(aws autoscaling describe-auto-scaling-groups --region $REGION \
  --query "AutoScalingGroups[?contains(AutoScalingGroupName, '$PREFIX')].AutoScalingGroupName" --output text)

for ASG in $ASG_NAMES; do
  echo "📉 Xóa Auto Scaling Group: $ASG"
  aws autoscaling delete-auto-scaling-group --auto-scaling-group-name $ASG --force-delete --region $REGION
done

## VPC + COMPONENTS
VPCS=$(aws ec2 describe-vpcs --region $REGION \
  --query "Vpcs[?contains(Tags[?Key=='Name'].Value | [0], '$PREFIX')].VpcId" --output text)

for VPC in $VPCS; do
  echo "🌐 Đang xử lý VPC: $VPC"

  SUBNETS=$(aws ec2 describe-subnets --region $REGION --filters Name=vpc-id,Values=$VPC --query "Subnets[*].SubnetId" --output text)
  for SUB in $SUBNETS; do
    aws ec2 delete-subnet --subnet-id $SUB --region $REGION
  done

  IGWS=$(aws ec2 describe-internet-gateways --region $REGION --filters Name=attachment.vpc-id,Values=$VPC --query "InternetGateways[*].InternetGatewayId" --output text)
  for IGW in $IGWS; do
    aws ec2 detach-internet-gateway --internet-gateway-id $IGW --vpc-id $VPC --region $REGION
    aws ec2 delete-internet-gateway --internet-gateway-id $IGW --region $REGION
  done

  RTBS=$(aws ec2 describe-route-tables --region $REGION --filters Name=vpc-id,Values=$VPC --query "RouteTables[*].RouteTableId" --output text)
  for RTB in $RTBS; do
    aws ec2 delete-route-table --route-table-id $RTB --region $REGION || true
  done

  aws ec2 delete-vpc --vpc-id $VPC --region $REGION
done

echo "✅ HOÀN TẤT: Đã xóa toàn bộ tài nguyên AWS với prefix $PREFIX tại region $REGION."


#!/bin/bash
cd /home/ubuntu/provisioning && ansible-playbook -c local -i localhost, nginx_playbook.yml -t instance-config \
    -e admin_user_ips=${var.admin_user_ips} \
    -e dev_user_ips=${var.dev_user_ips} \
    -e cloudwatch_log_group=${var.log_group_name} \
    -e g7_draft_documents_s3_url=${var.g7_draft_documents_s3_url} \
    -e documents_s3_url=${var.documents_s3_url} \
    -e agreements_s3_url=${var.agreements_s3_url} \
    -e communications_s3_url=${var.communications_s3_url} \
    -e submissions_s3_url=${var.submissions_s3_url} \
    -e api_url=${var.api_url} \
    -e search_api_url=${var.search_api_url} \
    -e buyer_frontend_url=${var.buyer_frontend_url} \
    -e admin_frontend_url=${var.admin_frontend_url} \
    -e supplier_frontend_url=${var.supplier_frontend_url} \
    -e elasticsearch_url=${var.elasticsearch_url} \
    -e elasticsearch_auth=${var.elasticsearch_auth} \
    -e app_auth=${var.app_auth} \
    -e aws_region=${data.aws_region.current} \
    -e nameserver_ip=$(awk '/nameserver/{ print $2; exit}' /etc/resolv.conf)

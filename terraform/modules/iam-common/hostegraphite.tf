resource "aws_iam_policy" "hostedgraphite" {
  name = "Hostedgraphite"
  policy = <<EOF
{
    "Statement": [
        {
            "Sid": "PermissionsForMetrics",
            "Effect": "Allow",
            "Action": [
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricStatistics",
                "ec2:DescribeInstances",
                "ec2:DescribeVolumes",
                "rds:DescribeDBInstances",
                "route53:ListHealthChecks",
                "sqs:ListQueues",
                "elasticache:DescribeCacheClusters",
                "elasticloadbalancing:DescribeLoadBalancers",
                "kinesis:ListStreams",
                "redshift:DescribeClusters",
                "cloudfront:ListDistributions"
            ],
            "Resource": [ "*" ]
        },
        {
            "Sid": "PermissionsForTags",
            "Effect": "Allow",
            "Action": [
                "elasticache:ListTagsForResource",
                "elasticloadbalancing:DescribeTags",
                "cloudfront:ListTagsForResource",
                "route53:ListTagsForResource",
                "kinesis:ListTagsForStream",
                "rds:ListTagsForResource",
                "lambda:ListFunctions",
                "elasticmapreduce:ListClusters",
                "iam:GetUser"
            ],
            "Resource": [ "*" ]
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_role" "hostedgraphite" {
  name = "hostedgraphite"
}

resource "aws_iam_role_policy_attachment" "hostedgraphite_hostedgraphite" {
  role = "${aws_iam_role.hostedgraphite.id}"
  policy_arn = "${aws_iam_policy.hostedgraphite.arn}"
}

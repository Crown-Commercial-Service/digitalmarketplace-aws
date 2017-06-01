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
                "ec2:DescribeVolumes"
            ],
            "Resource": [ "*" ]
        },
        {
            "Sid": "PermissionsForTags",
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:DescribeTags"
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

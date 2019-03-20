# Alarms module

## What are CloudWatch Alarms?

CloudWatch Alarms trigger an action based on the condition of a CloudWatch metric.

CloudWatch metrics, as used by Digital Marketplace, match certain log conditions.

For example; if we receive 20 log entries to the production router in 30 seconds and 2 of those have status = 500, then our production-router-500s metric will be 2.


## This module

These modules are used to set up [AWS CloudWatch Alarms](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ConsoleAlarms.html) which post a message to an [AWS SNS Topic](https://docs.aws.amazon.com/gettingstarted/latest/deploy/creating-an-sns-topic.html) which we use to [send an email](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/US_AlarmAtThresholdEC2.html).

They should be set up per environment.

* The `email-notification` module will set up an AWS SNS Topic for your alarms to post to
* `missing-logs`, `slow-requests` and `status-code` are alarms based on the metrics defined in [`../log-metric-filters`](https://github.com/alphagov/digitalmarketplace-aws/tree/master/terraform/modules/logging/log-metric-filters)

## SNS

This simple module creates an [SNS Topic](https://docs.aws.amazon.com/sns/latest/dg/welcome.html) of the format `<environment>-alarm-email`.

SNS Topics are analagous to [Mailchimp lists](https://mailchimp.com/help/lists)
The topic/ list the `email-notification` module creates can only be managed, and posted to, by account entities. And only GDS emails can subscribe to the list.

## Alarms

### missing-logs

This module creates an alarm _per app_ which is triggered on 15 minutes of 0 logs. This posts to the supplied topic on alarm and recovery.

It relies on the built in [`AWS/Logs` (Cloudwatch) `IncomingLogEvents` metric](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CountingLogEventsExample.html)

```
module "missing_logs_alarms" {
  source                = "../../modules/logging/alarms/missing-logs"
  environment           = "preview"
  app_names             = ["buyer-frontend", "api", "something else", "etc..."]
  alarm_email_topic_arn = "${module.email_alarm_sns.alarm_email_topic_arn}"
  alarm_recovery_email_topic_arn = "${module.alarm_recovery_email_sns.email_topic_arn}"
}
```

### slow-requests

This module creates 2 alarms, one for requests between 5 and 10 seconds and one for requests over 15 seconds. It is triggered on 5 of either within 5 minutes.

It relies on the [request_time_bucket_router metrics](https://github.com/alphagov/digitalmarketplace-aws/blob/0e0797c3a0e692619e6e7a2bbe1fb2a7cbd9dbdc/terraform/modules/logging/log-metric-filters/main.tf#L273), specifically buckets 8 and 9.

```
module "slow_requests_alarms" {
  source                = "../../modules/logging/alarms/slow-requests"
  environment           = "preview"
  app_name              = "router"
  alarm_email_topic_arn = "${module.email_alarm_sns.alarm_email_topic_arn}"
  alarm_recovery_email_topic_arn = "${module.alarm_recovery_email_sns.email_topic_arn}"
}
```

### status-code

This module creates a single alarm for the given status code. It is triggered on a single request returning the given status code.

It relies on the [`router-XXXs` metrics](https://github.com/alphagov/digitalmarketplace-aws/blob/0e0797c3a0e692619e6e7a2bbe1fb2a7cbd9dbdc/terraform/modules/logging/log-metric-filters/main.tf#L299).

```
module "router_500_alarm" {
  source                = "../../modules/logging/alarms/status-code"
  environment           = "preview"
  status_code           = "500"
  alarm_email_topic_arn = "${module.email_alarm_sns.alarm_email_topic_arn}"
  alarm_recovery_email_topic_arn = "${module.alarm_recovery_email_sns.email_topic_arn}"
}
```

### dropped-av-sns

This module creates a single alarm that is triggered on an entry in the ${var.environment}-dropped-antivirus-sns metric.

It relies on the [`${var.environment}-dropped-antivirus-sns` metrics](https://github.com/alphagov/digitalmarketplace-aws/blob/2df2d21ea8c8bd0da78a37c7f6ce3d71889d00e2/terraform/modules/logging/log-metric-filters/main.tf#L325).

```
module "dropped_av_sns_alarm" {
  source                = "../../modules/logging/alarms/dropped-av-sns"
  environment           = "preview"
  alarm_email_topic_arn = "${module.email_alarm_sns.alarm_email_topic_arn}"
  alarm_recovery_email_topic_arn = "${module.alarm_recovery_email_sns.email_topic_arn}"
}
```

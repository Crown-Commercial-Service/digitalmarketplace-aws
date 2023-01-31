# "Staging" environment

For this POC we are forced to use an "as-live" environment. This is for the following reasons:

1. Dev-like environments tie related service addresses to "localhost" values - see https://github.com/Crown-Commercial-Service/digitalmarketplace-buyer-frontend/blob/main/config.py#L137 - This will break our connectivity needs further down the line

1. In DMP 1.0 apps you can only choose from a small set of pre-defined environment names as per https://github.com/Crown-Commercial-Service/digitalmarketplace-buyer-frontend/blob/main/config.py#L177

1. Throughout this POC we have adopted the axiom that "the application code may not be altered"

Thus we find ourselves in an impasse unless we choose to adopt an "as-live" environment name for our POC. We have therefore chosen "staging".

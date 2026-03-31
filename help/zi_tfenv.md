---
category: AWS/Infra
description: load AWS creds from .env (staging/prod)
---
# zi_tfenv

## Terraform environment loader

Reads the `ENV` variable from `.env` in the current directory and calls the corresponding credential function (`zi_aws_prod` or `zi_aws_staging`). Define these in your `custom_workflows.sh`.

### Usage

```bash
zi_tfenv    # read .env, set matching AWS credentials
```

### Setup

Define your credential functions in `~/.config/zinteractive/custom_workflows.sh`:

```bash
zi_aws_prod() {
  export AWS_ACCESS_KEY_ID="your-key"
  export AWS_SECRET_ACCESS_KEY="your-secret"
}
zi_aws_staging() {
  export AWS_ACCESS_KEY_ID="your-staging-key"
  export AWS_SECRET_ACCESS_KEY="your-staging-secret"
}
```

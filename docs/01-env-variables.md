## Settings and Customization

Viewer expects several configuration parameters to be set in the environment, or
it's deployment manifests:

| Variable name            | Default value        | Description                 |
| -------------------------| -------------------- | --------------------------- |
| `UI_URL`                 | `localhost:3000`     | The main Viewer URL         |
| `API_URL`                | `localhost:8000/api` | Viewer API URL: ${BACKEND_URL}/api |
| `GITHUB_CLIENT_ID`\*     |                      | Github OAuth app client ID  |
| `GITHUB_SECRET_KEY`\*    |                      | Github OAuth app secret key |
| `GITLAB_CLIENT_ID`\*     |                      | GitLab OAuth app client ID  |
| `GITLAB_SECRET_KEY`\*    |                      | GitLab OAuth app secret key |
| `GITHUB_WEBHOOK_URL`     |                      | [Github Webhook URL](https://developer.github.com/webhooks/creating/#payload-url) for getting updates: ${BACKEND_URL}/webhook/github/ |
| `GITHUB_WEBHOOK_SECRET`  |                      | [Github Webhook secret](https://developer.github.com/webhooks/creating/#secret) to secure webhook |
| `GITLAB_WEBHOOK_URL`     |                      | [GitLab Webhook URL](https://docs.gitlab.com/ee/user/project/integrations/webhooks.html#webhook-endpoint-tips) for getting updates: ${BACKEND_URL}/webhook/gitlab/ |
| `GITLAB_WEBHOOK_SECRET`  |                      | [GitLab secret token](https://docs.gitlab.com/ee/user/project/integrations/webhooks.html#webhook-endpoint-tips) to secure webhook |


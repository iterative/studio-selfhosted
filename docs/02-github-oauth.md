# Github OAuth

For being able to login and use DVC Viewer service you must to create your [own Github OAuth application](https://developer.github.com/apps/building-oauth-apps/creating-an-oauth-app/)

During the setup process, you'll need to provide your on-premise Viewer's
homepage and login redirect URL. You can change those URLs in the app's settings
after the initial setup, but you need to make sure those URLS match the FQDN
you'll host Viewer on: see [Settings and Customization](https://github.com/iterative/viewer-onpremise/blob/master/docs/01-env-variables.md) for details.

## Steps

* Open settings  
  ![](./images/02-01-settings.png)
* Select **Developer settings** -> **OAuth Apps**  
  ![](./images/02-02-oauth-apps.png)
* Fill up the form where  
  **Homepage URL** is your **${UI_URL}**  
  **Authorization URL** is your **${API_URL}/complete/github/**  
  ![](./images/02-03-form.png)
* Register application and use  
  **Client ID** as **GITHUB_CLIENT_ID**  
  **Client Secret** as **GITHUB_SECRET_KEY**

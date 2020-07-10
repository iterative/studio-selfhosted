# Github OAuth

For being able to login and use DVC Viewer service you must to create your [own Github OAuth application](https://developer.github.com/apps/building-oauth-apps/creating-an-oauth-app/)

## Steps

* Open settings  
  ![](./images/02-01-settings.png)
* Select **Developer settings** -> **OAuth Apps**  
  ![](./images/02-02-oauth-apps.png)
* Fill up the form where  
  **Homepage URL** is your **UI_URL**  
  **Authorization URL** is your **API_URL/complete/github/**  
  ![](./images/02-03-form.png)
* Register application and use  
  **Client ID** as **GITHUB_CLIENT_ID**  
  **Client Secret** as **GITHUB_SECRET_KEY**

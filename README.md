# valentine

## Setup for development

```
cd valentine
mix deps.get
mix ecto.create
mix ecto.migrate
mix run priv/repo/seeds.exs
cd assets
npm i 
```


## Running with docker compose

You can run the app locally using docker compose. It is not recommended to use this in production.

```
docker-compose up
```

will build the latest image and run the app on `http://localhost:4000`. If you would like to use the LLM functionality. You need to provide your own OPENAI API key for gpt-4o-mini.

```
OPENAI_API_KEY=sk-proj... docker compose up
```

If you make changes to the source code, then you need to rebuild the image.


## Optional Google Auth

You can use Google as your IDP if you set the following environment variables:

```
GOOGLE_CLIENT_ID=your-client-id
GOOGLE_CLIENT_SECRET=your-client-secret
```

You can get these by creating a new project in the Google Developer Console and creating OAuth 2.0 credentials.

In this case to access the `/workspaces` route you need to be authenticated with Google, but visiting `/auth/google`. Currently nothing is done with the user information from Google, but you can use it to restrict access to the app.

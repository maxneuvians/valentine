ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Valentine.Repo, :manual)

System.put_env("GOOGLE_CLIENT_ID", "")
System.put_env("GOOGLE_CLIENT_SECRET", "")

# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :ndm,
  ecto_repos: [Ndm.Repo]

# Configures the endpoint
config :ndm, NdmWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "dNKcjdtLx2bvUYmnf5DJ0EhWGDxEXRpjebbwhn8hjqLyBsZNi5glpDhoIrDFHK8O",
  render_errors: [view: NdmWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Ndm.PubSub,
  live_view: [signing_salt: "cCyYMyV+"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

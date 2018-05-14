# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :ndm, NdmWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4AeiuXS4gAwlkYyGM2Ccz7i85zSkQAu7gHl6iWRAgl6ylhU5Mom+/s62f/pJZxxu",
  render_errors: [view: NdmWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Ndm.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures the guardian session management library
config :guardian, Guardian,
allowed_algos: ["HS512"], # optional
verify_module: Guardian.JWT,  # optional
issuer: "Ndm",
ttl: { 30, :days },
allowed_drift: 2000,
verify_issuer: true, # optional
secret_key: "GNmJ/ZBcHxpG2/7x4T+34mlMTLo5vLnXijB/zjFHBcc/b3x/B7HgQtIc+CaB1r7U",
serializer: Ndm.GuardianSerializer,
permissions: %{ user: [:default] }

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

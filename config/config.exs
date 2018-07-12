use Mix.Config

alias FidoQrCode.FidoServer.Client

config :fido_qr_code,
  relying_party_url: {:system, "RELYING_PARTY_URL"},
  callback_url: {:system, "CALLBACK_URL"},
  fido_server_client: Client,
  fido_server_url: "${FIDO_SERVER_URL}",
  requested_scopes: {:system, :list, "REQUESTED_SCOPES"},
  scope_request_ttl: {:system, :integer, "SCOPE_REQUEST_TTL"},
  ecto_repos: [FidoQrCode.Repo]

import_config "#{Mix.env()}.exs"

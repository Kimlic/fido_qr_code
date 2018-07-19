use Mix.Config

config :fido_qr_code,
  fido_server_client: FidoServerClientMock,
  fido_server_url: "http://localhost:8080",
  callback_url: "http://localhost:4001/callback",
  requested_scopes: ["documents.driver_license"],
  scope_request_ttl: 1000

config :fido_qr_code, FidoQrCode.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "fido_qr_code_test",
  hostname: "localhost"

config :ex_unit, capture_log: true

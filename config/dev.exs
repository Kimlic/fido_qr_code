use Mix.Config

config :fido_qr_code,
  fido_server_url: "http://localhost:8080",
  requested_scopes: ["documents.driver_license"]

config :fido_qr_code, FidoQrCode.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "fido_qr_code_dev",
  hostname: "localhost"

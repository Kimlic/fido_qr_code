defmodule FidoQrCode.FidoServer.Client do
  use HTTPoison.Base
  alias FidoQrCode.FidoServer.ClientBehaviour
  alias FidoQrCode.ResponseDecoder

  @behaviour ClientBehaviour

  @spec process_url(binary) :: binary
  def process_url(url), do: Confex.fetch_env!(:fido_qr_code, :fido_server_url) <> url

  @spec create_reg_request(binary) :: {:ok, map} | {:error, tuple}
  def create_reg_request(username) do
    get!("/v1/public/regRequest/#{username}")
  end

  @spec create_auth_request :: {:ok, map} | {:error, tuple}
  def create_auth_request do
    get!("/v1/public/uafAuthRequest")
  end

  @spec check_username_registered(binary) :: {:ok, map} | {:error, tuple}
  def check_username_registered(username) do
    head("/v1/public/registrations/#{username}}")
  end

  @spec request!(binary, binary, binary, list, list) :: {:ok, map} | {:error, tuple}
  def request!(method, url, body \\ "", headers \\ [], options \\ []) do
    method
    |> super(url, body, headers, options)
    |> ResponseDecoder.check_response()
  end
end

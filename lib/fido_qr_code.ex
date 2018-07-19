defmodule FidoQrCode do
  import FidoQrCode.ScopeRequests

  alias FidoQrCode.{ScopeRequest, ScopeRequests}

  @fido_server_client Application.get_env(:fido_qr_code, :fido_server_client)

  @spec create_scope_request :: %ScopeRequest{}
  def create_scope_request do
    ScopeRequests.create(%{
      scopes: fetch_scopes(),
      status: ScopeRequest.status(:new),
      used: false
    })
  end

  def process_scope_request(%ScopeRequest{id: id}, username),
    do: process_scope_request(id, username)

  @spec process_scope_request(binary, binary) :: map
  def process_scope_request(id, username) when is_binary(username) do
    with scope_request <- ScopeRequests.get!(id),
         :ok <- check_processed(scope_request),
         :ok <- check_expired(scope_request),
         {:ok, processed_scope_request} <- process(scope_request, username),
         {:ok, fido} <- create_request(username) do
      {:ok,
       %{
         scope_request: processed_scope_request,
         fido: fido
       }}
    end
  end

  @spec create_request(binary) :: {:ok, map} | {:error, tuple}
  defp create_request(username) do
    {:ok, %HTTPoison.Response{status_code: status_code}} =
      @fido_server_client.check_username_registered(username)

    case status_code do
      204 -> @fido_server_client.create_auth_request
      _ -> @fido_server_client.create_reg_request(username)
    end
  end

  @doc """
  Example of rendering QR Code in Phoenix Controller

  def qrcode(conn, _params) do
    conn
    |> put_resp_content_type("image/png")
    |> send_resp(201, FidoQrCode.generate_qr_code(scope_request))
  end
  """
  @spec generate_qr_code(%ScopeRequest{}) :: binary
  def generate_qr_code(%ScopeRequest{id: id}) do
    callback_url = Confex.fetch_env!(:fido_qr_code, :callback_url)
    QRCode.to_png(callback_url <> "?scope_request=#{id}}")
  end

  @spec fetch_scopes :: binary
  defp fetch_scopes do
    :fido_qr_code
    |> Confex.fetch_env!(:requested_scopes)
    |> Enum.join(" ")
  end
end

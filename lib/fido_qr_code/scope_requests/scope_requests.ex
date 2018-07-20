defmodule FidoQrCode.ScopeRequests do
  alias FidoQrCode.Repo
  alias FidoQrCode.ScopeRequest

  @type scope_request :: ScopeRequest.t()

  @spec get!(binary) :: scope_request
  def get!(id), do: Repo.get!(ScopeRequest, id)

  @spec create(map) :: {:ok, scope_request} | {:error, binary}
  def create(attrs) do
    %ScopeRequest{}
    |> ScopeRequest.changeset(attrs)
    |> Repo.insert()
  end

  @spec update(scope_request, map) :: {:ok, scope_request} | {:error, term}
  def update(%ScopeRequest{} = schema, attrs) do
    schema
    |> ScopeRequest.changeset(attrs)
    |> Repo.update()
  end

  @spec check_processed(scope_request) :: :ok | {:error, :scope_request_already_processed}
  def check_processed(%ScopeRequest{used: true}), do: {:error, :scope_request_already_processed}
  def check_processed(%ScopeRequest{used: false}), do: :ok

  @spec check_expired(scope_request) :: :ok | {:error, :scope_request_expired}
  def check_expired(%ScopeRequest{inserted_at: inserted_at}) do
    expires_at =
      :fido_qr_code
      |> Confex.fetch_env!(:scope_request_ttl)
      |> Kernel.+(:os.system_time(:second))
      |> DateTime.from_unix!()

    case DateTime.compare(expires_at, inserted_at) do
      :lt -> {:error, :scope_request_expired}
      _ -> :ok
    end
  end

  @spec process(scope_request, binary) :: {:ok, scope_request} | {:error, binary}
  def process(%ScopeRequest{} = scope_request, username) do
    update(scope_request, %{used: true, username: username})
  end
end

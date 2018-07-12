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

  @spec update(scope_request, map) :: {:ok, scope_request} | {:error, binary}
  def update(%ScopeRequest{} = schema, attrs) do
    schema
    |> ScopeRequest.changeset(attrs)
    |> Repo.update()
  end

  @spec check_processed(scope_request) :: :ok | {:error, atom}
  def check_processed(%ScopeRequest{used: true}), do: {:error, :scope_request_already_processed}
  def check_processed(%ScopeRequest{used: false}), do: :ok

  @spec check_expired(scope_request) :: :ok | {:error, atom}
  def check_expired(%ScopeRequest{inserted_at: inserted_at}) do
    Confex.fetch_env!(:fido_qr_code, :scope_request_ttl)
    # ToDo: check expiration time by inserted_at

    :ok
  end

  @spec process(scope_request, binary) :: {:ok, scope_request} | {:error, binary}
  def process(%ScopeRequest{} = scope_request, username) do
    update(scope_request, %{used: true, username: username})
  end
end

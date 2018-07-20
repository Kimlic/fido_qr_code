defmodule FidoQrCode.ScopeRequest do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__]}

  @status_new "NEW"
  @status_inactive "INACTIVE"

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "scope_requests" do
    field(:status, :string, null: false, default: @status_new)
    field(:scopes, :string, null: false)
    field(:used, :boolean, default: false)
    field(:username, :string)

    timestamps(type: :utc_datetime)
  end

  @optional ~w(username used)a
  @required ~w(status scopes)a

  @spec status(atom) :: string
  def status(:new), do: @status_new

  @spec changeset(ScopeRequest.t(), map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = schema, attrs) do
    schema
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end
end

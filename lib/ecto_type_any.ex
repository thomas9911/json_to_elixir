defmodule EctoTypeAny do
  alias Ecto.Type
  @behaviour Type

  @impl Type
  def type, do: :any

  @impl Type
  def cast(value), do: Type.cast(:any, value)

  @impl Type
  def load(value), do: Type.load(:any, value)

  @impl Type
  def dump(value), do: Type.dump(:any, value)

  @impl Type
  def embed_as(_), do: :self

  @impl Type
  def equal?(a, b), do: a == b
end

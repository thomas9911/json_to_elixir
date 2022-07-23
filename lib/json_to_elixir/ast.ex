defmodule JsonToElixir.Ast do
  defstruct [:root, :name]

  defmacro __using__(opts) do
    quote  do
      def load(changeset \\ __MODULE__.__struct__(), params) do
        not_required = unquote(opts)[:not_required] || []

        embeds =
          __MODULE__.__schema__(:embeds)
          |> Enum.map(&__MODULE__.__schema__(:embed, &1))
          |> Enum.map(&{&1.field, &1.related})

        {simple_fields, polymorphic_fields} =
          __MODULE__.__schema__(:fields)
          |> Enum.map(&{&1, __MODULE__.__schema__(:type, &1)})
          |> Enum.reject(fn
            {_, {:parameterized, Ecto.Embedded, _}} -> true
            {_, {:array, {:parameterized, Ecto.Embedded, _}}} -> true
            _ -> false
          end)
          |> Enum.split_with(fn
            {_, {:parameterized, PolymorphicEmbed, _}} -> false
            {_, {:array, {:parameterized, PolymorphicEmbed, _}}} -> false
            _ -> true
          end)
          |> then(fn {simple, polymorphic} -> {Keyword.keys(simple), polymorphic} end)

        base =
          changeset
          |> Ecto.Changeset.cast(params, simple_fields)
          |> Ecto.Changeset.validate_required(simple_fields -- not_required)

        base_with_embeds =
          embeds
          |> Enum.reduce(base, fn {embed, related}, changeset ->
            Ecto.Changeset.cast_embed(changeset, embed, required: true, with: {related, :load, []})
          end)

        polymorphic_fields
        |> Enum.map(fn input ->
          {name, metadata} =
            case input do
              {name, {:parameterized, PolymorphicEmbed, %{types_metadata: metadata}}} ->
                {name, metadata}

              {name, {:array, {:parameterized, PolymorphicEmbed, %{types_metadata: metadata}}}} ->
                {name, metadata}
            end

          {name, Enum.map(metadata, &{String.to_existing_atom(&1.type), {&1.module, :load, []}})}
        end)
        |> Enum.reduce(base_with_embeds, fn {embed, loader}, changeset ->
          PolymorphicEmbed.cast_polymorphic_embed(changeset, embed, required: true, with: loader)
        end)
      end
    end
  end

  alias JsonToElixir.Ast.Root

  def new(name, data) do
    data
    |> Root.load()
    |> Ecto.Changeset.apply_action(:create)
    |> case do
      {:ok, root} -> {:ok, %__MODULE__{name: name, root: root}}
      e -> e
    end
  end

  def from_json(name, data) do
    case Jason.decode(data, keys: :atoms!) do
      {:ok, data} -> new(name, data)
      e -> e
    end
  end
end

defmodule JsonToElixir.Ast do
  @moduledoc """
  Storage of the code as an elixir term
  """

  defstruct [:root, :name]

  defmacro __using__(opts) do
    quote do
      defp __json_to_elixir_ast_fetch_embeds do
        __MODULE__.__schema__(:embeds)
        |> Enum.map(&__MODULE__.__schema__(:embed, &1))
        |> Enum.map(&{&1.field, &1.related})
      end

      defp __json_to_elixir_ast_fetch_fields do
        __MODULE__.__schema__(:fields)
        |> Enum.map(&{&1, __MODULE__.__schema__(:type, &1)})
        |> Enum.reject(&__json_to_elixir_ast_parameterized_embed?/1)
        |> Enum.split_with(&__json_to_elixir_ast_parameterized_poly?/1)
        |> then(fn {polymorphic, simple} -> {Keyword.keys(simple), polymorphic} end)
      end

      defp __json_to_elixir_ast_parameterized_embed?({_, {:parameterized, Ecto.Embedded, _}}) do
        true
      end

      defp __json_to_elixir_ast_parameterized_embed?(
             {_, {:array, {:parameterized, Ecto.Embedded, _}}}
           ) do
        true
      end

      defp __json_to_elixir_ast_parameterized_embed?(_) do
        false
      end

      defp __json_to_elixir_ast_parameterized_poly?({_, {:parameterized, PolymorphicEmbed, _}}) do
        true
      end

      defp __json_to_elixir_ast_parameterized_poly?(
             {_, {:array, {:parameterized, PolymorphicEmbed, _}}}
           ) do
        true
      end

      defp __json_to_elixir_ast_parameterized_poly?(_) do
        false
      end

      defp __json_to_elixir_ast_changeset_base(changeset, params, simple_fields, not_required) do
        changeset
        |> Ecto.Changeset.cast(params, simple_fields)
        |> Ecto.Changeset.validate_required(simple_fields -- not_required)
      end

      defp __json_to_elixir_ast_changeset_apply_embeds(base, embeds) do
        Enum.reduce(embeds, base, fn {embed, related}, changeset ->
          Ecto.Changeset.cast_embed(changeset, embed, required: true, with: {related, :load, []})
        end)
      end

      defp __json_to_elixir_ast_changeset_apply_polymorphic(base, polymorphic_fields) do
        polymorphic_fields
        |> Enum.map(&__json_to_elixir_ast_extract_poly_metadata/1)
        |> Enum.reduce(base, fn {embed, loader}, changeset ->
          PolymorphicEmbed.cast_polymorphic_embed(changeset, embed, required: true, with: loader)
        end)
      end

      defp __json_to_elixir_ast_extract_poly_metadata(field) do
        {name, metadata} =
          case field do
            {name, {:parameterized, PolymorphicEmbed, %{types_metadata: metadata}}} ->
              {name, metadata}

            {name, {:array, {:parameterized, PolymorphicEmbed, %{types_metadata: metadata}}}} ->
              {name, metadata}
          end

        {name, Enum.map(metadata, &{String.to_existing_atom(&1.type), {&1.module, :load, []}})}
      end

      def load(changeset \\ __MODULE__.__struct__(), params) do
        not_required = unquote(opts)[:not_required] || []

        embeds = __json_to_elixir_ast_fetch_embeds()
        {simple_fields, polymorphic_fields} = __json_to_elixir_ast_fetch_fields()

        base_with_embeds =
          changeset
          |> __json_to_elixir_ast_changeset_base(params, simple_fields, not_required)
          |> __json_to_elixir_ast_changeset_apply_embeds(embeds)
          |> __json_to_elixir_ast_changeset_apply_polymorphic(polymorphic_fields)
      end

      defoverridable load: 1, load: 2
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
    case Jason.decode(data) do
      {:ok, data} -> new(name, data)
      e -> e
    end
  end
end

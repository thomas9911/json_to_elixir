defmodule Fancy do
  def my_add(x, y) do
    z = x + y
    1 + z
  end

  def concat_questionmark(text) do
    abc = text <> "?"
    Enum.join([abc, "?", "?"])
  end

  def trim_test(text) do
    x = String.trim(text)
    String.trim(x, "abc")
  end
end

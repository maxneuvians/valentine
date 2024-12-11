defmodule Valentine.Cache do
  @moduledoc """
  Wrapper cache module for Valentine
  """

  def get(key) do
    {:ok, value} = Cachex.get(:valentine, key)
    value
  end

  def put(key, value) do
    {:ok, true} = Cachex.put(:valentine, key, value)
    :ok
  end

  def delete(key) do
    {:ok, true} = Cachex.del(:valentine, key)
    :ok
  end

  def clear do
    {:ok, _} = Cachex.clear(:valentine)
    :ok
  end
end

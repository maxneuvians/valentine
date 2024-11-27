defmodule Valentine.CacheTest do
  use ExUnit.Case
  alias Valentine.Cache

  test "put and get a value" do
    assert :ok == Cache.put(:foo, "bar")
    assert "bar" == Cache.get(:foo)
  end

  test "delete a value" do
    Cache.put(:foo, "bar")
    assert :ok == Cache.delete(:foo)
    assert nil == Cache.get(:foo)
  end

  test "clear the cache" do
    Cache.put(:foo, "bar")
    Cache.put(:baz, "qux")
    assert :ok == Cache.clear()
    assert nil == Cache.get(:foo)
    assert nil == Cache.get(:baz)
  end
end

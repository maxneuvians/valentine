defmodule Valentine.Composer.ArchitectureTest do
  use ExUnit.Case, async: true

  alias Valentine.Composer.Architecture

  setup do
    workspace_id = System.unique_integer([:positive])
    {:ok, workspace_id: workspace_id}
  end

  test "get_cache/1 returns an empty list if the cache is empty", %{workspace_id: workspace_id} do
    assert Architecture.get_cache(workspace_id) == []
  end

  test "push_cache/2 pushes an item to the cache", %{workspace_id: workspace_id} do
    assert Architecture.push_cache(workspace_id, ["item"]) == ["item"]
  end

  test "push_cache/2 pushes multiple items to the cache", %{workspace_id: workspace_id} do
    assert Architecture.push_cache(workspace_id, ["item1"]) == ["item1"]
    assert Architecture.push_cache(workspace_id, ["item2"]) == ["item1", "item2"]
  end

  test "flush_cache/1 clears the cache", %{workspace_id: workspace_id} do
    Architecture.push_cache(workspace_id, ["item"])
    assert Architecture.flush_cache(workspace_id) == []
  end
end

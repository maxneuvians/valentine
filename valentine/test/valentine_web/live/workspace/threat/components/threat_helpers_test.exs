defmodule ValentineWeb.WorkspaceLive.Threat.Components.ThreatHelpersTest do
  use ExUnit.Case, async: true
  alias ValentineWeb.WorkspaceLive.Threat.Components.ThreatHelpers

  describe "join_list/2" do
    test "returns an empty string for an empty list" do
      assert ThreatHelpers.join_list([]) == ""
    end

    test "returns the single item as a string for a list with one item" do
      assert ThreatHelpers.join_list(["item"]) == "item"
    end

    test "joins two items with the default joiner" do
      assert ThreatHelpers.join_list(["item1", "item2"]) == "item1 and item2"
    end

    test "joins two items with a custom joiner" do
      assert ThreatHelpers.join_list(["item1", "item2"], "or") == "item1 or item2"
    end

    test "joins multiple items with the default joiner" do
      assert ThreatHelpers.join_list(["item1", "item2", "item3"]) == "item1, item2, and item3"
    end

    test "joins multiple items with a custom joiner" do
      assert ThreatHelpers.join_list(["item1", "item2", "item3"], "or") ==
               "item1, item2, or item3"
    end
  end
end

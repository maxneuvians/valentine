defmodule ValentineWeb.WorkspaceLive.Threat.Components.ThreatHelpersTest do
  use ExUnit.Case, async: true
  alias ValentineWeb.WorkspaceLive.Threat.Components.ThreatHelpers

  describe "a_or_an/2" do
    test "returns 'a' for a word that starts with a consonant" do
      assert ThreatHelpers.a_or_an("word") == "a"
    end

    test "returns 'an' for a word that starts with a vowel" do
      assert ThreatHelpers.a_or_an("apple") == "an"
    end

    test "returns 'A' for a word that starts with a consonant and is capitalized" do
      assert ThreatHelpers.a_or_an("Word", true) == "A"
    end

    test "returns 'An' for a word that starts with a vowel and is capitalized" do
      assert ThreatHelpers.a_or_an("Apple", true) == "An"
    end

    test "returns 'a' for a nil word" do
      assert ThreatHelpers.a_or_an(nil) == "a"
    end

    test "returns 'A' for a nil word that is capitalized" do
      assert ThreatHelpers.a_or_an(nil, true) == "A"
    end
  end

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

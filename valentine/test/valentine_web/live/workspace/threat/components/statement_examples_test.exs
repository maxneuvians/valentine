defmodule ValentineWeb.WorkspaceLive.Threat.Components.StatementExamplesTest do
  use ExUnit.Case, async: true

  alias ValentineWeb.WorkspaceLive.Threat.Components.StatementExamples

  describe "content/1" do
    test "returns correct title for :threat_source" do
      expected_title = "Threat source"
      assert StatementExamples.content(:threat_source).title == expected_title
    end

    test "returns correct title for :prerequisites" do
      expected_title = "Prerequisites"
      assert StatementExamples.content(:prerequisites).title == expected_title
    end

    test "returns correct title for :threat_action" do
      expected_title = "Threat action"
      assert StatementExamples.content(:threat_action).title == expected_title
    end

    test "returns correct title for :threat_impact" do
      expected_title = "Threat impact"
      assert StatementExamples.content(:threat_impact).title == expected_title
    end

    test "returns correct title for :impacted_assets" do
      expected_title = "Impacted assets"
      assert StatementExamples.content(:impacted_assets).title == expected_title
    end

    test "returns empty map for unknown content type" do
      assert StatementExamples.content(:unknown) == %{}
    end
  end
end

defmodule ValentineWeb.WorkspaceLive.Threat.Components.ThreatFieldComponentTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  alias ValentineWeb.WorkspaceLive.Threat.Components.ThreatFieldComponent

  test "renders properly with a placeholder" do
    assigns = %{
      field: :threat_source,
      type: :text,
      placeholder: "Placeholder",
      value: nil
    }

    html = render_component(ThreatFieldComponent, assigns)
    assert html =~ "Placeholder"
  end

  test "renders properly with an empty string" do
    assigns = %{
      field: :threat_source,
      type: :text,
      placeholder: "Placeholder",
      value: ""
    }

    html = render_component(ThreatFieldComponent, assigns)
    assert html =~ "Placeholder"
  end

  test "renders properly with an empty list" do
    assigns = %{
      field: :threat_source,
      type: :text,
      placeholder: "Placeholder",
      value: []
    }

    html = render_component(ThreatFieldComponent, assigns)
    assert html =~ "Placeholder"
  end

  test "renders properly with a value" do
    assigns = %{
      field: :threat_source,
      type: :text,
      placeholder: "Placeholder",
      value: "Value"
    }

    html = render_component(ThreatFieldComponent, assigns)
    assert html =~ "Value"
  end

  test "renders properly with a list value" do
    assigns = %{
      field: :threat_source,
      type: :text,
      placeholder: "Placeholder",
      value: ["Value1", "Value2"]
    }

    html = render_component(ThreatFieldComponent, assigns)
    assert html =~ "Value1 and Value2"
  end
end

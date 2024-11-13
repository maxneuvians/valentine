defmodule ValentineWeb.WorkspaceLive.Threat.Components.ThreatFieldComponentTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  alias ValentineWeb.WorkspaceLive.Threat.Components.ThreatFieldComponent
  alias Valentine.Composer
  alias Valentine.Composer.Threat

  @valid_changeset Composer.change_threat(%Threat{})

  test "renders placeholder when value is nil" do
    assigns = %{
      changeset: @valid_changeset,
      field: :threat_source,
      placeholder: "Enter value"
    }

    html = render_component(ThreatFieldComponent, assigns)
    assert html =~ "Enter value"
  end

  test "renders value from changeset" do
    changeset = Ecto.Changeset.change(@valid_changeset, threat_source: "Test Value")

    assigns = %{
      changeset: changeset,
      field: :threat_source,
      placeholder: "Enter value"
    }

    html = render_component(ThreatFieldComponent, assigns)
    assert html =~ "Test Value"
  end

  test "renders placeholder when value is empty string" do
    changeset = Ecto.Changeset.change(@valid_changeset, threat_source: "")

    assigns = %{
      changeset: changeset,
      field: :threat_source,
      placeholder: "Enter value"
    }

    html = render_component(ThreatFieldComponent, assigns)
    assert html =~ "Enter value"
  end
end

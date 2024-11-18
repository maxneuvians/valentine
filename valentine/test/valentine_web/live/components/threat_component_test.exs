defmodule ValentineWeb.WorkspaceLive.Components.ThreatComponentTest do
  use ValentineWeb.ConnCase

  import Phoenix.LiveViewTest
  import Valentine.ComposerFixtures

  alias ValentineWeb.WorkspaceLive.Components.ThreatComponent

  defp create_threat(_) do
    threat = threat_fixture()
    %{assigns: %{threat: threat}}
  end

  describe "render" do
    setup [:create_threat]

    test "displays threat numeric_id", %{assigns: assigns} do
      html = render_component(ThreatComponent, assigns)
      assert html =~ "Threat #{assigns.threat.numeric_id}"
    end

    test "displays threat source", %{assigns: assigns} do
      html = render_component(ThreatComponent, assigns)
      assert html =~ assigns.threat.threat_source
    end

    test "displays threat prerequisites", %{assigns: assigns} do
      html = render_component(ThreatComponent, assigns)
      assert html =~ assigns.threat.prerequisites
    end

    test "displays threat action", %{assigns: assigns} do
      html = render_component(ThreatComponent, assigns)
      assert html =~ assigns.threat.threat_action
    end

    test "displays threat impact", %{assigns: assigns} do
      html = render_component(ThreatComponent, assigns)
      assert html =~ assigns.threat.threat_impact
    end

    test "displays threat impacted goal if it set", %{assigns: assigns} do
      html = render_component(ThreatComponent, assigns)
      assert html =~ hd(assigns.threat.impacted_goal)
    end

    test "do not display threat goal if it is not set", %{assigns: assigns} do
      threat = Map.put(assigns.threat, :impacted_goal, nil)
      assigns = Map.put(assigns, :threat, threat)
      html = render_component(ThreatComponent, assigns)
      refute html =~ "reduced"
    end

    test "display impacted assets", %{assigns: assigns} do
      html = render_component(ThreatComponent, assigns)
      assert html =~ hd(assigns.threat.impacted_assets)
    end

    test "displays a :low priority badge", %{assigns: assigns} do
      assigns = Map.put(assigns, :threat, Map.put(assigns.threat, :priority, :low))
      html = render_component(ThreatComponent, assigns)
      assert html =~ "Low"
    end

    test "displays a :medium priority badge", %{assigns: assigns} do
      assigns = Map.put(assigns, :threat, Map.put(assigns.threat, :priority, :medium))
      html = render_component(ThreatComponent, assigns)
      assert html =~ "Medium"
    end

    test "displays a :high priority badge", %{assigns: assigns} do
      assigns = Map.put(assigns, :threat, Map.put(assigns.threat, :priority, :high))
      html = render_component(ThreatComponent, assigns)
      assert html =~ "High"
    end

    test "displays an :identified status badge", %{assigns: assigns} do
      assigns = Map.put(assigns, :threat, Map.put(assigns.threat, :status, :identified))
      html = render_component(ThreatComponent, assigns)
      assert html =~ "Identified"
    end

    test "displays a :resolved status badge", %{assigns: assigns} do
      assigns = Map.put(assigns, :threat, Map.put(assigns.threat, :status, :resolved))
      html = render_component(ThreatComponent, assigns)
      assert html =~ "Resolved"
    end

    test "displays a :not_useful status badge", %{assigns: assigns} do
      assigns = Map.put(assigns, :threat, Map.put(assigns.threat, :status, :not_useful))
      html = render_component(ThreatComponent, assigns)
      assert html =~ "Not Useful"
    end
  end

  describe "stride" do
    test "displays STRIDE if stride is not set" do
      html = ThreatComponent.stride(nil)
      assert html == "STRIDE"
    end

    test "displays STRIDE is an empty list" do
      {:safe, html} = ThreatComponent.stride([])
      assert html == "STRIDE"
    end

    test "displays highlighted STRIDE if all are set" do
      {:safe, html} =
        ThreatComponent.stride([
          :spoofing,
          :tampering,
          :repudiation,
          :information_disclosure,
          :denial_of_service,
          :elevation_of_privilege
        ])

      assert html ==
               "<span class=\"Label--accent\">S</span><span class=\"Label--accent\">T</span><span class=\"Label--accent\">R</span><span class=\"Label--accent\">I</span><span class=\"Label--accent\">D</span><span class=\"Label--accent\">E</span>"
    end
  end
end

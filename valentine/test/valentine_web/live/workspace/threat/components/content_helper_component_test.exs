defmodule ValentineWeb.WorkspaceLive.Threat.Components.ContextHelpComponentTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest
  alias ValentineWeb.WorkspaceLive.Threat.Components.ContextHelpComponent
  alias Valentine.Composer
  alias Valentine.Composer.Threat

  setup do
    form = %{
      params: %{"field" => "value"},
      source: Composer.change_threat(%Threat{})
    }

    {:ok, form: form}
  end

  test "update/2 assigns current_value correctly when active_field is present", %{form: form} do
    assigns = %{form: form, active_field: :field}
    socket = %Phoenix.LiveView.Socket{}

    {:ok, updated_socket} = ContextHelpComponent.update(assigns, socket)

    assert updated_socket.assigns.current_value == "value"
  end

  test "update/2 assigns current_value as empty string when active_field is nil", %{form: form} do
    assigns = %{form: form, active_field: nil}
    socket = %Phoenix.LiveView.Socket{}

    {:ok, updated_socket} = ContextHelpComponent.update(assigns, socket)

    assert updated_socket.assigns.current_value == ""
  end

  test "handle_event/3 sends update_field message with correct value", %{form: form} do
    assigns = %{form: form, active_field: :field}
    socket = %Phoenix.LiveView.Socket{assigns: assigns}

    ContextHelpComponent.handle_event(
      "update_field",
      %{"threat" => %{"field" => "new_value"}},
      socket
    )

    assert_received {:update_field, "new_value"}
  end

  describe "render/1" do
    setup do
      form = %{
        params: %{},
        source: Composer.change_threat(%Threat{}),
        field_name: :test_field
      }

      base_assigns = %{
        id: "test-id",
        title: "Test Title",
        description: "Test Description",
        form: form,
        active_field: :test_field,
        placeholder: "Test Placeholder",
        myself: nil,
        mitigation_inputs: [
          {:threat_source, "Threat source"},
          {:prerequisites, "prerequisites"},
          {:threat_action, "Threat action"}
        ],
        prioritization_inputs: [
          {:threat_impact, "Threat impact"},
          {:goal, "Impacted goal"},
          {:impacted_assets, "Impacted assets"}
        ],
        current_value: ""
      }

      {:ok, assigns: base_assigns}
    end

    test "renders main structure correctly", %{assigns: assigns} do
      html = render_component(&ContextHelpComponent.render/1, assigns)

      assert html =~ "Test Title"
      assert html =~ "Test Description"
      assert html =~ "Test Placeholder"
      assert html =~ "Inputs for mitigation"
      assert html =~ "Inputs for prioritization"
    end

    test "renders textarea with correct attributes", %{assigns: assigns} do
      html = render_component(&ContextHelpComponent.render/1, assigns)

      assert html =~ ~s(name="threat[test_field]")
      assert html =~ ~s(id="test-id-test_field")
      assert html =~ "phx-change=\"update_field\""
    end

    test "renders completed mitigation_inputs with check icon", %{assigns: assigns} do
      form = %{
        assigns.form
        | source: Composer.change_threat(%Threat{threat_source: "threat_source"})
      }

      assigns = Map.put(assigns, :form, form)

      html = render_component(&ContextHelpComponent.render/1, assigns)

      assert html =~ "hero-check-circle-solid"
      assert html =~ "text-green-500"
    end

    test "renders completed prioritization_inputs with check icon", %{assigns: assigns} do
      form = %{
        assigns.form
        | source: Composer.change_threat(%Threat{threat_impact: "threat_impact"})
      }

      assigns = Map.put(assigns, :form, form)

      html = render_component(&ContextHelpComponent.render/1, assigns)

      assert html =~ "hero-check-circle-solid"
      assert html =~ "text-green-500"
    end

    test "renders incomplete fields with minus icon", %{assigns: assigns} do
      html = render_component(&ContextHelpComponent.render/1, assigns)

      assert html =~ "hero-minus-circle"
    end

    test "renders all mitigation inputs", %{assigns: assigns} do
      html = render_component(&ContextHelpComponent.render/1, assigns)

      for {_key, input} <- assigns.mitigation_inputs do
        assert html =~ input
      end
    end

    test "renders all prioritization inputs", %{assigns: assigns} do
      html = render_component(&ContextHelpComponent.render/1, assigns)

      for {_key, input} <- assigns.prioritization_inputs do
        assert html =~ input
      end
    end
  end
end

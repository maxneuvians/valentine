defmodule Valentine.Prompts.PromptRegistryTest do
  use ValentineWeb.ConnCase
  alias Valentine.Prompts.PromptRegistry

  import Valentine.ComposerFixtures

  describe "get_schema/2" do
    test "returns the base schema if the module does not exist" do
      assert PromptRegistry.get_schema(
               "NonExistentModule",
               "some_action"
             ) ==
               %{
                 name: "chat_reponse",
                 schema: %{
                   type: "object",
                   required: ["content"],
                   additionalProperties: false,
                   properties: %{
                     content: %{
                       type: "string",
                       description: "The main response text that will be shown to the user"
                     }
                   }
                 },
                 strict: true
               }
    end

    test "returns Workspace schema" do
      assert PromptRegistry.get_schema(
               "Index",
               "some_action"
             ) ==
               %{
                 name: "chat_reponse",
                 schema: %{
                   type: "object",
                   required: ["content", "skills"],
                   additionalProperties: false,
                   properties: %{
                     content: %{
                       type: "string",
                       description: "The main response text that will be shown to the user"
                     },
                     skills: %{
                       type: "array",
                       description: "Array of actionable skills that can be performed",
                       items: %{
                         type: "object",
                         required: ["id", "type", "description", "data"],
                         additionalProperties: false,
                         properties: %{
                           data: %{
                             type: "string",
                             description:
                               "Optional data to send with the skill as a JSON string ex: if a name is required for an action, send it here '{'name':'John Doe'}'. If something is to be analyzed, include the ID here."
                           },
                           id: %{type: "string", description: "Unique identifier for this skill"},
                           type: %{
                             type: "string",
                             enum: ["create"],
                             description: "The type of action this skill represents"
                           },
                           description: %{
                             type: "string",
                             description: "Human readable description of what this skill will do"
                           }
                         }
                       }
                     }
                   }
                 },
                 strict: true
               }
    end
  end

  describe "get_system_prompt/3" do
    test "returns the default system prompt if the module does not exist" do
      assert PromptRegistry.get_system_prompt(
               "NonExistentModule",
               "some_action",
               "some_workspace_id"
             ) =~
               "PLEASE RESPOND WITH JSON"
    end

    test "returns ApplicationInformation prompt" do
      workspace = workspace_fixture()

      assert PromptRegistry.get_system_prompt(
               "ApplicationInformation",
               "some_action",
               workspace.id
             ) =~
               Valentine.Prompts.ApplicationInformation.system_prompt(workspace.id, "some_action")
    end
  end

  describe "get_tag_line/2" do
    test "returns a random tag line if module_name and action do not exist" do
      assert String.length(
               PromptRegistry.get_tag_line(
                 "NonExistentModule",
                 "some_action"
               )
             ) > 0
    end

    test "returns ApplicationInformation tag line" do
      assert PromptRegistry.get_tag_line(
               "ApplicationInformation",
               :index
             ) ==
               Valentine.Prompts.ApplicationInformation.tag_line(:index)
    end
  end
end

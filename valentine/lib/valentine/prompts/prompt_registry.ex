defmodule Valentine.Prompts.PromptRegistry do
  alias Valentine.Prompts.{
    ApplicationInformation,
    # DataFlow,
    # Architecture,
    # Threat,
    # Assumption,
    # Mitigation,
    # ThreatModel
    Workspace
  }

  @modules %{
    "ApplicationInformation" => ApplicationInformation,
    "Index" => Workspace
    # "DataFlow" => DataFlow,
    # "Architecture" => Architecture,
    # "Threat" => Threat,
    # "Assumption" => Assumption,
    # "Mitigation" => Mitigation,
    # "ThreatModel" => ThreatModel
  }

  def get_system_prompt(module_name, action, workspace_id) do
    case Map.get(@modules, module_name) do
      nil -> base_prompt()
      module -> base_prompt() <> module.system_prompt(workspace_id, action)
    end
  end

  def get_tag_line(module_name, action) do
    case Map.get(@modules, module_name) do
      nil -> random_tag_line()
      module -> module.tag_line(action)
    end
  end

  def base_prompt() do
    """
    PLEASE RESPOND WITH JSON.

    FACTS:
    1. You are an expert threat modeling assistant focused on helping users manage their workspaces effectively.
    2. Each workspace contains multiple components: application information, architecture, data flows, assumptions, threats, and mitigations. Depending on context, more information about each of these will be provided to you.
    3. As part of your response, you can suggest actions based on your skills. You yourself cannot perform these actions, but the actions will be rendered as buttons for a user to click. As uses to click on the buttons to perform the actions on your behalf.
    """
  end

  def response_schema() do
    """
      {
    "name": "chat_reponse",
    "strict": true,
    "schema": {
        "type": "object",
        "properties": {
            "content": {
                "type": "string",
                "description": "The main response text that will be shown to the user"
            },
            "skills": {
                "type": "array",
                "description": "Array of actionable skills that can be performed",
                "items": {
                    "type": "object",
                    "properties": {
                        "id": {
                            "type": "string",
                            "description": "Unique identifier for this skill"
                        },
                        "type": {
                            "type": "string",
                            "enum": [
                                "edit",
                                "create",
                                "update",
                                "delete",
                                "analyze",
                                "validate"
                            ],
                            "description": "The type of action this skill represents"
                        },
                        "description": {
                            "type": "string",
                            "description": "Human readable description of what this skill will do"
                        },
                        "data": {
                            "type": "string",
                            "description": "Optional data to send with the skill as a JSON string ex: if a name is required for an action, send it here '{'name':'John Doe'}'. If something is to be analyzed, include the ID here."
                        }
                    },
                    "required": [
                        "id",
                        "type",
                        "description",
                        "data"
                    ],
                    "additionalProperties": false
                }
            }
        },
        "required": [
            "content",
            "skills"
        ],
        "additionalProperties": false
    }
    }
    """
  end

  defp random_tag_line() do
    [
      "The pastry chef kneaded a break from his job.",
      "Time flies when you're a watchmaker.",
      "The mathematician counted on his fingers.",
      "That vegetable gardener really knows how to turnip.",
      "The optometrist made a spectacle of himself.",
      "The astronaut needed some space to think.",
      "Piano teachers always note their students' progress.",
      "The electrician conducted himself with shocking professionalism.",
      "The tired calendar just needed a few more dates.",
      "That cheese joke wasn't very mature."
    ]
    |> Enum.random()
  end
end

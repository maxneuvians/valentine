defmodule Valentine.Prompts.PromptRegistry do
  alias Valentine.Prompts.{
    ApplicationInformation
    # DataFlow,
    # Architecture,
    # Threat,
    # Assumption,
    # Mitigation,
    # ThreatModel
  }

  @modules %{
    "ApplicationInformation" => ApplicationInformation
    # "DataFlow" => DataFlow,
    # "Architecture" => Architecture,
    # "Threat" => Threat,
    # "Assumption" => Assumption,
    # "Mitigation" => Mitigation,
    # "ThreatModel" => ThreatModel
  }

  def get_system_prompt(module_name, action, workspace_id) do
    case Map.get(@modules, module_name) do
      nil -> default_system_prompt(workspace_id)
      module -> module.system_prompt(workspace_id, action)
    end
  end

  def get_tag_line(module_name, action) do
    case Map.get(@modules, module_name) do
      nil -> random_tag_line()
      module -> module.tag_line(action)
    end
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
            "module": {
              "type": "string",
              "enum": [
                "ApplicationInformation",
                "DataFlow",
                "Architecture",
                "Threat",
                "Assumption",
                "Mitigation",
                "ThreatModel"
              ],
              "description": "The module this skill applies to"
            },
            "data": {
              "type": "string",
              "description": "Optional data to send with the skill"
            },
            "confirmation_message": {
              "type": "string",
              "description": "Optional message to show in a confirmation dialog"
            },
            "requirements": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "estimated_impact": {
              "type": "string",
              "enum": [
                "low",
                "medium",
                "high"
              ]
            }
          },
          "required": [
            "id",
            "type",
            "description",
            "module",
            "data",
            "confirmation_message",
            "requirements",
            "estimated_impact"
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

  defp default_system_prompt(workspace_id) do
    """
    You are a helpful assistant. The current workspace_id is #{workspace_id}. Please provide your response in JSON.
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

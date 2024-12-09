defmodule Valentine.Prompts.PromptRegistry do
  alias Valentine.Prompts.{
    ApplicationInformation,
    DataFlow,
    Architecture,
    Threat,
    Assumption,
    Mitigation,
    ThreatModel
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
    "type": "object",
    "properties": {
    "content": {
      "type": "string",
      "description": "The main response text that will be shown to the user"
    },
    "capabilities": {
      "type": "array",
      "description": "Array of actionable capabilities that can be performed",
      "items": {
        "type": "object",
        "properties": {
          "id": {
            "type": "string",
            "description": "Unique identifier for this capability"
          },
          "type": {
            "type": "string",
            "enum": ["edit", "create", "update", "delete", "analyze", "validate"],
            "description": "The type of action this capability represents"
          },
          "description": {
            "type": "string",
            "description": "Human readable description of what this capability will do"
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
            "description": "The module this capability applies to"
          },
          "data": {
            "type": "object",
            "properties": {
              "operation": {
                "type": "string",
                "enum": ["append", "replace", "update"]
              },
              "section_title": {
                "type": "string"
              },
              "content": {
                "type": "string"
              },
              "nodes": {
                "type": "array",
                "items": {
                  "type": "object",
                  "properties": {
                    "id": {
                      "type": "string"
                    },
                    "type": {
                      "type": "string",
                      "enum": ["process", "store", "external"]
                    },
                    "label": {
                      "type": "string"
                    }
                  },
                  "required": ["id", "type", "label"],
                  "additionalProperties": false
                }
              },
              "edges": {
                "type": "array",
                "items": {
                  "type": "object",
                  "properties": {
                    "from": {
                      "type": "string"
                    },
                    "to": {
                      "type": "string"
                    },
                    "label": {
                      "type": "string"
                    }
                  },
                  "required": ["from", "to", "label"],
                  "additionalProperties": false
                }
              }
            },
            "required": ["operation", "content"],
            "additionalProperties": false
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
            "enum": ["low", "medium", "high"]
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
    "required": ["content", "capabilities"],
    "additionalProperties": false
    }
    """
  end

  defp default_system_prompt(workspace_id) do
    """
    You are a helpful assistant. The current workspace_id is #{workspace_id}.
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

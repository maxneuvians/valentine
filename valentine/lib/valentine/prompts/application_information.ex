defmodule Valentine.Prompts.ApplicationInformation do
  def get_skills(_), do: []

  def system_prompt(workspace_id, _action) do
    workspace =
      Valentine.Composer.get_workspace!(workspace_id, [
        :application_information
      ])

    """
    ADDITIONAL FACTS:
    1. The current workspace_id is #{workspace_id}
    2. Application information contains information about the application that we are threat modelling agains
    3. Application Information is stored as a text field in the database
    4. The current content is: #{if workspace.application_information, do: workspace.application_information.content, else: "No content available"}

    RULES:
    1. All suggestions must align with the described application type
    2. Maintain consistency with existing features
    3. Generated content must be well-structured with clear sections
    4. Provide clear explanations for recommended actions
    5. Consider security implications of suggested changes

    SKILLS:
    1. INSERT new application information (This ALWAYS requires a workspace_id attribute in the data and delta instructions)
    2. UPDATE existing application information (This ALWAYS requires a workspace_id attribute in the data and delta instructions)

    ADDITIONAL SKILL INFORMATION:
    To execute skills, you must provide instruction to edit the application information using the following format for deltas operations defined by Quill.js in the data section of the skill as JSON. Below is an example of operations

    ```
    // Existing content
    // {
    //   ops: [
    //     { insert: 'Gandalf', attributes: { bold: true } },
    //     { insert: ' the ' },
    //     { insert: 'Grey', attributes: { color: '#cccccc' } }
    //   ]
    // }

    {
    ops: [
    // Unbold and italicize "Gandalf"
    { retain: 7, attributes: { bold: null, italic: true } },

    // Keep " the " as is
    { retain: 5 },

    // Insert "White" formatted with color #fff
    { insert: 'White', attributes: { color: '#fff' } },

    // Delete "Grey"
    { delete: 4 }
    ]
    }
    ```

    You are an expert threat modelling assistant focused on helping users document and understand their applications.
    """
  end

  def tag_line(:index), do: "I can help analyze and improve your application documentation."
end

defmodule CometoidWeb.IssueLive.KeysNav do
  
  defp selected_index item, items do
    {_item, index} = items
      |> Enum.with_index()
      |> Enum.find(fn {%{id: id}, _index} -> id == item.id end)
    index
  end

  def selected_issue_index %{ selected_issue: selected_issue, issues: issues } do
    selected_index selected_issue, issues
  end

  def selected_context_index %{ selected_context: selected_context, contexts: contexts } do
    selected_index selected_context, contexts
  end

  defp get_next index, items do
    if index + 1 < length items do
      Enum.at items, index + 1
    else
      Enum.at items, index
    end
  end

  defp get_previous index, items do
    if index - 1 >= 0 do
      Enum.at items, index - 1
    else
      Enum.at items, index
    end
  end

  def get_next_issue %{ issues: issues }, index do
    get_next index, issues
  end
  
  def get_previous_issue %{ issues: issues }, index do
    get_previous index, issues
  end

  def get_previous_context %{ contexts: contexts }, index do
    get_previous index, contexts
  end

  def get_next_context %{ contexts: contexts }, index do
    get_next index, contexts
  end

  def is_selected_issue_in_issues? %{ selected_issue: selected_issue, issues: issues } do
    not (is_nil(selected_issue) 
      or (selected_issue.id not in (Enum.map issues, &(&1.id))))
  end
end
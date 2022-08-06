defmodule CometoidWeb.IssueLive.KeysNav do
  
  def get_next_issue %{ selected_issue: selected_issue, issues: issues } = state do
    if is_selected_issue_in_issues? state do
      index = selected_index selected_issue, issues
      get_next index, issues
    else
      List.first state.issues
    end
  end
  
  def get_previous_issue %{ selected_issue: selected_issue, issues: issues } = state do
    if is_selected_issue_in_issues? state do
      index = selected_index selected_issue, issues
      get_previous index, issues
    else
      nil
    end
  end

  def get_previous_context %{ contexts: contexts, selected_context: selected_context } do
    if selected_context do
      index = selected_index selected_context, contexts
      get_previous index, contexts
    else
      selected_context
    end
  end

  def get_next_context %{ selected_context: selected_context, contexts: contexts } = state do
    if state.selected_context do
      index = selected_index selected_context, contexts
      get_next index, contexts
    else
      List.first contexts
    end
  end

  defp is_selected_issue_in_issues? %{ selected_issue: selected_issue, issues: issues } do
    not (is_nil(selected_issue) 
      or (selected_issue.id not in (Enum.map issues, &(&1.id))))
  end

  defp selected_index item, items do
    {_item, index} = items
      |> Enum.with_index()
      |> Enum.find(fn {%{id: id}, _index} -> id == item.id end)
    index
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
end
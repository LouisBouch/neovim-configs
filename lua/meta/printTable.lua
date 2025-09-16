local tree
local maxDepth
-- -- TODO: Add metatable fetching.
local function helper(table, depth)
  -- Checks if tree is nil
  if table == nil then
    tree = "Empty"
    return tree
  end
  for key, value in pairs(table) do
    -- Checks for end of table
    local prefix = "|-"
    if next(table, key) == nil then
      prefix = "|_"
    end
    -- Checks for depth
    if depth == maxDepth then
      tree = tree .. (string.rep("  ", depth) .. "REACHED MAX DEPTH\n")
      return
    end
    -- Formats table content in a tree structure
    if type(value) ~= "table" then
      tree = tree
        .. (
          string.rep("  ", depth)
          .. prefix
          .. key
          .. ": "
          .. tostring(value)
          .. "\n"
        )
    else
      tree = tree .. (string.rep("  ", depth) .. prefix .. key .. ": table\n")
      helper(value, depth + 1)
    end
  end
  return tree
end
_G.meta_h.tableStr = function(table, maxD)
  maxDepth = maxD or 5
  tree = "TABLE\n"
  return helper(table, 0)
end

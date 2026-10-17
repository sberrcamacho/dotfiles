-- vim.snippet (Neovim's snippet engine) rejects some LSP/VSCode snippet syntax that
-- friendly-snippets uses: transforms ${1/re/fmt/}, nested placeholders, $0 or $N
-- inside a placeholder default. expand() tries the snippet as-is and, if parsing fails,
-- retries with those constructs simplified so the tabstops still work.
local M = {}

-- index of the "}" matching the "{" at position `open`
local function match_brace(s, open)
  local depth = 0
  local i = open
  while i <= #s do
    local c = s:sub(i, i)
    if c == "\\" then
      i = i + 1
    elseif c == "{" then
      depth = depth + 1
    elseif c == "}" then
      depth = depth - 1
      if depth == 0 then return i end
    end
    i = i + 1
  end
end

-- placeholder default text without nested placeholders, tabstops or variables;
-- a reference to tabstop N becomes N's default text when known (`defaults[N]`)
local function flatten(text, defaults)
  local out, i = {}, 1
  while i <= #text do
    local c = text:sub(i, i)
    if c == "\\" then
      out[#out + 1] = text:sub(i, i + 1)
      i = i + 2
    elseif c == "$" then
      local nxt = text:sub(i + 1, i + 1)
      if nxt == "{" then
        local close = match_brace(text, i + 1)
        if not close then break end
        local inner = text:sub(i + 2, close - 1)
        local default = inner:match("^[%w_]+:(.*)$") -- ${N:default} / ${VAR:default}
        if default then
          out[#out + 1] = flatten(default, defaults)
        elseif defaults[inner] then
          out[#out + 1] = defaults[inner]
        end
        i = close + 1
      else
        local name = text:match("^[%w_]+", i + 1) or ""
        out[#out + 1] = defaults[name] or ""
        i = i + 1 + #name -- $N / $VAR
      end
    else
      out[#out + 1] = c
      i = i + 1
    end
  end
  return table.concat(out)
end

-- first pass: default text of every top-level ${N:text} that has no nesting
local function collect_defaults(body)
  local defaults = {}
  for num, text in body:gmatch("%${(%d+):([^${}]*)}") do
    defaults[num] = defaults[num] or text
  end
  return defaults
end

function M.sanitize(body)
  local defaults = collect_defaults(body)
  local out, i = {}, 1
  while i <= #body do
    local c = body:sub(i, i)
    if c == "\\" then
      out[#out + 1] = body:sub(i, i + 1)
      i = i + 2
    elseif c == "$" and body:sub(i + 1, i + 1) == "{" then
      local close = match_brace(body, i + 1)
      if not close then
        out[#out + 1] = body:sub(i)
        break
      end
      local inner = body:sub(i + 2, close - 1)
      local num, rest = inner:match("^(%d+)(.*)$")
      if num and rest:sub(1, 1) == "/" then
        out[#out + 1] = "$" .. num -- transform -> plain mirror of the tabstop
      elseif num and rest:sub(1, 1) == ":" then
        out[#out + 1] = "${" .. num .. ":" .. flatten(rest:sub(2), defaults) .. "}"
      else
        out[#out + 1] = body:sub(i, close) -- ${N} / ${VAR}, keep
      end
      i = close + 1
    else
      out[#out + 1] = c
      i = i + 1
    end
  end
  return table.concat(out)
end

function M.expand(snippet)
  if pcall(vim.snippet.expand, snippet) then return end
  local ok, err = pcall(vim.snippet.expand, M.sanitize(snippet))
  if not ok then vim.notify("Snippet could not be expanded: " .. tostring(err), vim.log.levels.WARN) end
end

return M

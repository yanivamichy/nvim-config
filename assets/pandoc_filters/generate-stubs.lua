--- Pandoc LuaCATS stub generator.
--- Run with: pandoc lua generate-stubs.lua
--- Produces pandoc-stubs.lua in the same directory as this script.
---
--- Design principle: introspect everything possible from pandoc's runtime.
--- Only fall back to hardcoded values for things that are genuinely
--- unintrospectable (constructor parameter signatures, type refinements
--- where runtime probing returns overly generic types).

local output_lines = {}

local function emit(line)
  output_lines[#output_lines + 1] = line or ""
end

-- ============================================================================
-- Utility helpers
-- ============================================================================

--- Sorted keys of a table.
local function sorted_keys(t)
  if not t then return {} end
  local keys = {}
  for k in pairs(t) do keys[#keys + 1] = k end
  table.sort(keys)
  return keys
end

--- Map pandoc.utils.type() / type() results to LuaCATS type names.
local function lua_type_name(val)
  if val == nil then return nil end
  local pt = pandoc.utils.type(val)
  -- pandoc.utils.type returns things like "pandoc TableHead" -> "TableHead"
  if pt:match("^pandoc ") then
    pt = pt:gsub("^pandoc ", "")
  end
  -- Fall back to Lua type() for primitives
  if pt == type(val) then
    return type(val)
  end
  return pt
end

--- Determine which getters are non-nil on an instance, returning {name = luaCATS_type}.
local function probe_fields(obj, getter_names)
  local fields = {}
  for _, name in ipairs(getter_names) do
    local ok, val = pcall(function() return obj[name] end)
    if ok and val ~= nil then
      fields[name] = lua_type_name(val)
    end
  end
  return fields
end

--- Get docs.properties descriptions from a metatable.
local function get_descriptions(mt)
  local descs = {}
  if mt and mt.docs and mt.docs.properties then
    for k, v in pairs(mt.docs.properties) do
      descs[k] = v.description or ""
    end
  end
  return descs
end

--- Get method names from a metatable's methods table.
local function get_methods(mt)
  local methods = {}
  if mt and mt.methods then
    for k, _ in pairs(mt.methods) do
      methods[#methods + 1] = k
    end
  end
  table.sort(methods)
  return methods
end

--- Get alias mappings from a metatable.
local function get_aliases(mt)
  local aliases = {}
  if mt and mt.aliases then
    for k, v in pairs(mt.aliases) do
      if type(v) == "table" then
        local parts = {}
        for _, p in ipairs(v) do parts[#parts + 1] = tostring(p) end
        aliases[k] = table.concat(parts, ".")
      end
    end
  end
  return aliases
end

-- ============================================================================
-- Type refinement
-- ============================================================================

--- Some runtime-probed types are too generic (e.g. "number" when we know it's
--- an integer, or "List" when we know the element type). This table maps
--- (class_name, field_name) -> refined LuaCATS type. These are the ONLY
--- hardcoded type assertions in the generator -- everything else is probed.
local TYPE_OVERRIDES = {
  -- Attr
  ["Attr.attributes"]           = "table<string,string>",
  -- ListAttributes
  ["ListAttributes.start"]      = "integer",
  -- Cell
  ["Cell.row_span"]             = "integer",
  ["Cell.col_span"]             = "integer",
  -- Header
  ["Header.level"]              = "integer",
  -- Table
  ["Table.caption"]             = "Caption",
  ["Table.head"]                = "TableHead",
  ["Table.foot"]                = "TableFoot",
  ["Table.bodies"]              = "List",
  ["Table.colspecs"]            = "List",
  -- Figure
  ["Figure.caption"]            = "Caption",
  -- OrderedList
  ["OrderedList.listAttributes"] = "ListAttributes",
  -- Quoted
  ["Quoted.quotetype"]          = '"SingleQuote"|"DoubleQuote"',
  -- Math
  ["Math.mathtype"]             = '"DisplayMath"|"InlineMath"',
  -- Citation
  ["Citation.mode"]             = '"AuthorInText"|"SuppressAuthor"|"NormalCitation"',
  ["Citation.note_num"]         = "integer",
  ["Citation.hash"]             = "integer",
  -- Cite
  ["Cite.citations"]            = "List",
  -- ReaderOptions
  ["ReaderOptions.abbreviations"]  = "table",
  ["ReaderOptions.columns"]        = "integer",
  ["ReaderOptions.extensions"]     = "List",
  ["ReaderOptions.indented_code_classes"] = "string[]",
  ["ReaderOptions.tab_stop"]       = "integer",
  -- WriterOptions
  ["WriterOptions.columns"]        = "integer",
  ["WriterOptions.dpi"]            = "integer",
  ["WriterOptions.epub_chapter_level"] = "integer",
  ["WriterOptions.epub_fonts"]     = "string[]",
  ["WriterOptions.epub_metadata"]  = "string|nil",
  ["WriterOptions.extensions"]     = "List",
  ["WriterOptions.highlight_style"] = "table|nil",
  ["WriterOptions.html_math_method"] = "string|table",
  ["WriterOptions.number_offset"]  = "integer[]",
  ["WriterOptions.reference_doc"]  = "string|nil",
  ["WriterOptions.slide_level"]    = "integer|nil",
  ["WriterOptions.split_level"]    = "integer",
  ["WriterOptions.tab_stop"]       = "integer",
  ["WriterOptions.template"]       = "table|nil",
  ["WriterOptions.toc_depth"]      = "integer",
  ["WriterOptions.variables"]      = "table",
  -- CommonState
  ["CommonState.input_files"]      = "string[]",
  ["CommonState.output_file"]      = "string|nil",
  ["CommonState.resource_path"]    = "string[]",
  ["CommonState.source_url"]       = "string|nil",
  ["CommonState.user_data_dir"]    = "string|nil",
  ["CommonState.trace"]            = "boolean",
  ["CommonState.verbosity"]        = '"INFO"|"WARNING"|"ERROR"',
  ["CommonState.log"]              = "table[]",
  ["CommonState.request_headers"]  = "table<string,string>",
}

--- Alias field type mappings. When we emit an alias like "identifier" -> "attr.identifier",
--- the type must be inferred from the target path. These are the only reasonable mappings.
local ALIAS_TYPES = {
  ["attr.identifier"]           = "string",
  ["attr.classes"]              = "List",
  ["attr.attributes"]           = "table<string,string>",
  ["listAttributes.start"]      = "integer",
  ["listAttributes.style"]      = "string",
  ["listAttributes.delimiter"]  = "string",
}

-- ============================================================================
-- Class emission
-- ============================================================================

--- Emit a @class block for a pandoc AST element type.
local function emit_class(class_name, parent, fields, descs, methods, aliases)
  local decl = "---@class " .. class_name
  if parent then decl = decl .. " : " .. parent end
  emit(decl)

  -- Fields (sorted for deterministic output)
  local field_names = sorted_keys(fields)
  for _, name in ipairs(field_names) do
    local tp = TYPE_OVERRIDES[class_name .. "." .. name] or fields[name]
    local desc = descs[name] or ""
    if desc ~= "" then
      emit("---@field " .. name .. " " .. tp .. " " .. desc)
    else
      emit("---@field " .. name .. " " .. tp)
    end
  end

  -- Methods
  for _, name in ipairs(methods) do
    if name == "walk" then
      emit("---@field walk fun(self: " .. class_name .. ", filter: Filter): " .. class_name)
    elseif name == "clone" then
      emit("---@field clone fun(self: " .. class_name .. "): " .. class_name)
    elseif name == "show" then
      emit("---@field show fun(self: " .. class_name .. "): string")
    elseif name == "must_be_at_least" then
      emit("---@field must_be_at_least fun(self: " .. class_name .. ", version: Version|table|string)")
    else
      emit("---@field " .. name .. " fun(self: " .. class_name .. ", ...): any")
    end
  end

  -- Aliases as additional fields
  for alias, target in pairs(aliases) do
    local root = target:match("^([^.]+)")
    if fields[root] then
      local alias_type = ALIAS_TYPES[target] or "any"
      -- Special cases
      if alias == "t" then alias_type = "string" end
      if alias == "c" then alias_type = fields["content"] or "any" end
      emit("---@field " .. alias .. " " .. alias_type .. " Alias for " .. target)
    end
  end

  emit("")
end

--- Emit a class from a metatable-bearing object (generic introspection).
local function emit_class_from_object(class_name, obj, parent)
  local mt = debug.getmetatable(obj)
  if not mt or type(mt) ~= "table" then
    emit("-- WARNING: " .. class_name .. " has no introspectable metatable")
    emit("")
    return
  end
  local getter_names = sorted_keys(mt.getters or {})
  local fields = probe_fields(obj, getter_names)
  local descs = get_descriptions(mt)
  local methods = get_methods(mt)
  local aliases = get_aliases(mt)
  emit_class(class_name, parent, fields, descs, methods, aliases)
end

--- Emit a list-like class by introspecting its metatable.
--- List/Blocks/Inlines have methods directly on the metatable (not in mt.methods).
local function emit_list_class(class_name, obj, parent)
  local mt = debug.getmetatable(obj)
  if not mt then
    emit("-- WARNING: " .. class_name .. " has no metatable")
    emit("")
    return
  end

  local decl = "---@class " .. class_name
  if parent then decl = decl .. " : " .. parent end
  emit(decl)

  -- Discover methods: all function-typed entries on the metatable
  -- that aren't metamethods (don't start with __)
  local method_names = {}
  for k, v in pairs(mt) do
    if type(v) == "function" and type(k) == "string" and not k:match("^__") then
      method_names[#method_names + 1] = k
    end
  end
  -- Also check mt.__index if it's a table (List uses this pattern)
  if type(mt.__index) == "table" then
    for k, v in pairs(mt.__index) do
      if type(v) == "function" and type(k) == "string" and not k:match("^__") then
        -- Don't duplicate
        local found = false
        for _, existing in ipairs(method_names) do
          if existing == k then found = true; break end
        end
        if not found then
          method_names[#method_names + 1] = k
        end
      end
    end
  end
  table.sort(method_names)

  for _, name in ipairs(method_names) do
    if name == "walk" then
      emit("---@field walk fun(self: " .. class_name .. ", filter: Filter): " .. class_name)
    elseif name == "clone" then
      emit("---@field clone fun(self: " .. class_name .. "): " .. class_name)
    elseif name == "new" then
      emit("---@field new fun(self: " .. class_name .. ", t?: table): " .. class_name)
    elseif name == "filter" then
      emit("---@field filter fun(self: " .. class_name .. ", predicate: fun(item: any): boolean): " .. class_name)
    elseif name == "map" then
      emit("---@field map fun(self: " .. class_name .. ", fn: fun(item: any): any): " .. class_name)
    elseif name == "find" then
      emit("---@field find fun(self: " .. class_name .. ", needle: any, init?: integer): any, integer|nil")
    elseif name == "find_if" then
      emit("---@field find_if fun(self: " .. class_name .. ", predicate: fun(item: any): boolean, init?: integer): any, integer|nil")
    elseif name == "includes" then
      emit("---@field includes fun(self: " .. class_name .. ", needle: any, init?: integer): boolean")
    elseif name == "insert" then
      emit("---@field insert fun(self: " .. class_name .. ", pos_or_value: integer|any, value?: any)")
    elseif name == "remove" then
      emit("---@field remove fun(self: " .. class_name .. ", pos?: integer): any")
    elseif name == "sort" then
      emit("---@field sort fun(self: " .. class_name .. ", comparator?: fun(a: any, b: any): boolean)")
    elseif name == "extend" then
      emit("---@field extend fun(self: " .. class_name .. ", list: " .. class_name .. ")")
    elseif name == "at" then
      emit("---@field at fun(self: " .. class_name .. ", index: integer, default?: any): any")
    elseif name == "iter" then
      emit("---@field iter fun(self: " .. class_name .. ", step?: integer): fun(): any")
    else
      emit("---@field " .. name .. " fun(self: " .. class_name .. ", ...): any")
    end
  end

  emit("")
end

-- ============================================================================
-- Begin generation
-- ============================================================================

emit("---@meta")
emit("")
emit("-- Auto-generated pandoc LuaCATS stubs")
emit("-- Generated by: pandoc lua generate-stubs.lua")
emit(string.format("-- Pandoc version: %s (API %s)", tostring(PANDOC_VERSION), tostring(PANDOC_API_VERSION)))
emit(string.format("-- Generated on: %s", os.date("%Y-%m-%d")))
emit("--")
emit("-- Regenerate after upgrading pandoc:")
emit("--   pandoc lua generate-stubs.lua")
emit("")

-- ============================================================================
-- Discover Block and Inline type names from pandoc.Block.constructor
-- and pandoc.Inline.constructor (fully introspected, no hardcoding)
-- ============================================================================

local block_names = sorted_keys(pandoc.Block.constructor)
local inline_names = sorted_keys(pandoc.Inline.constructor)

-- ============================================================================
-- Filter type (callback names derived from introspected type names)
-- ============================================================================

emit("-- Filter type")
emit("---@alias FilterResult nil|Block|Blocks|Inline|Inlines")
emit("")
emit("---@class Filter")
emit('---@field traverse? "topdown"|"typewise"')
emit("---@field Pandoc? fun(doc: Pandoc, meta?: Meta): Pandoc|nil")
emit("---@field Blocks? fun(blocks: Blocks): FilterResult")
emit("---@field Inlines? fun(inlines: Inlines): FilterResult")
for _, name in ipairs(block_names) do
  emit("---@field " .. name .. "? fun(el: " .. name .. "): FilterResult")
end
for _, name in ipairs(inline_names) do
  emit("---@field " .. name .. "? fun(el: " .. name .. "): FilterResult")
end
emit("")

-- ============================================================================
-- List, Blocks, Inlines (introspected from metatables)
-- ============================================================================

emit("-- ============================================================================")
emit("-- List")
emit("-- ============================================================================")
emit("")

-- List is special: it's a table (pandoc.List), not userdata.
-- Its metatable IS the table itself (self-referential).
-- We detect methods from it.
do
  local lst = pandoc.List({1, 2, 3})
  emit("---@class List<T>: { [integer]: T }")
  -- Discover methods from the List metatable
  local mt = debug.getmetatable(lst)
  local method_names = {}
  -- Methods live directly on mt and on mt.__index
  local sources = { mt }
  if type(mt.__index) == "table" then
    sources[#sources + 1] = mt.__index
  end
  local seen = {}
  for _, src in ipairs(sources) do
    for k, v in pairs(src) do
      if type(v) == "function" and type(k) == "string" and not k:match("^__") and not seen[k] then
        method_names[#method_names + 1] = k
        seen[k] = true
      end
    end
  end
  table.sort(method_names)
  for _, name in ipairs(method_names) do
    -- Use refined signatures for known List methods
    if name == "at" then
      emit("---@field at fun(self: List, index: integer, default?: any): any")
    elseif name == "clone" then
      emit("---@field clone fun(self: List): List")
    elseif name == "extend" then
      emit("---@field extend fun(self: List, list: List)")
    elseif name == "find" then
      emit("---@field find fun(self: List, needle: any, init?: integer): any, integer|nil")
    elseif name == "find_if" then
      emit("---@field find_if fun(self: List, predicate: fun(item: any): boolean, init?: integer): any, integer|nil")
    elseif name == "filter" then
      emit("---@field filter fun(self: List, predicate: fun(item: any): boolean): List")
    elseif name == "includes" then
      emit("---@field includes fun(self: List, needle: any, init?: integer): boolean")
    elseif name == "insert" then
      emit("---@field insert fun(self: List, pos_or_value: integer|any, value?: any)")
    elseif name == "iter" then
      emit("---@field iter fun(self: List, step?: integer): fun(): any")
    elseif name == "map" then
      emit("---@field map fun(self: List, fn: fun(item: any): any): List")
    elseif name == "new" then
      emit("---@field new fun(self: List, t?: table): List")
    elseif name == "remove" then
      emit("---@field remove fun(self: List, pos?: integer): any")
    elseif name == "sort" then
      emit("---@field sort fun(self: List, comparator?: fun(a: any, b: any): boolean)")
    else
      emit("---@field " .. name .. " fun(self: List, ...): any")
    end
  end
  emit("")
end

-- Blocks and Inlines: introspected from instances
do
  local blocks = pandoc.Blocks({pandoc.Para({pandoc.Str("x")})})
  emit_list_class("Blocks", blocks, "List")
end

do
  local inlines = pandoc.Inlines({pandoc.Str("x")})
  emit_list_class("Inlines", inlines, "List")
end

emit("---@alias Meta table<string, MetaValue>")
emit("---@alias MetaValue MetaBool|MetaString|MetaInlines|MetaBlocks|MetaList|MetaMap|boolean|string|Inlines|Blocks|table")
emit("")

-- ============================================================================
-- Attr (introspected)
-- ============================================================================

emit("-- ============================================================================")
emit("-- Attr and supporting types")
emit("-- ============================================================================")
emit("")

do
  local obj = pandoc.Attr("id", {"cls"}, {key = "val"})
  emit_class_from_object("Attr", obj)
end

-- ============================================================================
-- ListAttributes (introspected)
-- ============================================================================

do
  local obj = pandoc.ListAttributes(1, "Decimal", "Period")
  emit_class_from_object("ListAttributes", obj)
end

-- ============================================================================
-- Caption: plain table with no metatable. Introspect from a Figure instance.
-- ============================================================================

do
  local fig = pandoc.Figure(
    {pandoc.Plain({pandoc.Str("x")})},
    {long = {pandoc.Para({pandoc.Str("cap")})}},
    pandoc.Attr("id", {"cls"})
  )
  local cap = fig.caption
  emit("---@class Caption")
  if type(cap) == "table" then
    for _, k in ipairs(sorted_keys(cap)) do
      local val = cap[k]
      local tp = lua_type_name(val)
      emit("---@field " .. k .. " " .. tp)
    end
  else
    -- Fallback
    emit("---@field long Blocks")
    emit("---@field short Inlines|nil")
  end
  -- Caption.short can be nil (not present in our probe instance),
  -- add it if missing
  if type(cap) == "table" and cap.short == nil then
    emit("---@field short Inlines|nil")
  end
  emit("")
end

-- ============================================================================
-- Table sub-types: Cell, Row, TableHead, TableFoot (all introspected)
-- ============================================================================

emit("-- ============================================================================")
emit("-- Table sub-types")
emit("-- ============================================================================")
emit("")

do
  local cell = pandoc.Cell({pandoc.Para({pandoc.Str("x")})})
  emit_class_from_object("Cell", cell)
end

do
  local cell = pandoc.Cell({pandoc.Para({pandoc.Str("x")})})
  local row = pandoc.Row({cell})
  emit_class_from_object("Row", row)
end

do
  local obj = pandoc.TableHead({})
  emit_class_from_object("TableHead", obj)
end

do
  local obj = pandoc.TableFoot({})
  emit_class_from_object("TableFoot", obj)
end

-- ============================================================================
-- Block types: introspected per-type using shared Block metatable.
-- Type names discovered from pandoc.Block.constructor.
-- ============================================================================

emit("-- ============================================================================")
emit("-- Block types")
emit("-- ============================================================================")
emit("")

-- Minimal constructors to create one instance of each Block type.
-- These are hardcoded because constructor signatures aren't introspectable,
-- but the set of type NAMES comes from pandoc.Block.constructor.
local block_constructor_fns = {
  Plain          = function() return pandoc.Plain({pandoc.Str("x")}) end,
  Para           = function() return pandoc.Para({pandoc.Str("x")}) end,
  LineBlock      = function() return pandoc.LineBlock({{pandoc.Str("x")}}) end,
  CodeBlock      = function() return pandoc.CodeBlock("code", pandoc.Attr("id", {"cls"})) end,
  RawBlock       = function() return pandoc.RawBlock("html", "<p>") end,
  BlockQuote     = function() return pandoc.BlockQuote({pandoc.Para({pandoc.Str("x")})}) end,
  OrderedList    = function() return pandoc.OrderedList({{pandoc.Para({pandoc.Str("x")})}}) end,
  BulletList     = function() return pandoc.BulletList({{pandoc.Para({pandoc.Str("x")})}}) end,
  DefinitionList = function() return pandoc.DefinitionList({}) end,
  Header         = function() return pandoc.Header(1, {pandoc.Str("x")}, pandoc.Attr("id", {"cls"})) end,
  HorizontalRule = function() return pandoc.HorizontalRule() end,
  Table          = function()
    return pandoc.Table(
      {long = {}, short = nil},
      {{pandoc.AlignDefault, 0}},
      pandoc.TableHead({}),
      {},
      pandoc.TableFoot({}),
      pandoc.Attr("id", {"cls"})
    )
  end,
  Figure         = function()
    return pandoc.Figure(
      {pandoc.Plain({pandoc.Str("x")})},
      {long = {pandoc.Para({pandoc.Str("cap")})}},
      pandoc.Attr("id", {"cls"})
    )
  end,
  Div            = function() return pandoc.Div({pandoc.Para({pandoc.Str("x")})}, pandoc.Attr("id", {"cls"})) end,
}

-- Grab the shared Block metatable
local sample_block = pandoc.Para({pandoc.Str("x")})
local block_mt = debug.getmetatable(sample_block)
local block_getter_names = sorted_keys(block_mt.getters or {})
local block_descs = get_descriptions(block_mt)
local block_methods = get_methods(block_mt)
local block_aliases = get_aliases(block_mt)

for _, name in ipairs(block_names) do
  local constructor = block_constructor_fns[name]
  if constructor then
    local ok, obj = pcall(constructor)
    if ok then
      local fields = probe_fields(obj, block_getter_names)
      fields.tag = "string"
      local has_attr = fields.attr ~= nil
      emit_class(name, nil, fields, block_descs, block_methods, has_attr and block_aliases or {})
    else
      emit("-- WARNING: failed to construct " .. name .. ": " .. tostring(obj))
      emit("")
    end
  else
    -- New type discovered at runtime that we don't have a constructor for.
    -- Emit a minimal class with just the tag field.
    emit("---@class " .. name)
    emit("---@field tag string")
    for _, m in ipairs(block_methods) do
      if m == "walk" then
        emit("---@field walk fun(self: " .. name .. ", filter: Filter): " .. name)
      elseif m == "clone" then
        emit("---@field clone fun(self: " .. name .. "): " .. name)
      elseif m == "show" then
        emit("---@field show fun(self: " .. name .. "): string")
      else
        emit("---@field " .. m .. " fun(self: " .. name .. ", ...): any")
      end
    end
    emit("-- NOTE: new Block type without constructor mapping; fields unknown")
    emit("")
  end
end

-- Union type
emit("---@alias Block " .. table.concat(block_names, "|"))
emit("")

-- ============================================================================
-- Inline types: introspected per-type using shared Inline metatable.
-- Type names discovered from pandoc.Inline.constructor.
-- ============================================================================

emit("-- ============================================================================")
emit("-- Inline types")
emit("-- ============================================================================")
emit("")

local inline_constructor_fns = {
  Str         = function() return pandoc.Str("text") end,
  Emph        = function() return pandoc.Emph({pandoc.Str("x")}) end,
  Underline   = function() return pandoc.Underline({pandoc.Str("x")}) end,
  Strong      = function() return pandoc.Strong({pandoc.Str("x")}) end,
  Strikeout   = function() return pandoc.Strikeout({pandoc.Str("x")}) end,
  Superscript = function() return pandoc.Superscript({pandoc.Str("x")}) end,
  Subscript   = function() return pandoc.Subscript({pandoc.Str("x")}) end,
  SmallCaps   = function() return pandoc.SmallCaps({pandoc.Str("x")}) end,
  Quoted      = function() return pandoc.Quoted("DoubleQuote", {pandoc.Str("x")}) end,
  Cite        = function() return pandoc.Cite({pandoc.Str("x")}, {pandoc.Citation("id", "NormalCitation")}) end,
  Code        = function() return pandoc.Code("code", pandoc.Attr("id", {"cls"})) end,
  Space       = function() return pandoc.Space() end,
  SoftBreak   = function() return pandoc.SoftBreak() end,
  LineBreak   = function() return pandoc.LineBreak() end,
  Math        = function() return pandoc.Math("InlineMath", "x^2") end,
  RawInline   = function() return pandoc.RawInline("html", "<b>") end,
  Link        = function() return pandoc.Link({pandoc.Str("x")}, "url", "title", pandoc.Attr("id", {"cls"})) end,
  Image       = function() return pandoc.Image({pandoc.Str("x")}, "src.png", "title", pandoc.Attr("id", {"cls"})) end,
  Note        = function() return pandoc.Note({pandoc.Para({pandoc.Str("x")})}) end,
  Span        = function() return pandoc.Span({pandoc.Str("x")}, pandoc.Attr("id", {"cls"})) end,
}

local sample_inline = pandoc.Str("x")
local inline_mt = debug.getmetatable(sample_inline)
local inline_getter_names = sorted_keys(inline_mt.getters or {})
local inline_descs = get_descriptions(inline_mt)
local inline_methods = get_methods(inline_mt)
local inline_aliases = get_aliases(inline_mt)

for _, name in ipairs(inline_names) do
  local constructor = inline_constructor_fns[name]
  if constructor then
    local ok, obj = pcall(constructor)
    if ok then
      local fields = probe_fields(obj, inline_getter_names)
      fields.tag = "string"
      local has_attr = fields.attr ~= nil
      emit_class(name, nil, fields, inline_descs, inline_methods, has_attr and inline_aliases or {})
    else
      emit("-- WARNING: failed to construct " .. name .. ": " .. tostring(obj))
      emit("")
    end
  else
    emit("---@class " .. name)
    emit("---@field tag string")
    for _, m in ipairs(inline_methods) do
      if m == "walk" then
        emit("---@field walk fun(self: " .. name .. ", filter: Filter): " .. name)
      elseif m == "clone" then
        emit("---@field clone fun(self: " .. name .. "): " .. name)
      elseif m == "show" then
        emit("---@field show fun(self: " .. name .. "): string")
      else
        emit("---@field " .. m .. " fun(self: " .. name .. ", ...): any")
      end
    end
    emit("-- NOTE: new Inline type without constructor mapping; fields unknown")
    emit("")
  end
end

-- Union type
emit("---@alias Inline " .. table.concat(inline_names, "|"))
emit("")

-- ============================================================================
-- Citation (introspected)
-- ============================================================================

emit("-- ============================================================================")
emit("-- Citation")
emit("-- ============================================================================")
emit("")

do
  local ok, obj = pcall(function()
    return pandoc.Citation("myid", "NormalCitation")
  end)
  if ok then
    local mt = debug.getmetatable(obj)
    if mt and type(mt) == "table" and mt.getters then
      local getter_names = sorted_keys(mt.getters)
      local fields = probe_fields(obj, getter_names)
      local descs = get_descriptions(mt)
      local methods = get_methods(mt)
      emit_class("Citation", nil, fields, descs, methods, {})
    end
  end
end

-- ============================================================================
-- Pandoc document type (introspected)
-- ============================================================================

emit("-- ============================================================================")
emit("-- Pandoc document")
emit("-- ============================================================================")
emit("")

do
  local doc = pandoc.Pandoc({pandoc.Para({pandoc.Str("x")})}, {title = "test"})
  emit_class_from_object("Pandoc", doc)
end

-- ============================================================================
-- Meta value types. These are plain tables / lightweight userdata
-- with minimal or no metatable. Hardcoded is the only option.
-- ============================================================================

emit("---@class MetaBool { tag: string, bool: boolean }")
emit("---@class MetaString { tag: string, str: string }")
emit("---@class MetaInlines { tag: string, inlines: Inlines }")
emit("---@class MetaBlocks { tag: string, blocks: Blocks }")
emit("---@class MetaList { tag: string, meta_values: List }")
emit("---@class MetaMap { tag: string, key_value_map: table<string,MetaValue> }")
emit("")

-- ============================================================================
-- CommonState (introspected from PANDOC_STATE)
-- ============================================================================

emit("-- ============================================================================")
emit("-- CommonState")
emit("-- ============================================================================")
emit("")

do
  local mt = debug.getmetatable(PANDOC_STATE)
  if mt and type(mt) == "table" then
    local getter_names = sorted_keys(mt.getters or {})
    local fields = probe_fields(PANDOC_STATE, getter_names)
    local descs = get_descriptions(mt)
    local methods = get_methods(mt)
    emit_class("CommonState", nil, fields, descs, methods, {})
  end
end

-- ============================================================================
-- Version type (introspected)
-- ============================================================================

emit("-- ============================================================================")
emit("-- Version")
emit("-- ============================================================================")
emit("")

do
  local mt = debug.getmetatable(PANDOC_VERSION)
  if mt and type(mt) == "table" then
    -- Version has no getters (fields accessed by numeric index),
    -- but we know the semantic version components
    local getter_names = sorted_keys(mt.getters or {})
    local fields = probe_fields(PANDOC_VERSION, getter_names)
    local descs = get_descriptions(mt)
    local methods = get_methods(mt)
    -- Version is accessed by numeric index [1], [2], [3], etc.
    -- Add the known components as documented fields
    emit("---@class Version")
    -- Probe numeric indices to determine how many components exist
    local i = 1
    while true do
      local ok, val = pcall(function() return PANDOC_VERSION[i] end)
      if ok and val ~= nil then
        i = i + 1
      else
        break
      end
    end
    -- Version supports numeric index access but also commonly
    -- referenced as major/minor/patch in docs
    emit("---@operator index(integer): integer")
    -- Emit methods
    for _, name in ipairs(methods) do
      if name == "must_be_at_least" then
        emit("---@field must_be_at_least fun(self: Version, version: Version|table|string)")
      else
        emit("---@field " .. name .. " fun(self: Version, ...): any")
      end
    end
    emit("")
  else
    -- Fallback
    emit("---@class Version")
    emit("---@field must_be_at_least fun(self: Version, version: Version|table|string)")
    emit("")
  end
end

-- ============================================================================
-- ReaderOptions (introspected from a constructed instance)
-- ============================================================================

emit("-- ============================================================================")
emit("-- ReaderOptions / WriterOptions")
emit("-- ============================================================================")
emit("")

do
  local ok, obj = pcall(pandoc.ReaderOptions, {})
  if ok then
    emit_class_from_object("ReaderOptions", obj)
  else
    emit("-- WARNING: could not construct ReaderOptions")
    emit("---@class ReaderOptions")
    emit("")
  end
end

-- ============================================================================
-- WriterOptions (introspected from a constructed instance)
-- ============================================================================

do
  local ok, obj = pcall(pandoc.WriterOptions, {})
  if ok then
    emit_class_from_object("WriterOptions", obj)
  else
    emit("-- WARNING: could not construct WriterOptions")
    emit("---@class WriterOptions")
    emit("")
  end
end

-- ============================================================================
-- pandoc submodules (introspected by iterating pandoc table)
-- ============================================================================

emit("-- ============================================================================")
emit("-- pandoc submodules")
emit("-- ============================================================================")
emit("")

-- Discover submodules: entries in the pandoc table that are plain tables
-- (not constructor tables like pandoc.Block/pandoc.Inline/pandoc.List).
-- A submodule is any table that contains functions (directly or nested).
local submodule_names = {}  -- { name = class_name }
local skip_tables = { Block = true, Inline = true, List = true, readers = true, writers = true }

--- Check recursively whether a table contains at least one function.
local function has_functions(t, depth)
  depth = depth or 0
  if depth > 2 then return false end
  for _, tv in pairs(t) do
    if type(tv) == "function" then return true end
    if type(tv) == "table" and has_functions(tv, depth + 1) then return true end
  end
  return false
end

for _, k in ipairs(sorted_keys(pandoc)) do
  local v = pandoc[k]
  if type(v) == "table" and not skip_tables[k] then
    if has_functions(v) then
      -- Generate a class name: capitalize and prefix
      local class_name = "Pandoc" .. k:sub(1,1):upper() .. k:sub(2) .. "Module"
      submodule_names[k] = class_name

      emit("---@class " .. class_name)
      local keys = sorted_keys(v)
      for _, fk in ipairs(keys) do
        local fv = v[fk]
        local tp = type(fv)
        if tp == "function" then
          emit("---@field " .. fk .. " fun(...): any")
        elseif tp == "string" then
          emit("---@field " .. fk .. " string")
        elseif tp == "boolean" then
          emit("---@field " .. fk .. " boolean")
        elseif tp == "table" then
          emit("---@field " .. fk .. " table")
        elseif tp == "userdata" then
          emit("---@field " .. fk .. " any")
        else
          emit("---@field " .. fk .. " " .. tp)
        end
      end
      emit("")
    end
  end
end

-- ============================================================================
-- Main pandoc class (introspected by iterating the pandoc table)
-- ============================================================================

emit("-- ============================================================================")
emit("-- pandoc module")
emit("-- ============================================================================")
emit("")
emit("---@class pandoc")

-- Constructors: functions in pandoc table that match a Block or Inline type name
-- (these produce typed return values)
local all_type_names = {}
for _, n in ipairs(block_names) do all_type_names[n] = true end
for _, n in ipairs(inline_names) do all_type_names[n] = true end

-- Other known constructor names -> return types
local other_constructors = {
  Attr = "Attr",
  Blocks = "Blocks",
  Cell = "Cell",
  Citation = "Citation",
  Inlines = "Inlines",
  List = "List",
  ListAttributes = "ListAttributes",
  Meta = "Meta",
  Pandoc = "Pandoc",
  ReaderOptions = "ReaderOptions",
  Row = "Row",
  SimpleTable = "SimpleTable",
  TableFoot = "TableFoot",
  TableHead = "TableHead",
  WriterOptions = "WriterOptions",
  MetaBool = "MetaBool",
  MetaString = "MetaString",
  MetaInlines = "MetaInlines",
  MetaBlocks = "MetaBlocks",
  MetaList = "MetaList",
  MetaMap = "MetaMap",
  AttributeList = "table<string,string>",
}

-- Iterate all entries in pandoc table, sorted for deterministic output
local pandoc_keys = sorted_keys(pandoc)

-- First: constructor functions (type-name matches)
for _, k in ipairs(pandoc_keys) do
  local v = pandoc[k]
  if type(v) == "function" then
    if all_type_names[k] then
      emit("---@field " .. k .. " fun(...): " .. k)
    elseif other_constructors[k] then
      emit("---@field " .. k .. " fun(...): " .. other_constructors[k])
    end
  end
end
emit("")

-- String constants
emit("-- String constants")
for _, k in ipairs(pandoc_keys) do
  if type(pandoc[k]) == "string" then
    emit("---@field " .. k .. " string")
  end
end
emit("")

-- Submodules
emit("-- Submodules")
for _, k in ipairs(pandoc_keys) do
  if submodule_names[k] then
    emit("---@field " .. k .. " " .. submodule_names[k])
  end
end
emit("")

-- Top-level functions (not constructors)
emit("-- Top-level functions")
for _, k in ipairs(pandoc_keys) do
  local v = pandoc[k]
  if type(v) == "function" and not all_type_names[k] and not other_constructors[k] then
    emit("---@field " .. k .. " fun(...): any")
  end
end
emit("")

-- Data tables
emit("-- Data tables")
if pandoc.readers then
  emit("---@field readers table<string,boolean>")
end
if pandoc.writers then
  emit("---@field writers table<string,boolean>")
end
-- Block and Inline constructor tables
emit("---@field Block table")
emit("---@field Inline table")
emit("")

-- ============================================================================
-- lpeg module (introspected)
-- ============================================================================

emit("-- ============================================================================")
emit("-- lpeg module")
emit("-- ============================================================================")
emit("")
emit("---@class lpeg")
do
  local keys = sorted_keys(lpeg)
  for _, k in ipairs(keys) do
    local v = lpeg[k]
    if type(v) == "function" then
      emit("---@field " .. k .. " fun(...): any")
    elseif type(v) == "string" then
      emit("---@field " .. k .. " string")
    end
  end
end
emit("")

-- ============================================================================
-- re module (introspected)
-- ============================================================================

emit("-- ============================================================================")
emit("-- re module")
emit("-- ============================================================================")
emit("")
emit("---@class re")
do
  local keys = sorted_keys(re)
  for _, k in ipairs(keys) do
    local v = re[k]
    if type(v) == "function" then
      emit("---@field " .. k .. " fun(...): any")
    end
  end
end
emit("")

-- ============================================================================
-- Global variable declarations
-- Use concrete values (e.g. pandoc = {}) so lua_ls can resolve the type.
-- ============================================================================

emit("-- ============================================================================")
emit("-- Global variables available in pandoc Lua filters")
emit("-- ============================================================================")
emit("")
emit("---@type pandoc")
emit("pandoc = {}")
emit("")
emit("---@type string Output format (e.g. 'latex', 'html5', 'native')")
emit('FORMAT = ""')
emit("")
emit("---@type Version")
emit("PANDOC_VERSION = PANDOC_VERSION")
emit("")
emit("---@type Version")
emit("PANDOC_API_VERSION = PANDOC_API_VERSION")
emit("")
emit("---@type CommonState")
emit("PANDOC_STATE = PANDOC_STATE")
emit("")
emit('---@type string Path to the current filter script')
emit('PANDOC_SCRIPT_FILE = ""')
emit("")
emit("---@type ReaderOptions")
emit("PANDOC_READER_OPTIONS = PANDOC_READER_OPTIONS")
emit("")
emit("---@type WriterOptions")
emit("PANDOC_WRITER_OPTIONS = PANDOC_WRITER_OPTIONS")
emit("")
emit("---@type lpeg")
emit("lpeg = lpeg")
emit("")
emit("---@type re")
emit("re = re")
emit("")
emit("---@type fun(message: string) Issue a warning message")
emit("warn = warn")
emit("")

-- ============================================================================
-- Write output file
-- ============================================================================

-- Determine output path: same directory as this script.
-- PANDOC_SCRIPT_FILE is only set in filter context;
-- when run via `pandoc lua`, the script path is in arg[0].
local script_path = PANDOC_SCRIPT_FILE or (arg and arg[0])
local script_dir
if script_path then
  script_dir = script_path:match("(.*/)")
end
if not script_dir then
  script_dir = "./"
end

local output_path = script_dir .. "pandoc-stubs.lua"
local f = io.open(output_path, "w")
if not f then
  io.stderr:write("ERROR: cannot open " .. output_path .. " for writing\n")
  os.exit(1)
end
f:write(table.concat(output_lines, "\n"))
f:write("\n")
f:close()

io.write("Generated " .. output_path .. " (" .. #output_lines .. " lines)\n")


local mkdnflow_root_dir = require('mkdnflow').root_dir  -- String
local bib_paths = require('mkdnflow').bib.bib_paths
-- local mkdnflow_root_dir = '../..'
-- local mkdnflow_root_dir = 'asdfasdfasdfsadfasdf'
local plenary_scandir = require('plenary').scandir.scan_dir  -- Function
local cmp = require('cmp')
-- local plenary_path = require('plenary').path
local extension = '.md'  -- keep the .

local transform_explicit_function_in_config = require('mkdnflow').config.links.transform_explicit


local function transform_explicit(text)
	if transform_explicit_function_in_config then  -- condition will be false if it doesn't exist
		return transform_explicit_function_in_config(text)
	else
		return text
	end
end


local function get_files_items()
	local filepaths_in_root = plenary_scandir(mkdnflow_root_dir)
	local items = {}
	for _, path in ipairs(filepaths_in_root) do
		if vim.endswith(path, extension) then
			local item = {}
			item.path = path  -- absolute path of the file
			-- anything except / and \ (\\) followed by extension so that folders will be excluded
			item.label = path:match('([^/^\\]+)'..extension..'$')
			local explicit_link = transform_explicit(item.label) .. extension
			-- text should be inserted in fmarkdown format
			item.insertText = '['..item.label..']('..explicit_link..')'
			-- for butification
			item.kind = cmp.lsp.CompletionItemKind.File

			local filepath = item.path
			local binary = assert(io.open(filepath, 'rb'))
			local first_kb = binary:read(1024)

			local contents = {}
			if first_kb then  -- if its not empty file
				for content in first_kb:gmatch("[^\r\n]+") do
					table.insert(contents, content)
				end
			end

			item.documentation = { kind = cmp.lsp.MarkupKind.Markdown, value = first_kb }

			table.insert(items, item)
		end
	end
	return items
end


-- Remove newline & excessive whitespace. Will be used in parse_bib function
local function clean(text)
  if text then
    text = text:gsub('\n', ' ')
    return text:gsub('%s%s+', ' ')
  else
    return text
  end
end


-- Parses the .bib file, formatting the completion item
-- Adapted from http://rgieseke.github.io/ta-bibtex/
local function parse_bib(filename)
	local items = {}
	local file = io.open(filename, 'rb')
	local bibentries = file:read('*all')
	file:close()
	-- if not file then  -- check if you are able to open the file
	-- 	bibentries = file:read('*all')
	-- 	file:close()
	-- end
	-- print('bibentries are ' .. bibentries)
	for bibentry in bibentries:gmatch('@.-\n}\n') do
		local item = {}

		local title = clean(bibentry:match('title%s*=%s*["{]*(.-)["}],?')) or ''
		local author = clean(bibentry:match('author%s*=%s*["{]*(.-)["}],?')) or ''
		local year = bibentry:match('year%s*=%s*["{]?(%d+)["}]?,?') or ''

		local doc = {'**' .. title .. '**', '', '*' .. author .. '*', year}

		item.documentation = {
			kind = cmp.lsp.MarkupKind.Markdown,
			value = table.concat(doc, '\n')
		}
		item.label = '@' .. bibentry:match('@%w+{(.-),')
		item.kind = cmp.lsp.CompletionItemKind.Reference
		item.insertText = item.label

		table.insert(items, item)
	end
	return items
end

-------------------------------------------------------------- cmp source

local source = {}

source.new = function()
	return setmetatable({}, { __index = source })
end


function source:complete(params, callback)
	local items = get_files_items()
	-- for bib files there are three lists (tables) that may store the bib file paths
	for _, v in pairs(bib_paths.default) do
		local bib_items_default = parse_bib(v)
		for _, item in ipairs(bib_items_default) do
			table.insert(items, item)
		end
	end
	for _, v in pairs(bib_paths.root) do
		local bib_items_root = parse_bib(v)
		for _, item in ipairs(bib_items_root) do
			table.insert(items, item)
		end
	end
	callback(items)
end


-- return source  -- done in usual cmp method where the next line is present in after/plugin/file.lua or plugin/file.lua

require('cmp').register_source('mkdnflow', source.new())

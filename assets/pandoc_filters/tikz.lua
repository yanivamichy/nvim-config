local system = pandoc.system

local tikz_doc_template = [[
\documentclass{standalone}
\usepackage{xcolor}
\usepackage{tikz}
\usetikzlibrary{quantikz2}
\usetikzlibrary{shapes.arrows, shadows, optics, decorations}
\usetikzlibrary{calc}
\usepackage{pgfgantt}
\makeatletter
\tikzset{
  show_fig_name/.code={
    \tikz@addmode{
      \message{Fig name is: |\tikz@fig@name|}
    }
  }
}
\makeatother
\begin{document}
\nopagecolor
\begin{%s}
%s
\end{%s}
\end{document}
]]

local function file_exists(name)
  local f = io.open(name, 'rb')
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

local function read_file(path)
  local f, err = io.open(path, 'rb')
  if not f then
    return nil, err
  end
  local content = f:read '*a'
  f:close()
  return content
end

local function write_file(path, content)
  local f, err = io.open(path, 'wb')
  if not f then
    error('Could not open ' .. path .. ' for writing: ' .. (err or 'unknown error'))
  end
  f:write(content)
  f:close()
end

local function run(cmd, log_path, label)
  local ok, why, code = os.execute(cmd)
  if ok == true or ok == 0 then
    return
  end

  local msg = (label or 'Command failed') .. ': ' .. cmd
  if why ~= nil or code ~= nil then
    msg = msg .. string.format(' (%s %s)', tostring(why), tostring(code))
  end

  if log_path and file_exists(log_path) then
    local log = read_file(log_path)
    if log and #log > 0 then
      msg = msg .. '\n\nLast part of log:\n' .. log:sub(math.max(1, #log - 4000))
    end
  end

  error(msg)
end

local function tikz2image(src, filetype, outfile, subtype)
  local source_dir = (PANDOC_STATE.input_files[1] or '.'):match '(.*/)' or '.'
  system.with_working_directory(source_dir, function()
    system.with_temporary_directory('tikz2image', function(tmpdir)
      local texfile = tmpdir .. '/tikz.tex'

      write_file(texfile, tikz_doc_template:format(subtype, src, subtype))
      if filetype == 'pdf' then
        local pdfout = tmpdir .. '/tikz.pdf'
        run(string.format('pdflatex -interaction=nonstopmode -halt-on-error -output-directory=%s %s', tmpdir, texfile))
        run(string.format('mv -f %s %s', pdfout, outfile))
      elseif filetype == 'svg' then
        local dviout = tmpdir .. '/tikz.dvi'
        run(string.format('latex -interaction=nonstopmode -halt-on-error -output-directory=%s %s', tmpdir, texfile))
        run(string.format('dvisvgm --no-fonts --exact -o %s %s', outfile, dviout))
      else
        error('Unsupported filetype: ' .. tostring(filetype))
      end
    end)
  end)
end

local extension_for = {
  html = 'svg',
  html4 = 'svg',
  html5 = 'svg',
  latex = 'pdf',
  beamer = 'pdf',
}

function CodeBlock(block)
  if not block.classes:includes 'tikz' then
    return nil
  end

  local subtype = block.attributes['subtype'] or 'tikzpicture'
  local caption_str = block.attributes['caption']
  local caption = caption_str and pandoc.Inlines(caption_str) or {}
  local title = block.attributes['title'] or ''
  -- local align = block.attributes['align'] or ''
  local width = block.attributes['width'] or ''
  local filetype = extension_for[FORMAT] or 'svg'

  local cache_dir = os.getenv 'HOME' .. '/.cache/pandoc/'
  os.execute('mkdir -p ' .. cache_dir)
  local hash = pandoc.sha1(block.text)
  local fname = cache_dir .. hash .. '.' .. filetype

  if not file_exists(fname) then
    tikz2image(block.text, filetype, fname, subtype)
  end
  local img = pandoc.Image(caption, fname, title, { width = width })

  if caption_str and caption_str ~= '' then
    local caption_inlines = pandoc.read(caption_str).blocks[1].content
    return pandoc.Figure({ pandoc.Plain { img } }, { long = { pandoc.Plain(caption_inlines) } })
  end

  if FORMAT:match 'latex' then
    return pandoc.Para {
      pandoc.RawInline('latex', '\\begin{center}'),
      img,
      pandoc.RawInline('latex', '\\end{center}'),
    }
  end
  if FORMAT:match 'html' then
    img.attributes.style = 'margin:auto; display: block;'
    return img
  end
  return img
end
